import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/book_category_display.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/book_cover_display.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/cloudinary_service.dart';

import 'dart:async';

import 'data/books_repository.dart';
import 'domain/book_list_query.dart';
import 'presentation/book_list_controller.dart';

extension _SortKeyLabelX on BookSortKey {
  String label(AppLocalizations t) {
    switch (this) {
      case BookSortKey.title:
        return t.sortOptionTitle;
      case BookSortKey.author:
        return t.sortOptionAuthor;
      case BookSortKey.category:
        return t.sortOptionCategory;
      case BookSortKey.available:
        return t.sortOptionStock;
      case BookSortKey.created:
        return t.sortOptionDateAdded;
    }
  }
}

/// Màn hình danh sách sách (Admin) — cuộn một luồng (CustomScrollView) để tránh overflow trên web.
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  static const int _kMaxBulkCoverBytes = 330000;

  final _searchController = TextEditingController();
  static const String _kAllCategories = '__ALL__'; // UI only
  String _selectedCategoryKey = _kAllCategories; // UI only
  bool _isGridView = true;
  BookSortKey _sortKey = BookSortKey.title;

  /// Chọn nhiều để xóa (chỉ nhân sự).
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _bulkDeleting = false;
  bool _bulkCoverBusy = false;

  bool get _bulkListInteractionLocked => _bulkDeleting || _bulkCoverBusy;

  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 40;
  bool _fetchMoreScheduled = false;

  Timer? _searchDebounce;
  String _searchText = ''; // UI input -> controller query

  late final BooksRepository _repo;
  late final BookListController _controller;
  late final Future<QuerySnapshot<Map<String, dynamic>>> _categoriesFuture;

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      final next = _searchController.text;
      if (!mounted) return;
      if (next == _searchText) return;
      setState(() => _searchText = next);
      _controller.setQuery(_buildQuery());
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _repo = BooksRepository();
    _controller = BookListController(
      repo: _repo,
      pageSize: _pageSize,
      initialQuery: const BookListQuery(
        category: null,
        searchText: '',
        sortKey: BookSortKey.title,
      ),
    );
    _categoriesFuture = _repo.fetchCategoriesOnce();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.refresh();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  BookListQuery _buildQuery() {
    final category = _selectedCategoryKey == _kAllCategories
        ? null
        : _selectedCategoryKey;
    return BookListQuery(
      category: category,
      searchText: _searchText,
      sortKey: _sortKey,
    );
  }

  /// Controller cache phân trang — sau khi sửa/xóa Firestore cần gọi để UI khớp dữ liệu.
  void _pushBooksRouteThenRefresh(String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments).then((_) {
      if (!mounted) return;
      _controller.refresh();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    // tải thêm khi gần cuối
    if (pos.pixels >= pos.maxScrollExtent - 1400) {
      if (_fetchMoreScheduled) return;
      _fetchMoreScheduled = true;
      // Microtask debounce to avoid duplicate calls during ballistic scroll.
      scheduleMicrotask(() async {
        _fetchMoreScheduled = false;
        await _controller.fetchMore();
      });
    }
  }

  List<(String key, String label)> _categoryRowsOnce(
    QuerySnapshot<Map<String, dynamic>>? catSnap,
    AppLocalizations t,
  ) {
    final names = <String>{};
    if (catSnap != null) {
      for (final d in catSnap.docs) {
        final n = d.data()['name'] as String?;
        if (n != null && n.trim().isNotEmpty) names.add(n.trim());
      }
    }
    final sorted = names.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [(_kAllCategories, t.categoryAll), ...sorted.map((n) => (n, n))];
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  /// Nhấn giữ để bật chọn nhiều và chọn/bỏ cuốn đang giữ (nhân sự).
  void _onBookLongPress(_BookItem book) {
    if (!AppUser.isStaff || _bulkListInteractionLocked) return;
    setState(() {
      _selectMode = true;
      if (_selectedIds.contains(book.id)) {
        _selectedIds.remove(book.id);
      } else {
        _selectedIds.add(book.id);
      }
    });
  }

  Future<void> _confirmBulkDelete(AppLocalizations t) async {
    if (_selectedIds.isEmpty) return;
    final n = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.bookListBulkDeleteConfirm(n)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(t.deleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _runBulkDelete(t);
  }

  Future<({Uint8List bytes, String filename})?> _pickOneCoverImageFile() async {
    if (kIsWeb) {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (pick == null || pick.files.isEmpty) return null;
      final f = pick.files.single;
      final bytes = f.bytes;
      if (bytes == null) return null;
      final name = (f.name).trim().isEmpty ? 'cover.jpg' : f.name.trim();
      return (bytes: bytes, filename: name);
    }
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      maxHeight: 1080,
      imageQuality: 68,
    );
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    final name = x.name.trim().isEmpty ? 'cover.jpg' : x.name.trim();
    return (bytes: bytes, filename: name);
  }

  Future<void> _confirmBulkReplaceCover(AppLocalizations t) async {
    if (_selectedIds.isEmpty) return;
    final n = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.bookListBulkReplaceCover(n)),
        content: Text(t.bookListBulkReplaceCoverConfirm(n)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonDone),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _bulkCoverBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _pickOneCoverImageFile();
      if (picked == null || !mounted) return;
      if (picked.bytes.length > _kMaxBulkCoverBytes) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.bookCoverImageTooLarge)),
        );
        return;
      }
      final url = await CloudinaryService.uploadBookCoverBytes(
        bytes: picked.bytes,
        filename: picked.filename,
      );
      final db = FirebaseFirestore.instance;
      final refs = db.collection('books');
      final ids = _selectedIds.toList();
      const chunk = 450;
      for (var i = 0; i < ids.length; i += chunk) {
        final end = i + chunk > ids.length ? ids.length : i + chunk;
        final batch = db.batch();
        for (var j = i; j < end; j++) {
          batch.update(refs.doc(ids[j]), {
            'imageUrl': url,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.bookListBulkReplaceCoverDone(n))),
      );
      await _controller.refresh();
      _exitSelectMode();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.bookListBulkReplaceCoverError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _bulkCoverBusy = false);
    }
  }

  Future<void> _openPerBookCoverPicker(AppLocalizations t) async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();
    final docsById = <String, _BookItem>{};
    for (final d in _controller.state.docs) {
      if (_selectedIds.contains(d.id)) {
        docsById[d.id] = _BookItem.fromDoc(d);
      }
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PerBookCoverPickerSheet(
        selectedIds: ids,
        initialById: docsById,
        maxBytes: _kMaxBulkCoverBytes,
      ),
    );
    if (!mounted) return;
    await _controller.refresh();
  }

  Future<void> _runBulkDelete(AppLocalizations t) async {
    final ids = _selectedIds.toList();
    if (ids.isEmpty) return;
    setState(() => _bulkDeleting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = FirebaseFirestore.instance;
      final busy = <String>{};
      for (var i = 0; i < ids.length; i += 10) {
        final part = ids.skip(i).take(10).toList();
        final q = await db
            .collection('borrow_records')
            .where('status', isEqualTo: 'borrowing')
            .where('bookId', whereIn: part)
            .get();
        for (final d in q.docs) {
          final bid = d.data()['bookId'];
          if (bid is String && bid.isNotEmpty) busy.add(bid);
        }
      }
      final toDelete = ids.where((id) => !busy.contains(id)).toList();
      var deleted = 0;
      const chunk = 400;
      for (var i = 0; i < toDelete.length; i += chunk) {
        final end = i + chunk > toDelete.length ? toDelete.length : i + chunk;
        final batch = db.batch();
        for (var j = i; j < end; j++) {
          batch.delete(db.collection('books').doc(toDelete[j]));
        }
        await batch.commit();
        deleted += end - i;
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.bookListBulkDeleteResult(deleted, busy.length)),
        ),
      );
      await _controller.refresh();
      _exitSelectMode();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.deleteBookError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _bulkDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final staff = AppUser.isStaff;
    return ChangeNotifierProvider<BookListController>.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          leading: _selectMode && staff
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: t.commonCancel,
                  onPressed: _exitSelectMode,
                )
              : null,
          title: Text(
            _selectMode && staff
                ? t.bookListSelectedCount(_selectedIds.length)
                : t.bookListTitle,
          ),
          actions: [
            // Web: thêm nút "Chọn nhiều" để khỏi cần long-press.
            if (kIsWeb && staff && !_selectMode)
              IconButton(
                icon: const Icon(Icons.checklist_rounded),
                tooltip: t.bookListLongPressHint,
                onPressed: () {
                  setState(() {
                    _selectMode = true;
                    _selectedIds.clear();
                  });
                },
              ),
            if (staff && _selectMode && _selectedIds.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.image_outlined),
                tooltip: t.bookListBulkReplaceCover(_selectedIds.length),
                onPressed: _bulkListInteractionLocked
                    ? null
                    : () => _confirmBulkReplaceCover(t),
              ),
              IconButton(
                icon: const Icon(Icons.collections_outlined),
                tooltip: t.bookListBulkReplaceCoverPerBook,
                onPressed: _bulkListInteractionLocked
                    ? null
                    : () => _openPerBookCoverPicker(t),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                tooltip: t.bookListBulkDelete(_selectedIds.length),
                onPressed: _bulkListInteractionLocked
                    ? null
                    : () => _confirmBulkDelete(t),
              ),
            ],
            if (!_selectMode) ...[
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                tooltip: _isGridView ? t.viewAsList : t.viewAsGrid,
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
              PopupMenuButton<BookSortKey>(
                icon: const Icon(Icons.sort),
                tooltip: t.sort,
                initialValue: _sortKey,
                onSelected: (v) async {
                  if (_sortKey == v) return;
                  setState(() => _sortKey = v);
                  await _controller.setQuery(_buildQuery());
                },
                itemBuilder: (context) => BookSortKey.values
                    .map(
                      (k) => PopupMenuItem<BookSortKey>(
                        value: k,
                        child: Text(k.label(t)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        body: Builder(
          builder: (context) {
            return Consumer<BookListController>(
              builder: (context, ctrl, _) {
                final s = ctrl.state;
                if (s.error != null && s.docs.isEmpty) {
                  return Center(child: Text(t.cannotLoadList('${s.error}')));
                }

                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: _categoriesFuture,
                  builder: (context, catSnap) {
                    final categoryRows = _categoryRowsOnce(catSnap.data, t);
                    final keys = categoryRows.map((e) => e.$1).toList();
                    if (!keys.contains(_selectedCategoryKey)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _selectedCategoryKey = _kAllCategories);
                        _controller.setQuery(_buildQuery());
                      });
                    }

                    final docs = s.docs;
                    final totalBooks = s.totalQuantityInLoaded;
                    final totalAvailable = s.totalAvailableInLoaded;
                    final totalBorrowed = totalBooks - totalAvailable;

                    final showSkeleton = s.loadingFirstPage && docs.isEmpty;

                    return Stack(
                      children: [
                        AbsorbPointer(
                          absorbing: _bulkListInteractionLocked,
                          child: CustomScrollView(
                            controller: _scrollController,
                            cacheExtent: 1400,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    10,
                                    16,
                                    0,
                                  ),
                                  child: _StatsStrip(
                                    theme: theme,
                                    t: t,
                                    totalBooks: totalBooks,
                                    totalAvailable: totalAvailable,
                                    totalBorrowed: totalBorrowed,
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: _buildSearchFilters(
                                  theme,
                                  categoryRows,
                                  shownCount: docs.length,
                                  loading: s.loadingFirstPage,
                                ),
                              ),
                              if (staff && _selectMode && docs.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      2,
                                      12,
                                      2,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Wrap(
                                        alignment: WrapAlignment.end,
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                            ),
                                            onPressed:
                                                _bulkListInteractionLocked
                                                ? null
                                                : () {
                                                    setState(() {
                                                      for (final d in docs) {
                                                        _selectedIds.add(d.id);
                                                      }
                                                    });
                                                  },
                                            icon: const Icon(
                                              Icons.select_all,
                                              size: 18,
                                            ),
                                            label: Text(
                                              t.bookListSelectAllVisible,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                            ),
                                            onPressed:
                                                (_bulkListInteractionLocked ||
                                                    !docs.any(
                                                      (d) => _selectedIds
                                                          .contains(d.id),
                                                    ))
                                                ? null
                                                : () {
                                                    setState(() {
                                                      for (final d in docs) {
                                                        _selectedIds.remove(
                                                          d.id,
                                                        );
                                                      }
                                                    });
                                                  },
                                            icon: const Icon(
                                              Icons.deselect,
                                              size: 18,
                                            ),
                                            label: Text(
                                              t.bookListDeselectAllVisible,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 4),
                              ),
                              if (showSkeleton)
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    80,
                                  ),
                                  sliver: _isGridView
                                      ? const _BookGridSkeletonSliver()
                                      : const _BookListSkeletonSliver(),
                                )
                              else if (docs.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      docs.isEmpty
                                          ? t.bookListEmptyLibrary
                                          : t.noBooksMatchFilters,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else if (_isGridView)
                                SliverLayoutBuilder(
                                  builder: (context, constraints) {
                                    final w = constraints.crossAxisExtent;
                                    final count = (w / 160).floor().clamp(2, 6);
                                    const ratio = 0.62;
                                    return SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        80,
                                      ),
                                      sliver: SliverGrid(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: count,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10,
                                              childAspectRatio: ratio,
                                            ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) => _buildGridCard(
                                            _BookItem.fromDoc(docs[index]),
                                            theme,
                                          ),
                                          childCount: docs.length,
                                          addAutomaticKeepAlives: false,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    80,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildListRow(
                                        _BookItem.fromDoc(docs[index]),
                                        theme,
                                      ),
                                      childCount: docs.length,
                                      addAutomaticKeepAlives: false,
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    24,
                                  ),
                                  child: s.loadingNextPage
                                      ? const _LoadMoreSkeleton()
                                      : (!s.hasMore
                                            ? const SizedBox.shrink()
                                            : Center(
                                                child: OutlinedButton.icon(
                                                  onPressed: ctrl.fetchMore,
                                                  icon: const Icon(
                                                    Icons.expand_more,
                                                  ),
                                                  label: Text(t.loadMore),
                                                ),
                                              )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_bulkDeleting || _bulkCoverBusy)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Color(0x33000000),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: !_selectMode
            ? FloatingActionButton.small(
                onPressed: () => _pushBooksRouteThenRefresh(AppRoutes.addBook),
                tooltip: t.addBook,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchFilters(
    ThemeData theme,
    List<(String, String)> categoryRows, {
    required int shownCount,
    required bool loading,
  }) {
    final t = AppLocalizations.of(context)!;
    final q = _searchController.text.trim();
    final hasSearch = q.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('search_input_field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: AppTextStyles.body.copyWith(fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              hintText: t.searchBooksHint,
              hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
              prefixIcon: Icon(
                Icons.search,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 40,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.85),
                  width: 1.5,
                ),
              ),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
          if (hasSearch && shownCount >= 0 && !loading) ...[
            const SizedBox(height: 6),
            Text(
              t.bookListMatchesCount(shownCount),
              style: AppTextStyles.small.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoryRows.map((row) {
                final key = row.$1;
                final label = row.$2;
                final selected = _selectedCategoryKey == key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(label, style: const TextStyle(fontSize: 12.5)),
                    selected: selected,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategoryKey = key);
                      _controller.setQuery(_buildQuery());
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.sortByLabel(_sortKey.label(t)),
            style: AppTextStyles.small.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (AppUser.isStaff && !_selectMode) ...[
            const SizedBox(height: 4),
            Text(
              t.bookListLongPressHint,
              style: AppTextStyles.small.copyWith(
                fontSize: 11.5,
                height: 1.25,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.85,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListRow(_BookItem book, ThemeData theme) {
    final t = AppLocalizations.of(context)!;
    final staff = AppUser.isStaff;
    final sel = _selectMode && staff;
    final checked = _selectedIds.contains(book.id);

    return RepaintBoundary(
      child: Card(
        key: ValueKey(book.id),
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: checked && sel
                ? AppColors.primary.withValues(alpha: 0.85)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: checked && sel ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: sel
              ? () {
                  if (_bulkListInteractionLocked) return;
                  setState(() {
                    if (checked) {
                      _selectedIds.remove(book.id);
                    } else {
                      _selectedIds.add(book.id);
                    }
                  });
                }
              : () => _pushBooksRouteThenRefresh(
                  AppRoutes.bookDetail,
                  arguments: _bookToMap(book),
                ),
          onLongPress: staff ? () => _onBookLongPress(book) : null,
          child: SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sel)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Checkbox(
                      value: checked,
                      onChanged: _bulkListInteractionLocked
                          ? null
                          : (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedIds.add(book.id);
                                } else {
                                  _selectedIds.remove(book.id);
                                }
                              });
                            },
                    ),
                  ),
                SizedBox(
                  width: 96,
                  child: RepaintBoundary(
                    child: buildBookCoverDisplay(
                      imageRef: buildCloudinaryThumbUrl(
                        book.imageUrl,
                        width: 96,
                        height: 130,
                      ),
                      width: 96,
                      height: 130,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: AppTextStyles.caption.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                displayBookCategory(t, book.category),
                                style: AppTextStyles.small.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  t.isbnLabel(
                                    book.isbn,
                                    book.available,
                                    book.quantity,
                                  ),
                                  style: AppTextStyles.small.copyWith(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: book.available > 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!sel)
                  Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _pushBooksRouteThenRefresh(
                            AppRoutes.editBook,
                            arguments: _bookToMap(book),
                          );
                        }
                        if (v == 'detail') {
                          _pushBooksRouteThenRefresh(
                            AppRoutes.bookDetail,
                            arguments: _bookToMap(book),
                          );
                        }
                        if (v == 'delete' && staff) {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(t.deleteConfirmTitle),
                              content: Text(t.deleteConfirmBookBody),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(t.commonCancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(t.deleteAction),
                                ),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          try {
                            await __firebaseDelete(book.id, t);
                          } catch (e) {
                            __firebaseError(e, t);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'detail',
                          child: Text(t.viewDetails),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(t.updateAction),
                        ),
                        if (staff)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              t.commonDelete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> __firebaseDelete(String id, AppLocalizations t) async {
    await FirebaseFirestore.instance.collection('books').doc(id).delete();
    await _controller.refresh();
    if (mounted) {
      setState(() => _selectedIds.remove(id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.deletedBookToast)));
    }
  }

  void __firebaseError(dynamic e, AppLocalizations t) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.deleteBookError('$e'))));
    }
  }

  Widget _buildGridCard(_BookItem book, ThemeData theme) {
    final t = AppLocalizations.of(context)!;
    final staff = AppUser.isStaff;
    final sel = _selectMode && staff;
    final checked = _selectedIds.contains(book.id);

    return RepaintBoundary(
      child: Card(
        key: ValueKey('grid_${book.id}'),
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: checked && sel
                ? AppColors.primary.withValues(alpha: 0.85)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: checked && sel ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              onTap: sel
                  ? () {
                      if (_bulkListInteractionLocked) return;
                      setState(() {
                        if (checked) {
                          _selectedIds.remove(book.id);
                        } else {
                          _selectedIds.add(book.id);
                        }
                      });
                    }
                  : () => _pushBooksRouteThenRefresh(
                      AppRoutes.bookDetail,
                      arguments: _bookToMap(book),
                    ),
              onLongPress: staff ? () => _onBookLongPress(book) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RepaintBoundary(
                          child: buildBookCoverDisplay(
                            imageRef: buildCloudinaryThumbUrl(
                              book.imageUrl,
                              width: 160,
                              height: 260,
                            ),
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                        ),
                        if (book.available <= 0)
                          Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.outbox_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 98,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 14,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.author,
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      displayBookCategory(t, book.category),
                                      style: AppTextStyles.small.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${book.available}/${book.quantity}',
                                    style: AppTextStyles.small.copyWith(
                                      color: book.available > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (sel)
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: theme.colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Checkbox(
                      value: checked,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: _bulkListInteractionLocked
                          ? null
                          : (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedIds.add(book.id);
                                } else {
                                  _selectedIds.remove(book.id);
                                }
                              });
                            },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _bookToMap(_BookItem book) => {
    'id': book.id,
    'title': book.title,
    'author': book.author,
    'category': book.category,
    'isbn': book.isbn,
    'quantity': book.quantity,
    'available': book.available,
    'description': book.description,
    if (book.publishedYear != null) 'publishedYear': book.publishedYear,
    if (book.authorId != null) 'authorId': book.authorId,
    if (book.genreId != null) 'genreId': book.genreId,
    // Tránh truyền data URL quá lớn qua Navigator; màn chi tiết/sửa sẽ tải lại từ Firestore.
    if (book.imageUrl.isNotEmpty && !book.imageUrl.startsWith('data:image'))
      'imageUrl': book.imageUrl,
  };
}

class _LoadMoreSkeleton extends StatelessWidget {
  const _LoadMoreSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SkBox(
            width: 22,
            height: 22,
            radius: 999,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(width: 10),
          _SkBox(
            width: 140,
            height: 14,
            radius: 999,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

class _BookListSkeletonSliver extends StatelessWidget {
  const _BookListSkeletonSliver();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _BookRowSkeleton(),
        ),
        childCount: 10,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

class _BookGridSkeletonSliver extends StatelessWidget {
  const _BookGridSkeletonSliver();

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.62,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const _BookCardSkeleton(),
        childCount: 12,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

class _BookRowSkeleton extends StatelessWidget {
  const _BookRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: Row(
          children: [
            _SkBox(
              width: 96,
              height: 130,
              radius: 0,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkBox(
                      width: double.infinity,
                      height: 14,
                      radius: 6,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 8),
                    _SkBox(
                      width: 180,
                      height: 12,
                      radius: 6,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _SkBox(
                          width: 86,
                          height: 18,
                          radius: 8,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        const Spacer(),
                        _SkBox(
                          width: 90,
                          height: 12,
                          radius: 8,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCardSkeleton extends StatelessWidget {
  const _BookCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SkBox(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkBox(
                    width: double.infinity,
                    height: 12,
                    radius: 6,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 6),
                  _SkBox(
                    width: 120,
                    height: 11,
                    radius: 6,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _SkBox(
                        width: 70,
                        height: 16,
                        radius: 6,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      const Spacer(),
                      _SkBox(
                        width: 44,
                        height: 12,
                        radius: 6,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;
  const _SkBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Thanh số liệu: luôn ba ô trên một hàng; thu nhỏ chữ/padding khi màn hẹp.
class _StatsStrip extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations t;
  final int totalBooks;
  final int totalAvailable;
  final int totalBorrowed;

  const _StatsStrip({
    required this.theme,
    required this.t,
    required this.totalBooks,
    required this.totalAvailable,
    required this.totalBorrowed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 520;
        final gap = compact ? 6.0 : 10.0;
        return Row(
          children: [
            Expanded(
              child: _StatPill(
                label: t.bookStatTotalBooks,
                value: '$totalBooks',
                color: AppColors.primary,
                compact: compact,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StatPill(
                label: t.bookStatAvailable,
                value: '$totalAvailable',
                color: AppColors.success,
                compact: compact,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StatPill(
                label: t.bookStatBorrowed,
                value: '$totalBorrowed',
                color: AppColors.secondary,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool compact;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueSize = compact ? 16.0 : 20.0;
    final labelStyle = AppTextStyles.small.copyWith(
      color: theme.hintColor,
      fontSize: compact ? 10 : 11,
      height: 1.15,
    );
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: color,
            fontSize: valueSize,
            height: 1.05,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: labelStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 11,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: compact ? 28 : 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(child: textColumn),
        ],
      ),
    );
  }
}

String? _stringIdFromFirestore(dynamic v) {
  if (v == null) return null;
  if (v is String && v.isNotEmpty) return v;
  if (v is DocumentReference) return v.id;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

class _BookItem {
  final String id, title, author, category, isbn;
  final String description;
  final String imageUrl;
  final int? publishedYear;
  final int quantity, available;
  final DateTime? createdAt;
  final String? authorId;
  final String? genreId;
  _BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    required this.description,
    required this.imageUrl,
    required this.publishedYear,
    required this.quantity,
    required this.available,
    required this.createdAt,
    this.authorId,
    this.genreId,
  });

  factory _BookItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final quantity = (data['quantity'] ?? 0) as int;
    final available =
        (data['availableQuantity'] ?? data['available'] ?? quantity) as int;
    final py = data['publishedYear'];
    int? publishedYear;
    if (py is int) {
      publishedYear = py;
    } else if (py is double) {
      publishedYear = py.toInt();
    } else {
      publishedYear = int.tryParse(py?.toString() ?? '');
    }
    return _BookItem(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      category:
          (data['category'] ?? data['categoryId'] ?? kDefaultBookCategory)
              as String,
      isbn: (data['isbn'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      publishedYear: publishedYear,
      quantity: quantity,
      available: available,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      authorId: _stringIdFromFirestore(data['authorId']),
      genreId: _stringIdFromFirestore(data['genreId']),
    );
  }
}

class _PerBookCoverPickerSheet extends StatefulWidget {
  final List<String> selectedIds;
  final Map<String, _BookItem> initialById;
  final int maxBytes;

  const _PerBookCoverPickerSheet({
    required this.selectedIds,
    required this.initialById,
    required this.maxBytes,
  });

  @override
  State<_PerBookCoverPickerSheet> createState() =>
      _PerBookCoverPickerSheetState();
}

class _PerBookCoverPickerSheetState extends State<_PerBookCoverPickerSheet> {
  final Map<String, bool> _busy = <String, bool>{};
  final Map<String, String> _url = <String, String>{};

  @override
  void initState() {
    super.initState();
    for (final e in widget.initialById.entries) {
      _url[e.key] = e.value.imageUrl;
    }
  }

  Future<({Uint8List bytes, String filename})?> _pickOneCoverImageFile() async {
    if (kIsWeb) {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (pick == null || pick.files.isEmpty) return null;
      final f = pick.files.single;
      final bytes = f.bytes;
      if (bytes == null) return null;
      final name = (f.name).trim().isEmpty ? 'cover.jpg' : f.name.trim();
      return (bytes: bytes, filename: name);
    }
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      maxHeight: 1080,
      imageQuality: 68,
    );
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    final name = x.name.trim().isEmpty ? 'cover.jpg' : x.name.trim();
    return (bytes: bytes, filename: name);
  }

  Future<_BookItem?> _loadBook(String id) async {
    final snap = await FirebaseFirestore.instance
        .collection('books')
        .doc(id)
        .get();
    if (!snap.exists) return null;
    final data = snap.data() ?? <String, dynamic>{};
    final quantity = (data['quantity'] ?? 0) as int;
    final available =
        (data['availableQuantity'] ?? data['available'] ?? quantity) as int;
    final py = data['publishedYear'];
    int? publishedYear;
    if (py is int) {
      publishedYear = py;
    } else if (py is double) {
      publishedYear = py.toInt();
    } else {
      publishedYear = int.tryParse(py?.toString() ?? '');
    }
    return _BookItem(
      id: id,
      title: (data['title'] ?? '').toString(),
      author: (data['author'] ?? '').toString(),
      category: (data['category'] ?? data['categoryId'] ?? kDefaultBookCategory)
          .toString(),
      isbn: (data['isbn'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      publishedYear: publishedYear,
      quantity: quantity,
      available: available,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      authorId: _stringIdFromFirestore(data['authorId']),
      genreId: _stringIdFromFirestore(data['genreId']),
    );
  }

  Future<void> _pickUploadAndUpdate(String id) async {
    final t = AppLocalizations.of(context)!;
    if (_busy[id] == true) return;
    setState(() => _busy[id] = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _pickOneCoverImageFile();
      if (picked == null || !mounted) return;
      if (picked.bytes.length > widget.maxBytes) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.bookCoverImageTooLarge)),
        );
        return;
      }
      final url = await CloudinaryService.uploadBookCoverBytes(
        bytes: picked.bytes,
        filename: picked.filename,
      );
      await FirebaseFirestore.instance.collection('books').doc(id).update({
        'imageUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() => _url[id] = url);
      messenger.showSnackBar(
        SnackBar(content: Text(t.bookListBulkReplaceCoverPicked)),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.bookListBulkReplaceCoverError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy[id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.bookListBulkReplaceCoverPerBookTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.bookListBulkReplaceCoverPerBookHint,
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  itemCount: widget.selectedIds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final id = widget.selectedIds[index];
                    final pre = widget.initialById[id];
                    if (pre != null) {
                      return _PerBookRow(
                        id: id,
                        title: pre.title,
                        author: pre.author,
                        imageUrl: _url[id] ?? pre.imageUrl,
                        busy: _busy[id] == true,
                        onPick: () => _pickUploadAndUpdate(id),
                      );
                    }
                    return FutureBuilder<_BookItem?>(
                      future: _loadBook(id),
                      builder: (context, snap) {
                        final d = snap.data;
                        return _PerBookRow(
                          id: id,
                          title: d?.title ?? id,
                          author: d?.author ?? '',
                          imageUrl: _url[id] ?? (d?.imageUrl ?? ''),
                          busy: _busy[id] == true,
                          onPick: () => _pickUploadAndUpdate(id),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.commonClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerBookRow extends StatelessWidget {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final bool busy;
  final VoidCallback onPick;

  const _PerBookRow({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.busy,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 54,
                height: 72,
                child: buildBookCoverDisplay(
                  imageRef: buildCloudinaryThumbUrl(
                    imageUrl,
                    width: 120,
                    height: 160,
                  ),
                  width: 54,
                  height: 72,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? id : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 14),
                  ),
                  if (author.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: busy ? null : onPick,
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.bookListBulkReplaceCoverPick),
            ),
          ],
        ),
      ),
    );
  }
}

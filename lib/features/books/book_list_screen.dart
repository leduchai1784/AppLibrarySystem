import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/l10n/book_category_display.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/book_cover_display.dart';
import '../../core/utils/fold_search_text.dart';
import '../../gen/l10n/app_localizations.dart';

import 'dart:async';

enum _BookSortKey { title, author, category, available, created }

extension _BookSortKeyX on _BookSortKey {
  String label(AppLocalizations t) {
    switch (this) {
      case _BookSortKey.title:
        return t.sortOptionTitle;
      case _BookSortKey.author:
        return t.sortOptionAuthor;
      case _BookSortKey.category:
        return t.sortOptionCategory;
      case _BookSortKey.available:
        return t.sortOptionStock;
      case _BookSortKey.created:
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
  final _searchController = TextEditingController();
  static const String _kAllCategories = '__ALL__';
  String _selectedCategoryKey = _kAllCategories;
  bool _isGridView = true;
  _BookSortKey _sortKey = _BookSortKey.title;

  /// Chọn nhiều để xóa (chỉ nhân sự).
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _bulkDeleting = false;

  /// Giữ cùng một tham chiếu stream — nếu tạo `.snapshots()` mỗi lần build, StreamBuilder đăng ký lại và bị loading liên tục khi setState (chọn sách).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _categoriesStream;
  static const int _pageSize = 40;
  final ScrollController _scrollController = ScrollController();
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _loadedDocs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _isLoadingPage = false;
  bool _hasMore = true;
  Object? _booksError;

  Timer? _searchDebounce;
  String _searchText = '';

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      final next = _searchController.text;
      if (!mounted) return;
      if (next == _searchText) return;
      setState(() => _searchText = next);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _categoriesStream = FirebaseFirestore.instance
        .collection('categories')
        .snapshots();
    _scrollController.addListener(_onScroll);
    // tải trang đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshBooks();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>> _baseBooksQuery() {
    final col = FirebaseFirestore.instance.collection('books');
    switch (_sortKey) {
      case _BookSortKey.created:
        return col.orderBy('createdAt', descending: true);
      case _BookSortKey.author:
        // field author có trong schema (denormalized)
        return col.orderBy('author');
      case _BookSortKey.category:
        return col.orderBy('category');
      case _BookSortKey.available:
        // ưu tiên availableQuantity nếu có
        return col.orderBy('availableQuantity', descending: true);
      case _BookSortKey.title:
        return col.orderBy('title');
    }
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _loadedDocs.clear();
      _lastDoc = null;
      _hasMore = true;
      _booksError = null;
    });
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingPage || !_hasMore) return;
    setState(() => _isLoadingPage = true);
    try {
      Query<Map<String, dynamic>> q = _baseBooksQuery().limit(_pageSize);
      if (_lastDoc != null) {
        q = q.startAfterDocument(_lastDoc!);
      }
      final snap = await q.get();
      if (!mounted) return;
      if (snap.docs.isNotEmpty) {
        _loadedDocs.addAll(snap.docs);
        _lastDoc = snap.docs.last;
      }
      if (snap.docs.length < _pageSize) {
        _hasMore = false;
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _booksError = e);
    } finally {
      if (mounted) setState(() => _isLoadingPage = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    // tải thêm khi gần cuối
    if (pos.pixels >= pos.maxScrollExtent - 520) {
      _fetchNextPage();
    }
  }

  /// Chip lọc: hợp **realtime** tên trong `categories` và giá trị `category` đang có trên sách — không dùng danh mục demo cố định.
  List<(String key, String label)> _categoryRowsMerged(
    QuerySnapshot<Map<String, dynamic>>? catSnap,
    List<_BookItem> allBooks,
    AppLocalizations t,
  ) {
    final names = <String>{};
    if (catSnap != null) {
      for (final d in catSnap.docs) {
        final n = d.data()['name'] as String?;
        if (n != null && n.trim().isNotEmpty) names.add(n.trim());
      }
    }
    for (final b in allBooks) {
      final c = b.category.trim();
      if (c.isNotEmpty) names.add(c);
    }
    final sorted = names.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [(_kAllCategories, t.categoryAll), ...sorted.map((n) => (n, n))];
  }

  String _bookSearchHaystack(_BookItem b) {
    final parts = <String>[
      b.title,
      b.author,
      b.isbn,
      b.category,
      b.description,
      if (b.publishedYear != null) '${b.publishedYear}',
    ];
    return foldSearchText(parts.join(' '));
  }

  bool _bookMatchesSearch(_BookItem b, List<String> tokens) {
    if (tokens.isEmpty) return true;
    final hay = _bookSearchHaystack(b);
    for (final t in tokens) {
      if (!hay.contains(t)) return false;
    }
    return true;
  }

  List<_BookItem> _filterAndSort(List<_BookItem> raw) {
    var books = List<_BookItem>.from(raw);
    if (_selectedCategoryKey != _kAllCategories) {
      books = books.where((b) => b.category == _selectedCategoryKey).toList();
    }
    final tokens = searchTokens(_searchText);
    if (tokens.isNotEmpty) {
      books = books.where((b) => _bookMatchesSearch(b, tokens)).toList();
    }
    books.sort((a, b) {
      switch (_sortKey) {
        case _BookSortKey.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case _BookSortKey.author:
          return a.author.toLowerCase().compareTo(b.author.toLowerCase());
        case _BookSortKey.category:
          return a.category.toLowerCase().compareTo(b.category.toLowerCase());
        case _BookSortKey.available:
          return b.available.compareTo(a.available);
        case _BookSortKey.created:
          final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
      }
    });
    return books;
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  /// Nhấn giữ để bật chọn nhiều và chọn/bỏ cuốn đang giữ (nhân sự).
  void _onBookLongPress(_BookItem book) {
    if (!AppUser.isStaff || _bulkDeleting) return;
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

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _categoriesStream,
      builder: (context, catSnap) {
        final staff = AppUser.isStaff;
        return Scaffold(
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
              if (staff && _selectMode && _selectedIds.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: t.bookListBulkDelete(_selectedIds.length),
                  onPressed: _bulkDeleting ? null : () => _confirmBulkDelete(t),
                ),
              if (!_selectMode) ...[
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  tooltip: _isGridView ? t.viewAsList : t.viewAsGrid,
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
                PopupMenuButton<_BookSortKey>(
                  icon: const Icon(Icons.sort),
                  tooltip: t.sort,
                  initialValue: _sortKey,
                  onSelected: (v) async {
                    if (_sortKey == v) return;
                    setState(() => _sortKey = v);
                    await _refreshBooks();
                  },
                  itemBuilder: (context) => _BookSortKey.values
                      .map(
                        (k) => PopupMenuItem<_BookSortKey>(
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
              if (_booksError != null && _loadedDocs.isEmpty) {
                return Center(child: Text(t.cannotLoadList('$_booksError')));
              }
              if (_loadedDocs.isEmpty && _isLoadingPage) {
                return const Center(child: CircularProgressIndicator());
              }

              final allRaw = _loadedDocs.map(_BookItem.fromDoc).toList();
              final categoryRows = _categoryRowsMerged(catSnap.data, allRaw, t);
              final keys = categoryRows.map((e) => e.$1).toList();
              if (!keys.contains(_selectedCategoryKey)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _selectedCategoryKey = _kAllCategories);
                });
              }

              final books = _filterAndSort(allRaw);

              final totalBooks = allRaw.fold<int>(0, (s, b) => s + b.quantity);
              final totalAvailable = allRaw.fold<int>(
                0,
                (s, b) => s + b.available,
              );
              final totalBorrowed = totalBooks - totalAvailable;

              return Stack(
                children: [
                  AbsorbPointer(
                    absorbing: _bulkDeleting,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                            filteredCount: books.length,
                            totalDocCount: allRaw.length,
                          ),
                        ),
                        if (staff && _selectMode && books.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 2, 12, 2),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      onPressed: _bulkDeleting
                                          ? null
                                          : () {
                                              setState(() {
                                                for (final b in books) {
                                                  _selectedIds.add(b.id);
                                                }
                                              });
                                            },
                                      icon: const Icon(
                                        Icons.select_all,
                                        size: 18,
                                      ),
                                      label: Text(
                                        t.bookListSelectAllVisible,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      onPressed:
                                          (_bulkDeleting ||
                                              !books.any(
                                                (b) =>
                                                    _selectedIds.contains(b.id),
                                              ))
                                          ? null
                                          : () {
                                              setState(() {
                                                for (final b in books) {
                                                  _selectedIds.remove(b.id);
                                                }
                                              });
                                            },
                                      icon: const Icon(
                                        Icons.deselect,
                                        size: 18,
                                      ),
                                      label: Text(
                                        t.bookListDeselectAllVisible,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 4)),
                        if (books.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                allRaw.isEmpty
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
                                    (context, index) =>
                                        _buildGridCard(books[index], theme),
                                    childCount: books.length,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildListRow(books[index], theme),
                                childCount: books.length,
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: _isLoadingPage
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 18),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : (!_hasMore
                                    ? const SizedBox.shrink()
                                    : Center(
                                        child: OutlinedButton.icon(
                                          onPressed: _fetchNextPage,
                                          icon: const Icon(Icons.expand_more),
                                          label: Text(t.loadMore),
                                        ),
                                      )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_bulkDeleting)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x33000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            },
          ),
          floatingActionButton: !_selectMode
              ? FloatingActionButton.small(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addBook),
                  tooltip: t.addBook,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSearchFilters(
    ThemeData theme,
    List<(String, String)> categoryRows, {
    required int filteredCount,
    required int totalDocCount,
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
          if (hasSearch && totalDocCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              t.bookListMatchesCount(filteredCount),
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
                    onSelected: (_) =>
                        setState(() => _selectedCategoryKey = key),
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

    return Card(
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
                if (_bulkDeleting) return;
                setState(() {
                  if (checked) {
                    _selectedIds.remove(book.id);
                  } else {
                    _selectedIds.add(book.id);
                  }
                });
              }
            : () => Navigator.pushNamed(
                context,
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
                    onChanged: _bulkDeleting
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
                    imageRef: book.imageUrl,
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
                                  color: book.available > 0 ? AppColors.success : AppColors.error,
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
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editBook,
                          arguments: _bookToMap(book),
                        );
                      }
                      if (v == 'detail') {
                        Navigator.pushNamed(
                          context,
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
                      PopupMenuItem(value: 'edit', child: Text(t.updateAction)),
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
    );
  }

  Future<void> __firebaseDelete(String id, AppLocalizations t) async {
    await FirebaseFirestore.instance.collection('books').doc(id).delete();
    if (mounted) {
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

    return Card(
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
                    if (_bulkDeleting) return;
                    setState(() {
                      if (checked) {
                        _selectedIds.remove(book.id);
                      } else {
                        _selectedIds.add(book.id);
                      }
                    });
                  }
                : () => Navigator.pushNamed(
                    context,
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
                          imageRef: book.imageUrl,
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
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
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
                    onChanged: _bulkDeleting
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
    // Tránh truyền data URL quá lớn qua Navigator; màn sửa sẽ tải lại từ Firestore.
    if (book.imageUrl.isNotEmpty &&
        (book.imageUrl.startsWith('http://') ||
            book.imageUrl.startsWith('https://') ||
            book.imageUrl.length < 100000))
      'imageUrl': book.imageUrl,
  };
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

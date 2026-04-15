import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/book_cover_display.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../services/book_excel_import_service.dart';
import '../../services/book_excel_sample_template.dart';
import '../../services/category_ensure_service.dart';

/// Màn hình thêm / cập nhật sách (Admin) - giao diện hoàn chỉnh
class AddEditBookScreen extends StatefulWidget {
  const AddEditBookScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  static const int _kMaxCoverRawBytes = 330000;
  static const int _kMaxDataUrlChars = 900000;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  final _imageUrlTextController = TextEditingController();
  String _selectedCategory = 'Công nghệ';

  /// Ảnh nhúng base64 (data URL) — không dùng Firebase Storage.
  String? _coverDataUrl;

  /// `null` = nhập tay / không liên kết document `authors`.
  String? _linkedAuthorId;
  String? _selectedGenreId;
  String? _lastSyncedAuthorName;
  static const String _kManualAuthor = '__manual__';

  List<(String value, String label)> _demoCategoryChoices(AppLocalizations t) => [
        ('Công nghệ', t.demoCategoryTech),
        ('Kinh tế', t.demoCategoryEcon),
        ('Văn học', t.demoCategoryLit),
        ('Khoa học', t.demoCategorySci),
        ('Lịch sử', t.demoCategoryHist),
        ('Giáo dục', t.demoCategoryEdu),
      ];
  String? _docId;
  bool _initializedFromArgs = false;
  bool _coverHydrateScheduled = false;

  /// Nhập hàng loạt từ Excel (chỉ chế độ thêm mới).
  String? _excelFileName;
  List<Map<String, dynamic>>? _excelParsedBooks;
  final List<String> _excelParseMessages = [];
  bool _excelWorking = false;

  @override
  void initState() {
    super.initState();
    _imageUrlTextController.addListener(_onCoverInputsChanged);
  }

  void _onCoverInputsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _imageUrlTextController.removeListener(_onCoverInputsChanged);
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _imageUrlTextController.dispose();
    super.dispose();
  }

  String _effectiveCoverForPreview() {
    final link = _imageUrlTextController.text.trim();
    if (link.startsWith('http://') || link.startsWith('https://')) return link;
    return _coverDataUrl ?? '';
  }

  String _effectiveImageUrlForSubmit() {
    final link = _imageUrlTextController.text.trim();
    if (link.startsWith('http://') || link.startsWith('https://')) return link;
    return (_coverDataUrl ?? '').trim();
  }

  String _mimeFromFileName(String name) {
    final p = name.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _pickCoverImage() async {
    final t = AppLocalizations.of(context)!;
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      maxHeight: 1080,
      imageQuality: 68,
    );
    if (!mounted || x == null) return;
    try {
      final bytes = await x.readAsBytes();
      if (bytes.length > _kMaxCoverRawBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.bookCoverImageTooLarge)));
        }
        return;
      }
      final mime = (x.mimeType != null && x.mimeType!.startsWith('image/')) ? x.mimeType! : _mimeFromFileName(x.name);
      final b64 = base64Encode(bytes);
      final dataUrl = 'data:$mime;base64,$b64';
      if (dataUrl.length > _kMaxDataUrlChars) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.bookCoverDataUrlTooLong)));
        }
        return;
      }
      setState(() {
        _coverDataUrl = dataUrl;
        _imageUrlTextController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.saveBookError('$e'))));
      }
    }
  }

  void _clearCoverImage() {
    setState(() {
      _coverDataUrl = null;
      _imageUrlTextController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Lấy dữ liệu chuyển từ màn hình danh sách / chi tiết sang khi ở chế độ sửa
    if (widget.isEdit && !_initializedFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : null;
      if (map != null) {
        _docId = map['id'] as String?;
        _titleController.text = map['title']?.toString() ?? '';
        _authorController.text = map['author']?.toString() ?? '';
        final aid = map['authorId']?.toString();
        _linkedAuthorId = (aid != null && aid.isNotEmpty) ? aid : null;
        final gid = map['genreId']?.toString();
        _selectedGenreId = (gid != null && gid.isNotEmpty) ? gid : null;
        _lastSyncedAuthorName =
            _linkedAuthorId != null ? _authorController.text.trim() : null;
        _selectedCategory = map['category']?.toString() ?? _selectedCategory;
        _isbnController.text = map['isbn']?.toString() ?? '';
        _quantityController.text = map['quantity']?.toString() ?? '1';
        _descriptionController.text = map['description']?.toString() ?? '';
        final img = map['imageUrl']?.toString() ?? '';
        if (img.startsWith('data:image')) {
          _coverDataUrl = img;
          _imageUrlTextController.clear();
        } else if (img.startsWith('http://') || img.startsWith('https://')) {
          _coverDataUrl = null;
          _imageUrlTextController.text = img;
        } else {
          _coverDataUrl = null;
          _imageUrlTextController.clear();
        }
      }
      _initializedFromArgs = true;
    }

    if (widget.isEdit && _initializedFromArgs && !_coverHydrateScheduled && _docId != null) {
      _coverHydrateScheduled = true;
      final hasLocalCover =
          (_coverDataUrl ?? '').isNotEmpty || _imageUrlTextController.text.trim().isNotEmpty;
      if (!hasLocalCover) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final id = _docId;
          if (!mounted || id == null || id.isEmpty) return;
          try {
            final snap = await FirebaseFirestore.instance.collection('books').doc(id).get();
            if (!mounted || !snap.exists) return;
            final u = snap.data()?['imageUrl']?.toString() ?? '';
            if (u.isEmpty) return;
            setState(() {
              if (u.startsWith('data:image')) {
                _coverDataUrl = u;
              } else if (u.startsWith('http://') || u.startsWith('https://')) {
                _imageUrlTextController.text = u;
              }
            });
          } catch (_) {}
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? t.editBookTitle : t.addBookTitle),
        actions: [
          if (widget.isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirm(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isEdit) ...[
                _SectionTitle(title: t.excelImportTitle, icon: Icons.table_chart_outlined),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.excelImportFormatHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _excelWorking ? null : _shareVietnameseExcelTemplate,
                            icon: const Icon(Icons.table_view_outlined, size: 20),
                            label: Text(t.downloadExcelTemplate),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_excelWorking) const LinearProgressIndicator(),
                        if (_excelWorking) const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _excelWorking ? null : _pickExcelFile,
                                icon: const Icon(Icons.upload_file_outlined),
                                label: Text(t.pickXlsx),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: (_excelWorking ||
                                        _excelParsedBooks == null ||
                                        _excelParsedBooks!.isEmpty)
                                    ? null
                                    : _importExcelToFirestore,
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: Text(
                                  _excelParsedBooks == null
                                      ? t.importInventory
                                      : t.importNBooks(_excelParsedBooks!.length),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_excelFileName != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            t.excelSelectedFile(_excelFileName!),
                            style: AppTextStyles.caption,
                          ),
                        ],
                        if (_excelParseMessages.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            t.excelNotesErrors,
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ..._excelParseMessages.take(12).map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('• $m', style: Theme.of(context).textTheme.bodySmall),
                                ),
                              ),
                          if (_excelParseMessages.length > 12)
                            Text(
                              t.excelAndMoreLines(_excelParseMessages.length - 12),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        t.orEnterSingleBook,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              // Thông tin cơ bản
              _SectionTitle(title: t.bookBasicInfoSection, icon: Icons.info_outline),
              const SizedBox(height: 12),
              _buildTextField(
                label: t.bookTitleLabel,
                hint: t.bookTitleHint,
                controller: _titleController,
                prefixIcon: Icons.menu_book,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildAuthorSection(context, t, theme),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snap) {
                  final names = snap.data?.docs
                          .map((d) => d.data()['name'] as String?)
                          .whereType<String>()
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList() ??
                      [];
                  names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  final demo = _demoCategoryChoices(t);
                  final items = names.isEmpty
                      ? demo
                      : [for (final n in names) (n, n)];
                  final codes = items.map((e) => e.$1).toList();
                  final value =
                      codes.contains(_selectedCategory) ? _selectedCategory : codes.first;
                  if (value != _selectedCategory) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedCategory = value);
                    });
                  }
                  return _buildDropdown(
                    label: t.bookCategoryLabel,
                    value: value,
                    items: items,
                    onChanged: (v) => setState(() => _selectedCategory = v ?? value),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildGenreSection(t),
              const SizedBox(height: 16),
              _SectionTitle(title: t.bookCoverSectionTitle, icon: Icons.image_outlined),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 128,
                  height: 180,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: buildBookCoverDisplay(
                    imageRef: _effectiveCoverForPreview(),
                    width: 128,
                    height: 180,
                    placeholder: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 44,
                      color: theme.colorScheme.primary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlTextController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: t.bookCoverUrlLabel,
                  hintText: t.bookCoverUrlHint,
                  prefixIcon: const Icon(Icons.link, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: Text(t.bookCoverPickGallery),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_effectiveCoverForPreview().isEmpty) ? null : _clearCoverImage,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: Text(t.bookCoverRemove),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: t.bookIsbnLabel,
                hint: t.bookIsbnHint,
                controller: _isbnController,
                prefixIcon: Icons.tag,
                keyboardType: TextInputType.text,
              ),

              // Số lượng
              const SizedBox(height: 24),
              _SectionTitle(title: t.bookInventorySection, icon: Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                label: t.bookQuantityLabel,
                hint: '0',
                controller: _quantityController,
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                required: true,
              ),

              const SizedBox(height: 24),
              _SectionTitle(title: t.bookDescriptionSectionTitle, icon: Icons.description_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                label: t.bookDescriptionFieldLabel,
                hint: t.bookDescriptionFieldHint,
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                fadedHint: true,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    await _onSubmit(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(widget.isEdit ? t.submitUpdateBook : t.submitAddBook),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim();
    final description = _descriptionController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    final data = <String, dynamic>{
      'title': title,
      'author': author,
      'category': _selectedCategory,
      'categoryId': _selectedCategory, // tạm dùng tên danh mục làm id
      'isbn': isbn,
      'description': description,
      'quantity': quantity,
      'isAvailable': quantity > 0,
      'imageUrl': _effectiveImageUrlForSubmit(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    void applyAuthorAndGenreIds() {
      if (_linkedAuthorId != null && _linkedAuthorId!.isNotEmpty) {
        data['authorId'] = _linkedAuthorId;
      } else if (widget.isEdit) {
        data['authorId'] = FieldValue.delete();
      }
      if (_selectedGenreId != null && _selectedGenreId!.isNotEmpty) {
        data['genreId'] = _selectedGenreId;
      } else if (widget.isEdit) {
        data['genreId'] = FieldValue.delete();
      }
    }

    applyAuthorAndGenreIds();

    final booksRef = FirebaseFirestore.instance.collection('books');

    try {
      await CategoryEnsureService.ensureByName(_selectedCategory);

      if (widget.isEdit && _docId != null) {
        // Giữ nguyên availableQuantity hiện tại để tránh sai lệch mượn trả
        final docSnap = await booksRef.doc(_docId).get();
        final current = docSnap.data();
        final currentAvailable = current?['availableQuantity'];
        if (currentAvailable != null) {
          data['availableQuantity'] = currentAvailable;
        }
        await booksRef.doc(_docId).update(data);
      } else {
        await booksRef.add({
          ...data,
          'availableQuantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
          'totalBorrowCount': 0,
        });
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? t.saveBookSuccessUpdate : t.saveBookSuccessAdd),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.saveBookError('$e'))),
      );
    }
  }

  Future<void> _shareVietnameseExcelTemplate() async {
    final t = AppLocalizations.of(context)!;
    final bytes = BookExcelSampleTemplate.buildLocalizedSampleBytes(t);
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.cannotCreateTemplate)),
      );
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              name: t.excelTemplateFileName,
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          fileNameOverrides: [t.excelTemplateFileName],
          subject: t.excelTemplateSubject,
          text: t.excelTemplateBody,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.shareFileError('$e'))),
        );
      }
    }
  }

  Future<void> _pickExcelFile() async {
    final t = AppLocalizations.of(context)!;
    setState(() {
      _excelWorking = true;
      _excelParseMessages.clear();
      _excelParsedBooks = null;
      _excelFileName = null;
    });
    try {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: true,
      );
      if (!mounted) return;
      if (pick == null || pick.files.isEmpty) {
        setState(() => _excelWorking = false);
        return;
      }
      final f = pick.files.single;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() {
          _excelWorking = false;
          _excelParseMessages.add(
            t.cannotReadFileContent,
          );
        });
        return;
      }
      final parsed = BookExcelImportService.parseXlsx(bytes, t);
      setState(() {
        _excelWorking = false;
        _excelFileName = f.name;
        _excelParsedBooks = parsed.books;
        _excelParseMessages.clear();
        _excelParseMessages.addAll(parsed.parseErrors);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _excelWorking = false;
          _excelParsedBooks = null;
          _excelFileName = null;
          _excelParseMessages
            ..clear()
            ..add(t.excelPickReadError('$e'));
        });
      }
    }
  }

  Widget _buildAuthorSection(BuildContext context, AppLocalizations t, ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('authors').snapshots(),
      builder: (context, snap) {
        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snap.data?.docs ?? []);
        docs.sort(
          (a, b) => (a.data()['name'] ?? '').toString().toLowerCase().compareTo(
                (b.data()['name'] ?? '').toString().toLowerCase(),
              ),
        );
        final items = <(String, String)>[(_kManualAuthor, t.bookAuthorManualOption)];
        for (final d in docs) {
          final name = (d.data()['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          items.add((d.id, name));
        }
        var ddValue = _kManualAuthor;
        if (_linkedAuthorId != null && items.any((e) => e.$1 == _linkedAuthorId)) {
          ddValue = _linkedAuthorId!;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.bookAuthorPickHint,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, height: 1.35),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: ddValue,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.library_books_outlined)),
              items: items
                  .map((e) => DropdownMenuItem<String>(value: e.$1, child: Text(e.$2)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  if (v == _kManualAuthor) {
                    _linkedAuthorId = null;
                    _lastSyncedAuthorName = null;
                  } else {
                    _linkedAuthorId = v;
                    final name = items.firstWhere((e) => e.$1 == v).$2;
                    _authorController.text = name;
                    _lastSyncedAuthorName = name;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: t.bookAuthorLabel,
              hint: t.bookAuthorHint,
              controller: _authorController,
              prefixIcon: Icons.person_outline,
              required: true,
              onChanged: (v) {
                final sync = _lastSyncedAuthorName;
                if (sync != null && v.trim() != sync.trim()) {
                  setState(() {
                    _linkedAuthorId = null;
                    _lastSyncedAuthorName = null;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenreSection(AppLocalizations t) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('genres').snapshots(),
      builder: (context, snap) {
        final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snap.data?.docs ?? []);
        docs.sort(
          (a, b) => (a.data()['name'] ?? '').toString().toLowerCase().compareTo(
                (b.data()['name'] ?? '').toString().toLowerCase(),
              ),
        );
        final items = <(String, String)>[('', t.bookGenreNone)];
        for (final d in docs) {
          final name = (d.data()['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          items.add((d.id, name));
        }
        var value = _selectedGenreId ?? '';
        final codes = items.map((e) => e.$1).toList();
        if (!codes.contains(value)) {
          value = '';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedGenreId = null);
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.bookGenreLabel, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: value,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.label_outline)),
              items: items
                  .map((e) => DropdownMenuItem<String>(value: e.$1, child: Text(e.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGenreId = (v == null || v.isEmpty) ? null : v),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importExcelToFirestore() async {
    final t = AppLocalizations.of(context)!;
    final rows = _excelParsedBooks;
    if (rows == null || rows.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _excelWorking = true);
    try {
      final out = await BookExcelImportService.commit(rows, t);
      if (!mounted) return;
      if (out.error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.firestoreWriteError('${out.error}'))),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(t.importedNBooksFromExcel(out.written))),
      );
      nav.pop();
    } finally {
      if (mounted) setState(() => _excelWorking = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool fadedHint = false,
    void Function(String)? onChanged,
  }) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hintStyle = fadedHint
        ? theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor.withValues(alpha: 0.42),
            fontWeight: FontWeight.w400,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.caption),
            if (required) const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,
            prefixIcon: Icon(prefixIcon, size: 20),
          ),
          onChanged: onChanged,
          validator: required ? (v) => (v == null || v.isEmpty) ? t.fieldRequiredWithLabel(label) : null : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<(String value, String label)> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e.$1, child: Text(e.$2)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.confirmDeleteTitle),
        content: Text(t.confirmDeleteBookBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              if (_docId == null) {
                Navigator.pop(context);
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('books').doc(_docId).delete();
                if (context.mounted) {
                  AppRoutes.finishBookDeletionAndOpenBookList(
                    context,
                    message: t.bookDeletedToast,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.deleteBookError('$e'))),
                  );
                }
              }
            },
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3),
      ],
    );
  }
}

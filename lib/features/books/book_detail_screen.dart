import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/book_cover_display.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình chi tiết sách — đồng bộ Firestore realtime khi có [id].
class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  static Map<String, dynamic> _normalizeMap(dynamic raw) {
    if (raw is! Map) return {};
    return Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  static String? _linkedDocId(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return v;
    if (v is DocumentReference) return v.id;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static Map<String, dynamic> _fromFirestore(String id, Map<String, dynamic> data) {
    final quantity = (data['quantity'] is int) ? data['quantity'] as int : int.tryParse('${data['quantity']}') ?? 0;
    final availableRaw = data['availableQuantity'] ?? data['available'] ?? quantity;
    final available =
        (availableRaw is int) ? availableRaw : int.tryParse('$availableRaw') ?? quantity;
    final py = data['publishedYear'];
    final publishedYear = py is int
        ? py
        : py is double
            ? py.toInt()
            : int.tryParse('${py ?? ''}');
    final imageUrl = (data['imageUrl'] ?? '').toString().trim();
    final tbcRaw = data['totalBorrowCount'];
    var totalBorrowCount = 0;
    if (tbcRaw is int) {
      totalBorrowCount = tbcRaw;
    } else if (tbcRaw is double) {
      totalBorrowCount = tbcRaw.toInt();
    } else {
      totalBorrowCount = int.tryParse('$tbcRaw') ?? 0;
    }
    final isAvailRaw = data['isAvailable'];
    final isBorrowable = isAvailRaw is bool ? isAvailRaw : (available > 0);

    final map = <String, dynamic>{
      'id': id,
      'title': '${data['title'] ?? ''}',
      'author': '${data['author'] ?? ''}',
      'category': '${data['category'] ?? data['categoryId'] ?? ''}',
      'isbn': '${data['isbn'] ?? ''}',
      'quantity': quantity,
      'available': available,
      'description': '${data['description'] ?? ''}',
      'imageUrl': imageUrl,
      'totalBorrowCount': totalBorrowCount,
      'isBorrowable': isBorrowable,
    };
    if (publishedYear != null) map['publishedYear'] = publishedYear;
    final aid = _linkedDocId(data['authorId']);
    if (aid != null) map['authorId'] = aid;
    final gid = _linkedDocId(data['genreId']);
    if (gid != null) map['genreId'] = gid;
    if (data['createdAt'] is Timestamp) map['bookCreatedAt'] = data['createdAt'];
    if (data['updatedAt'] is Timestamp) map['bookUpdatedAt'] = data['updatedAt'];
    return map;
  }

  static String _formatDetailDate(BuildContext context, Object? value) {
    if (value is! Timestamp) return '';
    final d = value.toDate();
    return MaterialLocalizations.of(context).formatFullDate(d);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments;
    final initial = _normalizeMap(args);
    final id = initial['id'] as String?;

    if (id != null && id.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('books').doc(id).snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(t.bookDetailTitle)),
              body: Center(child: Text(t.genericErrorWithMessage('${snap.error}'))),
            );
          }
          if (!snap.hasData) {
            return Scaffold(
              appBar: AppBar(title: Text(t.bookDetailTitle)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (!snap.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: Text(t.bookDetailTitle)),
              body: Center(child: Text(t.bookNotFound)),
            );
          }
          final data = snap.data!.data() ?? {};
          final merged = {...initial, ..._fromFirestore(id, data)};
          return _BookDetailBody(bookMap: merged);
        },
      );
    }

    return _BookDetailBody(bookMap: initial);
  }
}

class _BookDetailBody extends StatelessWidget {
  final Map<String, dynamic> bookMap;

  const _BookDetailBody({required this.bookMap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = bookMap['id'] as String?;
    final title = bookMap['title'] as String? ?? '—';
    final author = bookMap['author'] as String? ?? '—';
    final category = bookMap['category'] as String? ?? '—';
    final isbn = bookMap['isbn'] as String? ?? '—';
    final quantity = bookMap['quantity'] is int ? bookMap['quantity'] as int : int.tryParse('${bookMap['quantity']}') ?? 0;
    final available =
        bookMap['available'] is int ? bookMap['available'] as int : int.tryParse('${bookMap['available']}') ?? 0;
    final description = (bookMap['description'] as String?)?.trim() ?? '';
    final staff = AppUser.isStaff;
    final imageUrl = (bookMap['imageUrl'] as String?)?.trim() ?? '';
    final genreId = bookMap['genreId']?.toString();
    final pyRaw = bookMap['publishedYear'];
    int? publishedYear;
    if (pyRaw is int) {
      publishedYear = pyRaw;
    } else if (pyRaw != null) {
      publishedYear = int.tryParse('$pyRaw');
    }
    final totalBorrowCount = bookMap['totalBorrowCount'] is int
        ? bookMap['totalBorrowCount'] as int
        : int.tryParse('${bookMap['totalBorrowCount'] ?? 0}') ?? 0;
    final isBorrowable = bookMap['isBorrowable'] is bool
        ? bookMap['isBorrowable'] as bool
        : (available > 0);
    final createdAt = bookMap['bookCreatedAt'];
    final updatedAt = bookMap['bookUpdatedAt'];
    final createdStr = BookDetailScreen._formatDetailDate(context, createdAt);
    final updatedStr = BookDetailScreen._formatDetailDate(context, updatedAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.bookDetailTitle),
        actions: [
          if (staff)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.editBook, arguments: bookMap),
            ),
          if (staff)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirm(context, id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: buildBookCoverDisplay(
                      imageRef: imageUrl,
                      width: 140,
                      height: 200,
                      placeholder: const Icon(Icons.menu_book, size: 80, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(t.bookAuthorPrefix(author), style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(category, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: t.bookDetailTotalQuantity, value: '$quantity', icon: Icons.inventory),
                    const Divider(),
                    _InfoRow(label: t.bookDetailAvailable, value: '$available', icon: Icons.check_circle, valueColor: AppColors.success),
                    const Divider(),
                    _InfoRow(
                      label: t.bookDetailOnLoan,
                      value: '${quantity - available}',
                      icon: Icons.bookmark,
                      valueColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (id != null && id.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_2, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(t.bookQrTitle, style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: id,
                            version: QrVersions.auto,
                            size: 160,
                            gapless: true,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          t.bookDetailQrScanHint,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'ID: $id',
                          style: AppTextStyles.small.copyWith(
                            color: theme.hintColor,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.bookInfoSection, style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.tag, label: t.bookDetailIsbnTile, value: isbn.isEmpty ? t.bookDetailValueDash : isbn),
                    const SizedBox(height: 8),
                    _InfoTile(icon: Icons.category, label: t.bookDetailCategoryTile, value: category.isEmpty ? t.bookDetailValueDash : category),
                    const SizedBox(height: 8),
                    _InfoTile(icon: Icons.person, label: t.bookDetailAuthorTile, value: author.isEmpty ? t.bookDetailValueDash : author),
                    if (publishedYear != null) ...[
                      const SizedBox(height: 8),
                      _InfoTile(
                        icon: Icons.calendar_month_outlined,
                        label: t.bookDetailPublishedYearTile,
                        value: '$publishedYear',
                      ),
                    ],
                    const SizedBox(height: 8),
                    _BookDetailGenreTile(genreId: genreId),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.bookDetailMetadataSection, style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      label: t.bookDetailBorrowableTile,
                      value: isBorrowable ? t.bookDetailBorrowableYes : t.bookDetailBorrowableNo,
                    ),
                    const SizedBox(height: 8),
                    _InfoTile(
                      icon: Icons.repeat,
                      label: t.bookDetailTotalBorrowsTile,
                      value: '$totalBorrowCount',
                    ),
                    if (createdStr.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoTile(icon: Icons.event_available_outlined, label: t.bookDetailCreatedAtTile, value: createdStr),
                    ],
                    if (updatedStr.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoTile(icon: Icons.update, label: t.bookDetailUpdatedAtTile, value: updatedStr),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.bookDescriptionSection, style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      description.isEmpty ? t.bookNoDescription : description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          height: 84,
          child: Row(
            children: [
              Expanded(
                child: _BottomActionItem(
                  icon: Icons.download,
                  label: t.bookDetailActionCreateBorrow,
                  onTap: id == null || id.isEmpty
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.bookMissingIdCannotBorrow)),
                          );
                        }
                      : () => AppRoutes.openBorrowCreate(
                            context,
                            arguments: {'bookId': id},
                          ),
                ),
              ),
              Expanded(
                child: _BottomActionItem(
                  icon: Icons.share,
                  label: t.bookDetailActionShare,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.bookIdLabel(id ?? '—'))),
                    );
                  },
                ),
              ),
              if (staff)
                Expanded(
                  child: _BottomActionItem(
                    icon: Icons.edit,
                    label: t.editAction,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.editBook, arguments: bookMap),
                  ),
                ),
              Expanded(
                child: _BottomActionItem(
                  icon: Icons.print,
                  label: t.bookDetailActionPrint,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.printNotSupported)),
                    );
                  },
                ),
              ),
              if (staff)
                Expanded(
                  child: _BottomActionItem(
                    icon: Icons.delete,
                    label: t.deleteAction,
                    iconColor: AppColors.error,
                    onTap: () => _showDeleteConfirm(context, id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String? bookId) {
    final t = AppLocalizations.of(context)!;
    if (bookId == null || bookId.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.deleteConfirmBookBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
                if (context.mounted) {
                  AppRoutes.finishBookDeletionAndOpenBookList(
                    context,
                    message: t.deletedBookToast,
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
            child: Text(t.deleteAction),
          ),
        ],
      ),
    );
  }
}

/// Thể loại từ `genres/{genreId}` — realtime khi sửa tên thể loại ở quản lý.
class _BookDetailGenreTile extends StatelessWidget {
  final String? genreId;

  const _BookDetailGenreTile({required this.genreId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final id = genreId?.trim();
    if (id == null || id.isEmpty) {
      return _InfoTile(icon: Icons.label_outline, label: t.bookDetailGenreTile, value: t.bookDetailValueDash);
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('genres').doc(id).snapshots(),
      builder: (context, snap) {
        var value = t.bookDetailValueDash;
        if (snap.hasData && snap.data!.exists) {
          final n = snap.data!.data()?['name'];
          if (n != null && '$n'.trim().isNotEmpty) value = '$n'.trim();
        }
        return _InfoTile(icon: Icons.label_outline, label: t.bookDetailGenreTile, value: value);
      },
    );
  }
}

class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = iconColor ?? theme.colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: effectiveColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(value, style: AppTextStyles.h3.copyWith(color: valueColor)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.small),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

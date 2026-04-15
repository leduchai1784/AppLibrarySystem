import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../gen/l10n/app_localizations.dart';

/// Giao diện web cho nhân viên: tra cứu sách bằng bookId/ISBN, không dùng camera/QR.
class WebStaffDeskTab extends StatefulWidget {
  const WebStaffDeskTab({super.key});

  @override
  State<WebStaffDeskTab> createState() => _WebStaffDeskTabState();
}

class _WebStaffDeskTabState extends State<WebStaffDeskTab> {
  final _codeController = TextEditingController();
  bool _loading = false;
  _DeskBook? _book;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final t = AppLocalizations.of(context)!;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.enterBookIdOrIsbn)),
      );
      return;
    }

    setState(() {
      _loading = true;
      _book = null;
    });

    try {
      final booksRef = FirebaseFirestore.instance.collection('books');
      final byId = await booksRef.doc(code).get();
      if (byId.exists) {
        final data = byId.data();
        if (data != null && mounted) {
          setState(() => _book = _DeskBook.fromDoc(byId.id, data));
        }
        return;
      }

      final byIsbn = await booksRef.where('isbn', isEqualTo: code).limit(1).get();
      if (byIsbn.docs.isNotEmpty) {
        final doc = byIsbn.docs.first;
        if (mounted) {
          setState(() => _book = _DeskBook.fromDoc(doc.id, doc.data()));
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.bookNotFoundShort)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.lookupError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _bookToDetailMap(_DeskBook b) => {
        'id': b.id,
        'title': b.title,
        'author': b.author,
        'category': b.category,
        'isbn': b.isbn,
        'quantity': b.quantity,
        'available': b.available,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              t.deskTitle,
              style: AppTextStyles.h1.copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              t.deskSubtitle,
              style: AppTextStyles.body.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 28),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(t.deskLookupTitle, style: AppTextStyles.h3),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            onSubmitted: (_) => _lookup(),
                            decoration: InputDecoration(
                              hintText: t.deskCodeHint,
                              prefixIcon: const Icon(Icons.tag_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _loading ? null : _lookup,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(t.findAction),
                        ),
                      ],
                    ),
                    if (_book != null) ...[
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      _BookResultCard(
                        book: _book!,
                        onOpenDetail: () => AppRoutes.pushRoot(
                          context,
                          AppRoutes.bookDetail,
                          arguments: _bookToDetailMap(_book!),
                        ),
                        onBorrow: () => AppRoutes.openBorrowCreate(
                          context,
                          arguments: {'bookId': _book!.id},
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(t.quickActions, style: AppTextStyles.h3),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 700 ? 4 : (w >= 480 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: cols >= 4 ? 1.35 : 1.5,
                  children: [
                    _DeskActionCard(
                      icon: Icons.add_circle_outline,
                      label: t.quickCreateBorrow,
                      subtitle: t.quickCreateBorrowSubtitle,
                      onTap: () => AppRoutes.openBorrowCreate(context),
                    ),
                    _DeskActionCard(
                      icon: Icons.keyboard_return,
                      label: t.quickReturn,
                      subtitle: t.quickReturnSubtitle,
                      onTap: () => AppRoutes.openReturnBook(context),
                    ),
                    _DeskActionCard(
                      icon: Icons.bookmark_outline,
                      label: t.quickCurrentBorrows,
                      subtitle: t.quickCurrentBorrowsSubtitle,
                      onTap: () => AppRoutes.pushRoot(context, AppRoutes.currentBorrows),
                    ),
                    _DeskActionCard(
                      icon: Icons.history,
                      label: t.quickHistory,
                      subtitle: t.quickHistorySubtitle,
                      onTap: () => AppRoutes.pushRoot(context, AppRoutes.borrowHistory),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DeskBook {
  final String id;
  final String title;
  final String author;
  final String category;
  final String isbn;
  final int quantity;
  final int available;

  _DeskBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    required this.quantity,
    required this.available,
  });

  factory _DeskBook.fromDoc(String id, Map<String, dynamic> data) {
    final quantity = (data['quantity'] ?? 0) as int;
    final available = (data['availableQuantity'] ?? data['available'] ?? quantity) as int;
    return _DeskBook(
      id: id,
      title: (data['title'] ?? '') as String,
      author: (data['author'] ?? '') as String,
      category: (data['category'] ?? data['categoryId'] ?? kDefaultBookCategory) as String,
      isbn: (data['isbn'] ?? '') as String,
      quantity: quantity,
      available: available,
    );
  }
}

class _BookResultCard extends StatelessWidget {
  final _DeskBook book;
  final VoidCallback onOpenDetail;
  final VoidCallback onBorrow;

  const _BookResultCard({
    required this.book,
    required this.onOpenDetail,
    required this.onBorrow,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stockColor = book.available > 0 ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title.isEmpty ? t.webDeskUntitledBook : book.title, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(t.bookIdDebugLabel(book.id), style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            t.webDeskRemainingIsbn(
              '${book.available}',
              '${book.quantity}',
              book.isbn.isEmpty ? '—' : book.isbn,
            ),
            style: AppTextStyles.body.copyWith(color: stockColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenDetail,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(t.bookDetailsAction),
              ),
              FilledButton.icon(
                onPressed: () {
                  if (book.available > 0) {
                    onBorrow();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.outOfStockCannotBorrow)),
                    );
                  }
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(t.createBorrowRecordAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeskActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DeskActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const Spacer(),
              Text(label, style: AppTextStyles.h3.copyWith(fontSize: 15)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

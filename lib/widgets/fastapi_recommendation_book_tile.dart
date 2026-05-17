import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/l10n/book_category_display.dart';
import '../core/routes/app_routes.dart';
import '../core/utils/book_cover_display.dart';
import '../gen/l10n/app_localizations.dart';
import '../services/fastapi_recommendations_client.dart';

/// Thẻ sách ngang dùng chung cho gợi ý FastAPI (home / chi tiết sách).
class FastApiRecommendationBookTile extends StatelessWidget {
  const FastApiRecommendationBookTile({super.key, required this.book});

  final FastApiRecommendationBook book;

  Future<String> _fallbackCoverFromFirestore() async {
    final id = book.id.trim();
    if (id.isEmpty) return '';
    final snap = await FirebaseFirestore.instance
        .collection('books')
        .doc(id)
        .get();
    return (snap.data()?['imageUrl'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stockColor = book.availableQuantity > 0
        ? AppColors.success
        : AppColors.error;

    return InkWell(
      onTap: () {
        if (book.id.isEmpty) return;
        Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: {'id': book.id},
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 156,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (book.imageUrl.trim().isNotEmpty)
                  ? buildBookCoverDisplay(
                      imageRef: book.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    )
                  : FutureBuilder<String>(
                      future: _fallbackCoverFromFirestore(),
                      builder: (context, snap) {
                        final url = (snap.data ?? '').trim();
                        return buildBookCoverDisplay(
                          imageRef: url,
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title.isEmpty ? t.webDeskUntitledBook : book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            displayBookCategory(t, book.category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${book.availableQuantity}/${book.quantity}',
                        style: AppTextStyles.small.copyWith(
                          color: stockColor,
                          fontWeight: FontWeight.w900,
                        ),
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

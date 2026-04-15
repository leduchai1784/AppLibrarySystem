import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/book_cover_from_firestore.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../data/recommended_books_repository.dart';

class RecommendedBooksWidget extends StatefulWidget {
  const RecommendedBooksWidget({super.key});

  @override
  State<RecommendedBooksWidget> createState() => _RecommendedBooksWidgetState();
}

class _RecommendedBooksWidgetState extends State<RecommendedBooksWidget> {
  final _repo = RecommendedBooksRepository();
  late final PageController _pageController;
  final ValueNotifier<double> _page = ValueNotifier<double>(0);
  late final VoidCallback _pageListener;

  @override
  void initState() {
    super.initState();
    // Nhỏ gọn như bản đầu: card hẹp hơn, đỡ chiếm chiều ngang.
    _pageController = PageController(viewportFraction: 0.66);
    _pageListener = () {
      final p = _pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0;
      _page.value = p.toDouble();
    };
    _pageController.addListener(_pageListener);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final t = AppLocalizations.of(context)!;
    
    if (user == null) {
      return Text(
        t.needSignIn,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gợi ý cho bạn', // Có thể thêm vào localization sau: t.recommendedBooksTitle
              style: AppTextStyles.h3,
            ),
            Icon(Icons.auto_awesome, color: Colors.orangeAccent),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<RecommendedBooksState>(
          stream: _repo.watchHomeRecommendations(user.uid),
          builder: (context, snapshot) {
            final state = snapshot.data ?? const RecommendedBooksState.loading();

            if (state.error != null && !state.loading && state.ids.isEmpty) {
              return _InlineMessageCard(
                icon: Icons.error_outline,
                iconColor: Theme.of(context).colorScheme.error,
                text: 'Không tải được gợi ý. ${state.error}',
              );
            }

            if (state.loading) {
              return const _RecommendationShimmer();
            }

            if (state.ids.isEmpty) {
              return _InlineMessageCard(
                icon: Icons.psychology,
                iconColor: Colors.blueGrey,
                text: 'AI đang phân tích sở thích để đưa ra gợi ý phù hợp nhất với bạn...',
              );
            }

            // Dùng cache + stream books => có thể có lúc books chưa đủ, vẫn render mượt.
            final items = _sortByIds(state.ids, state.books);
            if (items.isEmpty) {
              return _InlineMessageCard(
                icon: Icons.menu_book_outlined,
                iconColor: Theme.of(context).hintColor,
                text: 'Chưa có sách gợi ý lúc này.',
              );
            }

            return _RecommendationCarousel(
              controller: _pageController,
              page: _page,
              items: items,
            );
          },
        ),
      ],
    );
  }
}

class _RecommendationCarousel extends StatelessWidget {
  final PageController controller;
  final ValueListenable<double> page;
  final List<RecommendedBookLite> items;

  const _RecommendationCarousel({
    required this.controller,
    required this.page,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 182,
          child: PageView.builder(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ValueListenableBuilder<double>(
                valueListenable: page,
                builder: (_, p, __) {
                  final delta = (p - index).clamp(-1.0, 1.0);
                  final scale = 1 - (delta.abs() * 0.10);
                  final parallax = delta * 14;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: _RecommendedBookCard(
                        bookId: item.id,
                        title: item.title,
                        author: item.author,
                        parallaxX: parallax,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _DotsIndicator(
          length: items.length,
          page: page,
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int length;
  final ValueListenable<double> page;

  const _DotsIndicator({
    required this.length,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = theme.colorScheme.primary;
    final inactive = theme.dividerColor.withValues(alpha: 0.7);

    final count = length.clamp(0, 10);
    if (count <= 1) return const SizedBox.shrink();

    return ValueListenableBuilder<double>(
      valueListenable: page,
      builder: (_, p, __) {
        final idx = p.round().clamp(0, count - 1);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final selected = i == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 7,
              width: selected ? 16 : 7,
              decoration: BoxDecoration(
                color: selected ? active : inactive,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RecommendedBookCard extends StatelessWidget {
  final String bookId;
  final String title;
  final String author;
  final double parallaxX;

  const _RecommendedBookCard({
    required this.bookId,
    required this.title,
    required this.author,
    this.parallaxX = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final radius = BorderRadius.circular(16);

    return Material(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.bookDetail,
            arguments: {'id': bookId},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRect(
                    child: Transform.translate(
                      offset: Offset(parallaxX, 0),
                      child: BookCoverFromBookId(
                        bookId: bookId,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'AI',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  // Gradient đáy để chữ đọc rõ trên mọi bìa
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _InlineMessageCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InlineMessageCard({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton (không cần package ngoài) cho loading.
class _RecommendationShimmer extends StatefulWidget {
  const _RecommendationShimmer();

  @override
  State<_RecommendationShimmer> createState() => _RecommendationShimmerState();
}

class _RecommendationShimmerState extends State<_RecommendationShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor.withValues(alpha: 0.20);
    final highlight = theme.dividerColor.withValues(alpha: 0.10);

    return SizedBox(
      height: 182 + 8 + 10,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            children: [
              Expanded(child: _shimmerCard(base, highlight, _c.value)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerCard(base, highlight, (_c.value + 0.35) % 1)),
            ],
          );
        },
      ),
    );
  }

  Widget _shimmerCard(Color base, Color highlight, double t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ShaderMask(
        shaderCallback: (rect) {
          final w = rect.width;
          return LinearGradient(
            begin: Alignment(-1 - 0.8 + (t * 2.6), 0),
            end: Alignment(1 - 0.8 + (t * 2.6), 0),
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(Rect.fromLTWH(0, 0, w, rect.height));
        },
        blendMode: BlendMode.srcATop,
        child: Container(color: base),
      ),
    );
  }
}

List<RecommendedBookLite> _sortByIds(
  List<String> ids,
  List<RecommendedBookLite> books,
) {
  final map = <String, RecommendedBookLite>{for (final b in books) b.id: b};
  return ids.map((id) => map[id]).whereType<RecommendedBookLite>().toList();
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../services/fastapi_recommendations_client.dart';
import '../../../services/library_config_service.dart';
import '../../../widgets/fastapi_recommendation_book_tile.dart';

enum _SimilarLoadIssue { none, http, timeout, parse, unknown }

/// Gợi ý theo sách đang xem — `GET …/recommend?book_id=…&top_k=…` (Bearer + tuỳ chọn X-Dev-Uid).
class BookSimilarRecommendationsSection extends StatefulWidget {
  const BookSimilarRecommendationsSection({
    super.key,
    required this.currentBookId,
    this.fallbackBaseUrl = 'http://10.10.10.113:8000',
  });

  final String currentBookId;
  final String fallbackBaseUrl;

  @override
  State<BookSimilarRecommendationsSection> createState() =>
      _BookSimilarRecommendationsSectionState();
}

class _BookSimilarRecommendationsSectionState
    extends State<BookSimilarRecommendationsSection> {
  bool _loading = true;
  List<FastApiRecommendationBook> _items = const [];
  _SimilarLoadIssue _issue = _SimilarLoadIssue.none;
  int? _httpStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BookSimilarRecommendationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBookId != widget.currentBookId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _issue = _SimilarLoadIssue.none;
      _httpStatus = null;
    });
    try {
      final m = await LibraryConfigService.getConfigMap();
      final base = LibraryConfigService.effectiveFastApiBaseUrl(
        m,
        widget.fallbackBaseUrl,
      );
      final cfg = FastApiRecommendationsSettings.fromConfigMap(m);
      var list = await FastApiRecommendationsClient.fetchByBookId(
        baseUrl: base,
        bookFirestoreId: widget.currentBookId,
        resourcePath: cfg.bookSimilarPath,
        topK: cfg.bookSimilarTopK,
        devBypassUid: cfg.devBypassUid,
      );
      list = list.where((b) => b.id != widget.currentBookId).toList();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _issue = _SimilarLoadIssue.none;
      });
    } on ApiHttpException catch (e) {
      debugPrint('[BookSimilarReco] HTTP: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _SimilarLoadIssue.http;
        _httpStatus = e.statusCode;
      });
    } on ApiTimeoutException catch (e) {
      debugPrint('[BookSimilarReco] timeout: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _SimilarLoadIssue.timeout;
      });
    } on ApiParseException catch (e) {
      debugPrint('[BookSimilarReco] parse: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _SimilarLoadIssue.parse;
      });
    } catch (e, st) {
      debugPrint('[BookSimilarReco] error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _SimilarLoadIssue.unknown;
      });
    }
  }

  String _errorDetail(AppLocalizations t) {
    switch (_issue) {
      case _SimilarLoadIssue.none:
        return '';
      case _SimilarLoadIssue.http:
        return t.recommendationsLoadFailedHttp('${_httpStatus ?? '?'}');
      case _SimilarLoadIssue.timeout:
        return t.recommendationsLoadFailedTimeout;
      case _SimilarLoadIssue.parse:
        return t.recommendationsLoadFailedParse;
      case _SimilarLoadIssue.unknown:
        return t.recommendationsLoadFailedUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.bookSimilarRecommendationsTitle,
                style: AppTextStyles.h3,
              ),
            ),
            IconButton(
              tooltip: t.refresh,
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_loading)
          const _SimilarRecoSkeleton()
        else if (_items.isEmpty && _issue != _SimilarLoadIssue.none)
          _SimilarRecoError(detail: _errorDetail(t))
        else if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.bookSimilarRecommendationsEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          )
        else
          SizedBox(
            height: 212,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              cacheExtent: 900,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  FastApiRecommendationBookTile(book: _items[index]),
            ),
          ),
      ],
    );
  }
}

class _SimilarRecoError extends StatelessWidget {
  const _SimilarRecoError({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final errColor = theme.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: errColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.bookSimilarRecommendationsLoadFailedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: errColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.bookSimilarRecommendationsLoadFailedHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarRecoSkeleton extends StatelessWidget {
  const _SimilarRecoSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 212,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 156,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 96,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(999),
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
}

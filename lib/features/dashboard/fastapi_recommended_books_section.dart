import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../widgets/fastapi_recommendation_book_tile.dart';
import '../../services/api_service.dart';
import '../../services/fastapi_recommendations_client.dart';
import '../../services/library_config_service.dart';

class FastApiRecommendedBooksSection extends StatefulWidget {
  const FastApiRecommendedBooksSection({super.key});

  @override
  State<FastApiRecommendedBooksSection> createState() =>
      _FastApiRecommendedBooksSectionState();
}

enum _RecommendationsLoadIssue { none, http, timeout, parse, unknown }

class _FastApiRecommendedBooksSectionState
    extends State<FastApiRecommendedBooksSection> {
  static const String _fallbackBaseUrl = 'http://10.10.10.113:8000';

  bool _loading = true;
  List<FastApiRecommendationBook> _items = const [];
  _RecommendationsLoadIssue _issue = _RecommendationsLoadIssue.none;
  int? _httpStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _issue = _RecommendationsLoadIssue.none;
      _httpStatus = null;
    });
    try {
      final m = await LibraryConfigService.getConfigMap();
      final base = LibraryConfigService.effectiveFastApiBaseUrl(
        m,
        _fallbackBaseUrl,
      );
      final reco = FastApiRecommendationsSettings.fromConfigMap(m);
      final list = await FastApiRecommendationsClient.fetch(
        baseUrl: base,
        resourcePath: reco.resourcePath,
        topK: reco.topK,
        devBypassUid: reco.devBypassUid,
      );
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _issue = _RecommendationsLoadIssue.none;
        _httpStatus = null;
      });
    } on ApiHttpException catch (e) {
      debugPrint('[FastApiRecommendedBooks] HTTP: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _RecommendationsLoadIssue.http;
        _httpStatus = e.statusCode;
      });
    } on ApiTimeoutException catch (e) {
      debugPrint('[FastApiRecommendedBooks] timeout: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _RecommendationsLoadIssue.timeout;
        _httpStatus = null;
      });
    } on ApiParseException catch (e) {
      debugPrint('[FastApiRecommendedBooks] parse: $e');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _RecommendationsLoadIssue.parse;
        _httpStatus = null;
      });
    } catch (e, st) {
      debugPrint('[FastApiRecommendedBooks] error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
        _issue = _RecommendationsLoadIssue.unknown;
        _httpStatus = null;
      });
    }
  }

  Future<void> _refresh() async {
    await _load();
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
              child: Text(t.recommendationsTitle, style: AppTextStyles.h3),
            ),
            IconButton(
              tooltip: t.refresh,
              onPressed: _loading ? null : _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_loading)
          const _RecoSkeleton()
        else if (_items.isEmpty && _issue != _RecommendationsLoadIssue.none)
          _RecoLoadError(issue: _issue, httpStatus: _httpStatus)
        else if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.recommendationsEmpty,
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

/// Phân biệt lỗi tải API với trạng thái “chưa có gợi ý” (API 200 nhưng danh sách rỗng).
class _RecoLoadError extends StatelessWidget {
  const _RecoLoadError({required this.issue, required this.httpStatus});

  final _RecommendationsLoadIssue issue;
  final int? httpStatus;

  String _detailLine(AppLocalizations t) {
    switch (issue) {
      case _RecommendationsLoadIssue.none:
        return '';
      case _RecommendationsLoadIssue.http:
        return t.recommendationsLoadFailedHttp('${httpStatus ?? '?'}');
      case _RecommendationsLoadIssue.timeout:
        return t.recommendationsLoadFailedTimeout;
      case _RecommendationsLoadIssue.parse:
        return t.recommendationsLoadFailedParse;
      case _RecommendationsLoadIssue.unknown:
        return t.recommendationsLoadFailedUnknown;
    }
  }

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
                  t.recommendationsLoadFailedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: errColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _detailLine(t),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.recommendationsLoadFailedHint,
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

class _RecoSkeleton extends StatelessWidget {
  const _RecoSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 212,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
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
                    _Sk(width: double.infinity, height: 12),
                    const SizedBox(height: 6),
                    _Sk(width: 96, height: 10),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _Sk(width: double.infinity, height: 16),
                        ),
                        SizedBox(width: 8),
                        _Sk(width: 38, height: 12),
                      ],
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

class _Sk extends StatelessWidget {
  final double width;
  final double height;
  const _Sk({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.62,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/export_share_bytes.dart';
import '../../core/utils/web_download.dart';
import '../../services/library_data_export_service.dart';
import '../../gen/l10n/app_localizations.dart';
import 'library_statistics_engine.dart';

enum _ExportKind { excel, pdf }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _exportBusy = false;
  DateTimeRange? _selectedRange;

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  DateTimeRange _thisWeekRange() {
    final now = DateTime.now();
    final start = _startOfDay(now.subtract(Duration(days: now.weekday - 1)));
    final end = _endOfDay(start.add(const Duration(days: 6)));
    return DateTimeRange(start: start, end: end);
  }

  String _rangeLabel(AppLocalizations t) {
    if (_selectedRange == null) return t.statsDateRangeThisWeek;
    final r = _selectedRange!;
    return '${r.start.day.toString().padLeft(2, '0')}/${r.start.month.toString().padLeft(2, '0')}'
        ' - ${r.end.day.toString().padLeft(2, '0')}/${r.end.month.toString().padLeft(2, '0')}';
  }

  Future<void> _pickRange(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _selectedRange ?? _thisWeekRange(),
      helpText: t.statsDateRangeHelp,
      confirmText: t.statsDatePickerDone,
      cancelText: t.statsDatePickerCancel,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _selectedRange = DateTimeRange(
        start: _startOfDay(picked.start),
        end: _endOfDay(picked.end),
      );
    });
  }

  Future<void> _showExportOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final lt = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  lt.statsExportPickFormat,
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: Text(lt.statsExportFormatExcel),
                onTap: () {
                  Navigator.pop(ctx);
                  _runExport(context, _ExportKind.excel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded),
                title: Text(lt.statsExportFormatPdf),
                onTap: () {
                  Navigator.pop(ctx);
                  _runExport(context, _ExportKind.pdf);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runExport(BuildContext context, _ExportKind kind) async {
    final t = AppLocalizations.of(context)!;
    setState(() => _exportBusy = true);
    try {
      final r = _selectedRange ?? _thisWeekRange();
      final ts = DateTime.now().millisecondsSinceEpoch;

      switch (kind) {
        case _ExportKind.excel:
          final bytes = await LibraryDataExportService.buildStatisticsExcelBytes(start: r.start, end: r.end, l10n: t);
          final name = 'library_statistics_$ts.xlsx';
          if (kIsWeb) {
            triggerWebDownloadBytes(
              name,
              bytes,
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );
          } else {
            await shareBytesAsFile(
              bytes,
              name,
              mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );
          }
        case _ExportKind.pdf:
          final bytes = await LibraryDataExportService.buildStatisticsPdfBytes(start: r.start, end: r.end, l10n: t);
          final name = 'library_statistics_$ts.pdf';
          if (kIsWeb) {
            triggerWebDownloadBytes(name, bytes, 'application/pdf');
          } else {
            await shareBytesAsFile(bytes, name, mimeType: 'application/pdf');
          }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.statsExportDone)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.statsExportError('$e'))));
    } finally {
      if (mounted) setState(() => _exportBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.statisticsTitle)),
        body: Center(child: Text(t.statsPermissionDenied)),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, booksSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('borrow_records').snapshots(),
          builder: (context, borrowsSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, usersSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                  builder: (context, catSnap) {
                    if (borrowsSnap.hasError || usersSnap.hasError) {
                      return Scaffold(
                        appBar: AppBar(title: Text(t.statisticsTitle)),
                        body: Center(
                          child: Text(t.statsLoadError),
                        ),
                      );
                    }
                    if (booksSnap.connectionState == ConnectionState.waiting && !booksSnap.hasData) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }
                    final bookDocs = booksSnap.data?.docs ?? [];
                    final allBorrows = borrowsSnap.data?.docs ?? [];
                    final userDocs = usersSnap.data?.docs ?? [];
                    final catDocs = catSnap.data?.docs ?? [];
                    final range = _selectedRange ?? _thisWeekRange();
                    final snap = computeLibraryStatistics(
                      bookDocs: bookDocs,
                      borrowDocsAll: allBorrows,
                      userDocs: userDocs,
                      categoryDocs: catDocs,
                      periodStart: range.start,
                      periodEnd: range.end,
                    );

                    return Scaffold(
                      body: Stack(
                        children: [
                          CustomScrollView(
                            slivers: [
                              SliverAppBar(
                                pinned: true,
                                toolbarHeight: 48,
                                surfaceTintColor: Colors.transparent,
                                backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.97),
                                foregroundColor: theme.colorScheme.onSurface,
                                title: Text(
                                  t.statisticsTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _DateRangeButton(
                                      label: _rangeLabel(t),
                                      onTap: () => _pickRange(context),
                                    ),
                                  ),
                                ],
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 96),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate(
                                    _buildContent(theme, t, snap),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SafeArea(
                              top: false,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.96),
                                  border: Border(
                                    top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.45)),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 46,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _exportBusy ? null : () => _showExportOptions(context),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _exportBusy
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.download_rounded, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                t.statsExportReport,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildContent(ThemeData theme, AppLocalizations t, LibraryStatisticsSnapshot s) {
    final colors = [AppColors.primary, const Color(0xFF60A5FA), const Color(0xFF93C5FD), const Color(0xFFBFDBFE)];
    final invDonut = s.categoryInventoryPct.isEmpty
        ? <(String, int, Color)>[(t.statsNoChartData, 1, AppColors.primary)]
        : s.categoryInventoryPct
            .asMap()
            .entries
            .map((e) => (e.value.$1, e.value.$3, colors[e.key % colors.length]))
            .toList();
    final borDonut = s.categoryBorrowCounts.isEmpty
        ? <(String, int, Color)>[(t.statsNoChartData, 1, AppColors.secondary)]
        : s.categoryBorrowCounts
            .asMap()
            .entries
            .map((e) => (e.value.$1, e.value.$2, colors[e.key % colors.length]))
            .toList();

    final dailyVals = s.borrowsByDay.map((e) => e.$2.toDouble()).toList();
    final chartDaily = dailyVals.length <= 1 ? (dailyVals.isEmpty ? [0.0, 0.0] : [dailyVals.first, dailyVals.first]) : dailyVals;

    final monthNorm = normalizeBars(s.borrowsByMonthLast12.map((e) => e.$2).toList());

    return [
      _sectionHeader(theme, t.statsOverviewSection, t.statsOverviewSubtitle),
      const SizedBox(height: 10),
      LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final crossAxisCount = w >= 820 ? 3 : 2;
          final aspect = w >= 820 ? 1.9 : 1.55;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspect,
            children: [
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardBookTitles,
                  value: '${s.totalBookTitles}',
                  icon: Icons.menu_book_rounded,
                  iconBg: AppColors.primary.withValues(alpha: 0.08),
                  deltaText: t.statsDeltaTotalPrintCopies('${s.totalBookCopies}'),
                  deltaColor: AppColors.success,
                ),
              ),
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardUsers,
                  value: '${s.totalUsers}',
                  icon: Icons.people_outline,
                  iconBg: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  deltaText: t.statsDeltaAccounts,
                  deltaColor: const Color(0xFF2563EB),
                ),
              ),
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardBorrowTurnsPeriod,
                  value: '${s.borrowEventsInPeriod}',
                  icon: Icons.history_rounded,
                  iconBg: AppColors.secondary.withValues(alpha: 0.12),
                  deltaText: t.statsDeltaByBorrowDate,
                  deltaColor: AppColors.primary,
                ),
              ),
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardActiveTickets,
                  value: '${s.activeBorrowTicketsGlobal}',
                  icon: Icons.bookmark_rounded,
                  iconBg: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  deltaText: t.statsDeltaSystemWide,
                  deltaColor: const Color(0xFF7C3AED),
                ),
              ),
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardInStock,
                  value: '${s.totalAvailableCopies}',
                  icon: Icons.inventory_2_rounded,
                  iconBg: const Color(0xFF059669).withValues(alpha: 0.12),
                  deltaText: t.statsDeltaTotalAvailable,
                  deltaColor: const Color(0xFF059669),
                ),
              ),
              _SummaryStatCard(
                data: _SummaryCardData(
                  title: t.statsCardReturnedLatePeriod,
                  value: '${s.periodReturned + s.periodLate}',
                  icon: Icons.fact_check_rounded,
                  iconBg: const Color(0xFFEC4899).withValues(alpha: 0.12),
                  deltaText: t.statsDeltaLateShort('${s.periodLate}'),
                  deltaColor: s.periodLate > 0 ? AppColors.error : theme.hintColor,
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsBorrowReturnPeriodSection, null),
      const SizedBox(height: 8),
      _CardShell(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv(t.statsKvBorrowingTicketsInPeriod, '${s.periodBorrowing}'),
            _kv(t.statsKvReturned, '${s.periodReturned}'),
            _kv(t.statsKvLateRecorded, '${s.periodLate}'),
            if (s.onTimeReturnRate != null) _kv(t.statsKvOnTimeRate, '${(s.onTimeReturnRate! * 100).toStringAsFixed(1)}%'),
            if (s.avgBorrowDaysReturned != null)
              _kv(
                t.statsKvAvgBorrowDaysReturned,
                t.statsKvAvgBorrowDaysValue(s.avgBorrowDaysReturned!.toStringAsFixed(1)),
              ),
            const SizedBox(height: 6),
            Text(
              t.statsFootnoteOnTimeReturns,
              style: AppTextStyles.caption.copyWith(fontSize: 10, color: theme.hintColor),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsDailyBorrowsSection, null),
      const SizedBox(height: 8),
      _CardShell(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.statsTotalTurns('${s.borrowEventsInPeriod}'),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineAreaPainter(data: chartDaily, color: AppColors.primary),
              ),
            ),
            if (s.borrowsByDay.length <= 14)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: s.borrowsByDay.map((e) {
                  return Chip(
                    label: Text('${e.$1.day}/${e.$1.month}: ${e.$2}', style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsMonthlyBorrowsSection, t.statsMonthlyTrendSubtitle),
      const SizedBox(height: 8),
      _CardShell(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _MonthlyBarPainter(
                  values: monthNorm,
                  labels: s.borrowsByMonthLast12.map((e) => e.$1.substring(5)).toList(),
                  color: AppColors.primary,
                ),
              ),
            ),
            if (s.borrowsByMonthLast12.length >= 2) ...[
              const SizedBox(height: 8),
              Text(
                _monthCompareText(t, s.borrowsByMonthLast12),
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsCategoriesSection, t.statsCategoriesDonutsSubtitle),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 380;
          final left = _donutCard(theme, t.statsDonutByInventory, invDonut);
          final right = _donutCard(theme, t.statsDonutBorrowedInPeriod, borDonut);
          if (narrow) return Column(children: [left, const SizedBox(height: 10), right]);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 10),
              Expanded(child: right),
            ],
          );
        },
      ),
      const SizedBox(height: 12),
      _CardShell(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.statsTopCategoriesBorrowed, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...s.categoryBorrowCounts.take(6).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _HorizontalPercentBar(
                      label: e.$1,
                      percent: s.borrowEventsInPeriod > 0 ? (e.$2 / s.borrowEventsInPeriod) * 100 : 0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsBooksSection, t.statsBooksSectionsSubtitle),
      const SizedBox(height: 8),
      _rankedBookCard(theme, t, t.statsTopBorrowedThisPeriod, s.topBorrowed),
      const SizedBox(height: 10),
      _rankedBookCard(theme, t, t.statsLeastBorrowedThisPeriod, s.leastBorrowed),
      const SizedBox(height: 10),
      _bookListCard(theme, t, t.statsOutOfStockTitle, s.outOfStockBooks, empty: t.statsOutOfStockEmpty),
      const SizedBox(height: 10),
      _bookListCard(theme, t, t.statsNewBooksInPeriodTitle, s.newBooksInPeriod, empty: t.statsNewBooksEmpty),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsAuthorsByPeriodSection, null),
      const SizedBox(height: 8),
      _CardShell(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: s.authorBorrowCounts.isEmpty
            ? Text(t.statsNoChartData, style: TextStyle(color: theme.hintColor))
            : Column(
                children: s.authorBorrowCounts
                    .map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.$1, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text('${e.$2}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    )
                    .toList(),
              ),
      ),
      const SizedBox(height: 16),
      _sectionHeader(theme, t.statsUsersSection, null),
      const SizedBox(height: 8),
      _userListCard(theme, t, t.statsTopUsersPeriod, s.topUserBorrowers),
      const SizedBox(height: 10),
      _borrowerRowsCard(theme, t, t.statsBorrowersActiveTickets, s.currentBorrowers, overdue: false),
      const SizedBox(height: 10),
      _borrowerRowsCard(theme, t, t.statsBorrowersOverdue, s.overdueBorrowers, overdue: true),
      const SizedBox(height: 16),
    ];
  }

  Widget _sectionHeader(ThemeData theme, String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
        ],
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(k, style: AppTextStyles.body.copyWith(fontSize: 13))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _monthCompareText(AppLocalizations t, List<(String, int)> months) {
    if (months.length < 2) return '';
    final a = months[months.length - 2];
    final b = months[months.length - 1];
    final diff = b.$2 - a.$2;
    final arrow = diff >= 0 ? '↑' : '↓';
    return t.statsMonthCompareTwo(a.$1, '${a.$2}', b.$1, '${b.$2}', arrow, '${diff.abs()}');
  }

  Widget _donutCard(ThemeData theme, String title, List<(String, int, Color)> items) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(painter: _DonutPainter(items: items)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .take(6)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: e.$3, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${e.$1} (${e.$2})',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rankedBookCard(ThemeData theme, AppLocalizations t, String title, List<RankedBookRow> rows) {
    return _CardShell(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.35)),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(t.statsEmptyTopBooks, style: TextStyle(color: theme.hintColor)),
            )
          else
            ...rows.map(
              (row) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text('${row.rank}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
                title: Text(row.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(row.categoryLabel, style: const TextStyle(fontSize: 11)),
                trailing: Text('${row.borrowCount}', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookListCard(
    ThemeData theme,
    AppLocalizations t,
    String title,
    List<BookListRow> rows, {
    required String empty,
  }) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(empty, style: TextStyle(color: theme.hintColor, fontSize: 13))
          else
            ...rows.take(12).map(
                  (b) => ListTile(
                    dense: true,
                    title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      t.statsBookStockSubtitle(
                        '${b.available}',
                        '${b.quantity}',
                        b.author.isNotEmpty ? ' · ${b.author}' : '',
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _userListCard(
    ThemeData theme,
    AppLocalizations t,
    String title,
    List<(String, String, int)> rows,
  ) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(t.statsNoChartData, style: TextStyle(color: theme.hintColor))
          else
            ...rows.map(
              (e) => ListTile(
                dense: true,
                title: Text(e.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(e.$1, style: const TextStyle(fontSize: 11)),
                trailing: Text(t.statsUserBorrowCount('${e.$3}'), style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _borrowerRowsCard(
    ThemeData theme,
    AppLocalizations t,
    String title,
    List<BorrowerRow> rows, {
    required bool overdue,
  }) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(t.statsBorrowersNone, style: TextStyle(color: theme.hintColor))
          else
            ...rows.take(15).map(
                  (r) => ListTile(
                    dense: true,
                    title: Text(r.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(r.email, style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      overdue
                          ? t.statsBorrowerOverdueCount('${r.overdueCount}')
                          : t.statsBorrowerActiveCount('${r.activeCount}'),
                      style: TextStyle(fontWeight: FontWeight.w900, color: overdue ? AppColors.error : null),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SummaryCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final String deltaText;
  final Color deltaColor;

  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.deltaText,
    required this.deltaColor,
  });
}

class _SummaryStatCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = data.deltaColor == AppColors.success ? AppColors.primary : data.deltaColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: data.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(data.icon, size: 17, color: iconColor),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: data.deltaColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          data.deltaText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.25,
                            fontWeight: FontWeight.w800,
                            color: data.deltaColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.title,
                  style: AppTextStyles.caption.copyWith(fontSize: 10.75, height: 1.15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        clipBehavior: clipBehavior,
        child: Material(
          color: theme.colorScheme.surface,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateRangeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.primary),
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: theme.colorScheme.onSurface),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _HorizontalPercentBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _HorizontalPercentBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safe = percent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${safe.toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 8,
            width: double.infinity,
            color: color.withValues(alpha: 0.14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: safe / 100,
                child: Container(color: color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineAreaPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineAreaPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final pts = data.length == 1 ? [data.first, data.first] : data;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final h = size.height;
    final w = size.width;

    final minV = pts.reduce(min);
    final maxV = pts.reduce(max);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    for (int i = 1; i <= 3; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < pts.length; i++) {
      final x = pts.length <= 1 ? w / 2 : w * i / (pts.length - 1);
      final normalized = (pts[i] - minV) / range;
      final y = h - (normalized * h * 0.9 + h * 0.05);
      points.add(Offset(x, y));
    }

    final areaPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }
    areaPath
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();
    canvas.drawPath(areaPath, paintArea);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paintLine);

    final dotPaint = Paint()..color = Colors.white;
    final dotStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

class _MonthlyBarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;

  _MonthlyBarPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final n = values.length;
    final gap = 4.0;
    final barW = (size.width - gap * (n + 1)) / n;
    final maxH = size.height - 28;
    for (var i = 0; i < n; i++) {
      final h = maxH * values[i];
      final left = gap + i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - 22 - h, barW, h),
        const Radius.circular(4),
      );
      final p = Paint()..color = color.withValues(alpha: 0.85);
      canvas.drawRRect(rect, p);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(fontSize: 9, color: color, fontFeatures: const [ui.FontFeature.tabularFigures()]),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barW + gap);
      tp.paint(canvas, Offset(left + (barW - tp.width) / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _DonutPainter extends CustomPainter {
  final List<(String, int, Color)> items;

  _DonutPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<int>(0, (s, e) => s + e.$2);
    if (total <= 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radius = min(size.width, size.height) / 2;
    const stroke = 12.0;

    var startAngle = -pi / 2;
    for (final it in items) {
      final angle = 2 * pi * (it.$2 / total);
      final paint = Paint()
        ..color = it.$3
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        startAngle,
        angle,
        false,
        paint,
      );
      startAngle += angle;
    }

    final holePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - stroke, holePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

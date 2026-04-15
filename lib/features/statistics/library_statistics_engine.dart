import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Kết quả tính toán thống kê thư viện (từ snapshot Firestore đã nạp client-side).
class LibraryStatisticsSnapshot {
  const LibraryStatisticsSnapshot({
    required this.periodStart,
    required this.periodEnd,
    required this.totalBookTitles,
    required this.totalBookCopies,
    required this.totalAvailableCopies,
    required this.totalUsers,
    required this.borrowEventsInPeriod,
    required this.activeBorrowTicketsGlobal,
    required this.periodBorrowing,
    required this.periodReturned,
    required this.periodLate,
    required this.topBorrowed,
    required this.leastBorrowed,
    required this.outOfStockBooks,
    required this.newBooksInPeriod,
    required this.categoryInventoryPct,
    required this.categoryBorrowCounts,
    required this.authorBorrowCounts,
    required this.borrowsByDay,
    required this.borrowsByMonthLast12,
    required this.topUserBorrowers,
    required this.currentBorrowers,
    required this.overdueBorrowers,
    required this.onTimeReturnRate,
    required this.avgBorrowDaysReturned,
  });

  final DateTime periodStart;
  final DateTime periodEnd;

  final int totalBookTitles;
  final int totalBookCopies;
  final int totalAvailableCopies;
  final int totalUsers;
  /// Số phiếu (lượt) có borrowDate trong kỳ.
  final int borrowEventsInPeriod;
  /// Phiếu đang hoạt động (toàn hệ thống): status == borrowing.
  final int activeBorrowTicketsGlobal;

  final int periodBorrowing;
  final int periodReturned;
  final int periodLate;

  final List<RankedBookRow> topBorrowed;
  final List<RankedBookRow> leastBorrowed;
  final List<BookListRow> outOfStockBooks;
  final List<BookListRow> newBooksInPeriod;

  /// Tên hiển thị -> phần trăm (tồn đầu sách theo danh mục).
  final List<(String label, double pct, int count)> categoryInventoryPct;
  /// Danh mục được mượn nhiều trong kỳ (theo lượt mượn).
  final List<(String label, int borrows)> categoryBorrowCounts;

  final List<(String authorName, int borrows)> authorBorrowCounts;

  /// Ngày (local) -> số lượt mượn trong kỳ.
  final List<(DateTime day, int count)> borrowsByDay;
  /// 12 tháng gần nhất (kết thúc tại tháng của periodEnd): (nhãn yyyy-MM) -> count.
  final List<(String monthKey, int count)> borrowsByMonthLast12;

  final List<(String userId, String displayName, int borrows)> topUserBorrowers;
  final List<BorrowerRow> currentBorrowers;
  final List<BorrowerRow> overdueBorrowers;

  /// Tỷ lệ trả đúng hạn trong các phiếu đã trả (trong kỳ). Null nếu không có dữ liệu.
  final double? onTimeReturnRate;
  /// Số ngày mượn trung bình (phiếu đã trả trong kỳ).
  final double? avgBorrowDaysReturned;
}

class RankedBookRow {
  const RankedBookRow({
    required this.rank,
    required this.bookId,
    required this.title,
    required this.categoryLabel,
    required this.borrowCount,
  });

  final int rank;
  final String bookId;
  final String title;
  final String categoryLabel;
  final int borrowCount;
}

class BookListRow {
  const BookListRow({
    required this.bookId,
    required this.title,
    required this.author,
    required this.available,
    required this.quantity,
    this.createdAt,
  });

  final String bookId;
  final String title;
  final String author;
  final int available;
  final int quantity;
  final DateTime? createdAt;
}

class BorrowerRow {
  const BorrowerRow({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.activeCount,
    this.overdueCount = 0,
  });

  final String userId;
  final String displayName;
  final String email;
  final int activeCount;
  final int overdueCount;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  return int.tryParse('$v') ?? fallback;
}

bool _inDateRange(DateTime? d, DateTime start, DateTime endInclusive) {
  if (d == null) return false;
  final day = DateTime(d.year, d.month, d.day);
  final a = DateTime(start.year, start.month, start.day);
  final b = DateTime(endInclusive.year, endInclusive.month, endInclusive.day);
  return !day.isBefore(a) && !day.isAfter(b);
}

String _normCatKey(String? id, String? fallbackName) {
  final s = (id ?? fallbackName ?? '').trim();
  if (s.isEmpty) return '__other__';
  return s;
}

/// map userId -> (fullName, email)
Map<String, (String, String)> _userDisplayMap(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
) {
  final m = <String, (String, String)>{};
  for (final d in userDocs) {
    final data = d.data();
    final name = '${data['fullName'] ?? data['name'] ?? ''}'.trim();
    final email = '${data['email'] ?? ''}'.trim();
    m[d.id] = (name.isEmpty ? email : name, email);
  }
  return m;
}

Map<String, String> _categoryNames(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs,
) {
  final m = <String, String>{};
  for (final d in categoryDocs) {
    m[d.id] = '${d.data()['name'] ?? d.id}';
  }
  return m;
}

LibraryStatisticsSnapshot computeLibraryStatistics({
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> bookDocs,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> borrowDocsAll,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> userDocs,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs,
  required DateTime periodStart,
  required DateTime periodEnd,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final catNames = _categoryNames(categoryDocs);
  final usersMap = _userDisplayMap(userDocs);

  final booksById = <String, Map<String, dynamic>>{};
  for (final d in bookDocs) {
    booksById[d.id] = d.data();
  }

  String bookTitle(String bookId) =>
      '${booksById[bookId]?['title'] ?? '(Sách đã xóa)'}';

  String categoryLabelForBook(String bookId) {
    final m = booksById[bookId];
    if (m == null) return '—';
    final cid = '${m['categoryId'] ?? ''}'.trim();
    if (cid.isNotEmpty && catNames.containsKey(cid)) return catNames[cid]!;
    final legacy = '${m['category'] ?? ''}'.trim();
    if (legacy.isNotEmpty) return legacy;
    return catNames[cid] ?? (cid.isEmpty ? 'Khác' : cid);
  }

  String authorForBook(String bookId) {
    final m = booksById[bookId];
    if (m == null) return '—';
    final a = '${m['author'] ?? ''}'.trim();
    if (a.isNotEmpty) return a;
    return '—';
  }

  final periodStartDay = DateTime(periodStart.year, periodStart.month, periodStart.day);
  final periodEndDay = DateTime(periodEnd.year, periodEnd.month, periodEnd.day);

  var totalCopies = 0;
  var totalAvail = 0;
  for (final d in bookDocs) {
    final m = d.data();
    final q = _parseInt(m['quantity']);
    final aRaw = m['availableQuantity'] ?? m['available'] ?? q;
    totalCopies += q;
    totalAvail += _parseInt(aRaw, q);
  }

  final borrowsInPeriod = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  for (final d in borrowDocsAll) {
    final bd = (d.data()['borrowDate'] as Timestamp?)?.toDate();
    if (_inDateRange(bd, periodStartDay, periodEndDay)) {
      borrowsInPeriod.add(d);
    }
  }

  int periodB = 0, periodR = 0, periodL = 0;
  final borrowCountByBook = <String, int>{};
  final borrowCountByCategory = <String, int>{};
  final borrowCountByAuthor = <String, int>{};
  final borrowCountByUser = <String, int>{};

  for (final d in borrowsInPeriod) {
    final m = d.data();
    final st = '${m['status'] ?? ''}';
    if (st == 'borrowing') {
      periodB++;
    } else if (st == 'returned') {
      periodR++;
    } else if (st == 'late') {
      periodL++;
    }
    final bid = '${m['bookId'] ?? ''}'.trim();
    if (bid.isNotEmpty) {
      borrowCountByBook[bid] = (borrowCountByBook[bid] ?? 0) + 1;
      final bm = booksById[bid];
      final ck = _normCatKey(
        bm == null ? null : '${bm['categoryId']}'.trim(),
        bm == null ? null : '${bm['category']}'.trim(),
      );
      final catLabel = ck == '__other__'
          ? 'Khác'
          : (catNames[ck] ?? (bm != null && '${bm['category']}'.trim().isNotEmpty ? '${bm['category']}' : (ck)));
      borrowCountByCategory[catLabel] = (borrowCountByCategory[catLabel] ?? 0) + 1;
      final auth = authorForBook(bid);
      if (auth != '—') {
        borrowCountByAuthor[auth] = (borrowCountByAuthor[auth] ?? 0) + 1;
      }
    }
    final uid = '${m['userId'] ?? ''}'.trim();
    if (uid.isNotEmpty) {
      borrowCountByUser[uid] = (borrowCountByUser[uid] ?? 0) + 1;
    }
  }

  var activeGlobal = 0;
  for (final d in borrowDocsAll) {
    if ('${d.data()['status'] ?? ''}' == 'borrowing') activeGlobal++;
  }

  // Top / least
  final sortedBooks = borrowCountByBook.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topBorrowed = <RankedBookRow>[];
  for (var i = 0; i < sortedBooks.length && i < 10; i++) {
    final e = sortedBooks[i];
    topBorrowed.add(RankedBookRow(
      rank: i + 1,
      bookId: e.key,
      title: bookTitle(e.key),
      categoryLabel: categoryLabelForBook(e.key),
      borrowCount: e.value,
    ));
  }

  final allBookIds = bookDocs.map((e) => e.id).toList();
  final leastPairs = <({String id, int c})>[];
  for (final id in allBookIds) {
    leastPairs.add((id: id, c: borrowCountByBook[id] ?? 0));
  }
  leastPairs.sort((a, b) {
    final cmp = a.c.compareTo(b.c);
    if (cmp != 0) return cmp;
    return bookTitle(a.id).compareTo(bookTitle(b.id));
  });
  final leastBorrowed = <RankedBookRow>[];
  for (var i = 0; i < leastPairs.length && i < 10; i++) {
    final p = leastPairs[i];
    leastBorrowed.add(RankedBookRow(
      rank: i + 1,
      bookId: p.id,
      title: bookTitle(p.id),
      categoryLabel: categoryLabelForBook(p.id),
      borrowCount: p.c,
    ));
  }

  // Out of stock
  final outOfStock = <BookListRow>[];
  for (final d in bookDocs) {
    final m = d.data();
    final av = _parseInt(m['availableQuantity'] ?? m['available'] ?? m['quantity']);
    if (av <= 0) {
      outOfStock.add(BookListRow(
        bookId: d.id,
        title: '${m['title'] ?? '(Không tên)'}',
        author: '${m['author'] ?? ''}'.trim(),
        available: av,
        quantity: _parseInt(m['quantity']),
        createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      ));
    }
  }

  // New books in period (createdAt)
  final newBooks = <BookListRow>[];
  for (final d in bookDocs) {
    final m = d.data();
    final created = (m['createdAt'] as Timestamp?)?.toDate();
    if (created != null && _inDateRange(created, periodStartDay, periodEndDay)) {
      newBooks.add(BookListRow(
        bookId: d.id,
        title: '${m['title'] ?? '(Không tên)'}',
        author: '${m['author'] ?? ''}'.trim(),
        available: _parseInt(m['availableQuantity'] ?? m['available'] ?? m['quantity']),
        quantity: _parseInt(m['quantity']),
        createdAt: created,
      ));
    }
  }
  newBooks.sort((a, b) {
    final ad = a.createdAt;
    final bd = b.createdAt;
    if (ad == null && bd == null) return a.bookId.compareTo(b.bookId);
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  });
  final newBooksLimited = newBooks.length > 15 ? newBooks.sublist(0, 15) : newBooks;

  // Inventory by category (book counts)
  final invByCat = <String, int>{};
  for (final d in bookDocs) {
    final m = d.data();
    final cid = '${m['categoryId'] ?? ''}'.trim();
    final label = cid.isNotEmpty
        ? (catNames[cid] ?? cid)
        : ('${m['category'] ?? ''}'.trim().isNotEmpty ? '${m['category']}' : 'Khác');
    invByCat[label] = (invByCat[label] ?? 0) + 1;
  }
  final invTotal = invByCat.values.fold<int>(0, (s, e) => s + e);
  final categoryInventoryPct = <(String, double, int)>[];
  if (invTotal > 0) {
    final sorted = invByCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (var i = 0; i < sorted.length && i < 8; i++) {
      final e = sorted[i];
      categoryInventoryPct.add((e.key, (e.value / invTotal) * 100, e.value));
    }
  }

  final catBorrSorted = borrowCountByCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final categoryBorrowCounts = catBorrSorted.take(10).map((e) => (e.key, e.value)).toList();

  final authSorted = borrowCountByAuthor.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final authorBorrowCounts = authSorted.take(10).map((e) => (e.key, e.value)).toList();

  // Daily series in period
  final dayMap = <DateTime, int>{};
  for (var t = periodStartDay;
      !t.isAfter(periodEndDay);
      t = t.add(const Duration(days: 1))) {
    dayMap[DateTime(t.year, t.month, t.day)] = 0;
  }
  for (final d in borrowsInPeriod) {
    final bd = (d.data()['borrowDate'] as Timestamp?)?.toDate();
    if (bd == null) continue;
    final key = DateTime(bd.year, bd.month, bd.day);
    if (dayMap.containsKey(key)) {
      dayMap[key] = (dayMap[key] ?? 0) + 1;
    }
  }
  final borrowsByDay = dayMap.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => a.$1.compareTo(b.$1));

  // Last 12 months (calendar months ending at periodEnd's month)
  final anchorMonth = DateTime(periodEndDay.year, periodEndDay.month, 1);
  final monthBuckets = <String, int>{};
  for (var i = 11; i >= 0; i--) {
    final dt = DateTime(anchorMonth.year, anchorMonth.month - i, 1);
    final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
    monthBuckets[key] = 0;
  }
  for (final d in borrowDocsAll) {
    final bd = (d.data()['borrowDate'] as Timestamp?)?.toDate();
    if (bd == null) continue;
    final key = '${bd.year}-${bd.month.toString().padLeft(2, '0')}';
    if (monthBuckets.containsKey(key)) {
      monthBuckets[key] = (monthBuckets[key] ?? 0) + 1;
    }
  }
  final borrowsByMonthLast12 = monthBuckets.entries.map((e) => (e.key, e.value)).toList();

  // Top users
  final usrSort = borrowCountByUser.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topUserBorrowers = <(String, String, int)>[];
  for (var i = 0; i < usrSort.length && i < 10; i++) {
    final e = usrSort[i];
    final disp = usersMap[e.key];
    topUserBorrowers.add((e.key, disp?.$1 ?? e.key, e.value));
  }

  // Current borrowers: users with at least one active borrowing ticket
  final userActive = <String, int>{};
  final userOverdueTickets = <String, int>{};
  for (final d in borrowDocsAll) {
    final m = d.data();
    final uid = '${m['userId'] ?? ''}'.trim();
    if (uid.isEmpty) continue;
    final st = '${m['status'] ?? ''}';
    final due = (m['dueDate'] as Timestamp?)?.toDate();
    if (st == 'borrowing') {
      userActive[uid] = (userActive[uid] ?? 0) + 1;
      if (due != null && due.isBefore(clock)) {
        userOverdueTickets[uid] = (userOverdueTickets[uid] ?? 0) + 1;
      }
    } else if (st == 'late') {
      userOverdueTickets[uid] = (userOverdueTickets[uid] ?? 0) + 1;
    }
  }

  final currentBorrowers = <BorrowerRow>[];
  for (final e in userActive.entries) {
    final disp = usersMap[e.key];
    currentBorrowers.add(BorrowerRow(
      userId: e.key,
      displayName: disp?.$1 ?? e.key,
      email: disp?.$2 ?? '',
      activeCount: e.value,
      overdueCount: userOverdueTickets[e.key] ?? 0,
    ));
  }
  currentBorrowers.sort((a, b) => b.activeCount.compareTo(a.activeCount));

  final overdueSet = <String>{};
  final overdueRows = <BorrowerRow>[];
  for (final e in userOverdueTickets.entries) {
    overdueSet.add(e.key);
  }
  for (final uid in overdueSet) {
    final disp = usersMap[uid];
    overdueRows.add(BorrowerRow(
      userId: uid,
      displayName: disp?.$1 ?? uid,
      email: disp?.$2 ?? '',
      activeCount: userActive[uid] ?? 0,
      overdueCount: userOverdueTickets[uid] ?? 0,
    ));
  }
  overdueRows.sort((a, b) => b.overdueCount.compareTo(a.overdueCount));

  // On-time & avg duration (returned in period)
  var onTime = 0;
  var lateReturn = 0;
  var sumDays = 0.0;
  var nReturned = 0;
  for (final d in borrowsInPeriod) {
    final m = d.data();
    if ('${m['status'] ?? ''}' != 'returned') continue;
    final bd = (m['borrowDate'] as Timestamp?)?.toDate();
    final rd = (m['returnDate'] as Timestamp?)?.toDate();
    final due = (m['dueDate'] as Timestamp?)?.toDate();
    if (bd == null || rd == null) continue;
    nReturned++;
    sumDays += rd.difference(bd).inHours / 24.0;
    if (due != null) {
      final rdDay = DateTime(rd.year, rd.month, rd.day);
      final dueDay = DateTime(due.year, due.month, due.day);
      if (!rdDay.isAfter(dueDay)) {
        onTime++;
      } else {
        lateReturn++;
      }
    }
  }
  double? onTimeRate;
  if (onTime + lateReturn > 0) {
    onTimeRate = onTime / (onTime + lateReturn);
  }
  double? avgDays;
  if (nReturned > 0) {
    avgDays = sumDays / nReturned;
  }

  return LibraryStatisticsSnapshot(
    periodStart: periodStartDay,
    periodEnd: periodEndDay,
    totalBookTitles: bookDocs.length,
    totalBookCopies: totalCopies,
    totalAvailableCopies: totalAvail,
    totalUsers: userDocs.length,
    borrowEventsInPeriod: borrowsInPeriod.length,
    activeBorrowTicketsGlobal: activeGlobal,
    periodBorrowing: periodB,
    periodReturned: periodR,
    periodLate: periodL,
    topBorrowed: topBorrowed,
    leastBorrowed: leastBorrowed,
    outOfStockBooks: outOfStock,
    newBooksInPeriod: newBooksLimited,
    categoryInventoryPct: categoryInventoryPct,
    categoryBorrowCounts: categoryBorrowCounts,
    authorBorrowCounts: authorBorrowCounts,
    borrowsByDay: borrowsByDay,
    borrowsByMonthLast12: borrowsByMonthLast12,
    topUserBorrowers: topUserBorrowers,
    currentBorrowers: currentBorrowers.take(30).toList(),
    overdueBorrowers: overdueRows.take(30).toList(),
    onTimeReturnRate: onTimeRate,
    avgBorrowDaysReturned: avgDays,
  );
}

/// Chuẩn hoá dữ liệu biểu đồ cột (0..1).
List<double> normalizeBars(List<int> values) {
  if (values.isEmpty) return [];
  final mx = values.reduce(math.max);
  if (mx <= 0) return List.filled(values.length, 0.0);
  return values.map((v) => v / mx).toList();
}

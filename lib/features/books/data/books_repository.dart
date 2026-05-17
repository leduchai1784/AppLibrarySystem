import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/firestore_query_limit.dart';
import '../../../core/utils/fold_search_text.dart';
import '../domain/book_list_query.dart';

typedef BookDoc = QueryDocumentSnapshot<Map<String, dynamic>>;

class BooksPage {
  final List<BookDoc> docs;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
  const BooksPage({
    required this.docs,
    required this.lastDoc,
    required this.hasMore,
  });
}

/// Firestore repository for books list with server-side filtering and indexed sorting.
class BooksRepository {
  final FirebaseFirestore _db;
  BooksRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  static const int defaultPageSize = 40;

  Query<Map<String, dynamic>> _applySort(
    Query<Map<String, dynamic>> q,
    BookSortKey sortKey,
  ) {
    switch (sortKey) {
      case BookSortKey.created:
        return q.orderBy('createdAt', descending: true);
      case BookSortKey.author:
        return q.orderBy('author');
      case BookSortKey.category:
        return q.orderBy('category');
      case BookSortKey.available:
        return q.orderBy('availableQuantity', descending: true);
      case BookSortKey.title:
        return q.orderBy('title');
    }
  }

  Query<Map<String, dynamic>> _baseQuery(BookListQuery query) {
    Query<Map<String, dynamic>> q = _db.collection('books');
    if (query.category != null && query.category!.trim().isNotEmpty) {
      q = q.where('category', isEqualTo: query.category);
    }
    return q;
  }

  static bool docMatchesFoldedSearch(
    BookDoc doc,
    String rawSearch,
  ) {
    final tokens = searchTokens(rawSearch);
    if (tokens.isEmpty) return true;
    final d = doc.data();
    final hay = [
      d['title'],
      d['author'],
      d['isbn'],
      d['category'],
      d['description'],
    ].map((e) => '${e ?? ''}').join(' ');
    return foldedMatchesAllTokens(hay, rawSearch);
  }

  Query<Map<String, dynamic>> _buildQuery(BookListQuery query) {
    final q = _baseQuery(query);
    final s = query.normalizedSearch;
    if (s.isNotEmpty && query.isIsbnLike) {
      return q.where('isbn', isEqualTo: s.replaceAll(' ', ''));
    }
    return _applySort(q, query.sortKey);
  }

  /// Lọc client theo [fold_search_text] — Firestore không bỏ dấu tiếng Việt.
  Future<BooksPage> _fetchWithFoldedClientFilter({
    required BookListQuery query,
    required int pageSize,
    required DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final filtered = <BookDoc>[];
    var cursor = startAfter;
    var hasMore = true;
    const maxRounds = 8;

    for (var round = 0; round < maxRounds && filtered.length < pageSize && hasMore; round++) {
      var q = _buildQuery(query).limit(firestoreQueryLimit(pageSize));
      if (cursor != null) {
        q = q.startAfterDocument(cursor);
      }
      final snap = await q.get();
      if (snap.docs.isEmpty) {
        hasMore = false;
        break;
      }
      for (final doc in snap.docs) {
        if (docMatchesFoldedSearch(doc, query.searchText)) {
          filtered.add(doc);
          if (filtered.length >= pageSize) break;
        }
      }
      cursor = snap.docs.last;
      hasMore = snap.docs.length >= pageSize;
    }

    return BooksPage(
      docs: filtered,
      lastDoc: cursor,
      hasMore: hasMore,
    );
  }

  Future<BooksPage> fetchNextPage({
    required BookListQuery query,
    required int pageSize,
    required DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final s = query.normalizedSearch;
    if (s.isNotEmpty && !query.isIsbnLike) {
      return _fetchWithFoldedClientFilter(
        query: query,
        pageSize: pageSize,
        startAfter: startAfter,
      );
    }

    var q = _buildQuery(query).limit(firestoreQueryLimit(pageSize));
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    final snap = await q.get();
    final docs = snap.docs;
    final last = docs.isNotEmpty ? docs.last : startAfter;
    final hasMore = docs.length == pageSize;
    return BooksPage(docs: docs, lastDoc: last, hasMore: hasMore);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchCategoriesOnce() {
    return _db.collection('categories').get();
  }
}

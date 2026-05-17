import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/books_repository.dart';
import '../domain/book_list_query.dart';

@immutable
class BookListState {
  final BookListQuery query;
  final List<BookDoc> docs;
  final bool loadingFirstPage;
  final bool loadingNextPage;
  final bool hasMore;
  final int totalQuantityInLoaded;
  final int totalAvailableInLoaded;
  final Object? error;

  const BookListState({
    required this.query,
    required this.docs,
    required this.loadingFirstPage,
    required this.loadingNextPage,
    required this.hasMore,
    required this.totalQuantityInLoaded,
    required this.totalAvailableInLoaded,
    required this.error,
  });

  const BookListState.initial(this.query)
    : docs = const [],
      loadingFirstPage = true,
      loadingNextPage = false,
      hasMore = true,
      totalQuantityInLoaded = 0,
      totalAvailableInLoaded = 0,
      error = null;

  BookListState copyWith({
    BookListQuery? query,
    List<BookDoc>? docs,
    bool? loadingFirstPage,
    bool? loadingNextPage,
    bool? hasMore,
    int? totalQuantityInLoaded,
    int? totalAvailableInLoaded,
    Object? Function()? error,
  }) {
    return BookListState(
      query: query ?? this.query,
      docs: docs ?? this.docs,
      loadingFirstPage: loadingFirstPage ?? this.loadingFirstPage,
      loadingNextPage: loadingNextPage ?? this.loadingNextPage,
      hasMore: hasMore ?? this.hasMore,
      totalQuantityInLoaded:
          totalQuantityInLoaded ?? this.totalQuantityInLoaded,
      totalAvailableInLoaded:
          totalAvailableInLoaded ?? this.totalAvailableInLoaded,
      error: error != null ? error() : this.error,
    );
  }
}

/// ChangeNotifier controller with in-memory cache per query.
///
/// Goal: avoid duplicate fetch calls and minimize Firestore reads while
/// supporting pagination and quick back/forward between query states.
class BookListController extends ChangeNotifier {
  final BooksRepository _repo;
  final int _pageSize;

  BookListController({
    required BooksRepository repo,
    int pageSize = BooksRepository.defaultPageSize,
    BookListQuery? initialQuery,
  }) : _repo = repo,
       _pageSize = pageSize,
       _state = BookListState.initial(
         initialQuery ??
             const BookListQuery(
               category: null,
               searchText: '',
               sortKey: BookSortKey.title,
             ),
       );

  BookListState _state;
  BookListState get state => _state;

  // Cache keyed by query.
  final Map<BookListQuery, _CachedQueryState> _cache =
      <BookListQuery, _CachedQueryState>{};

  int _requestEpoch = 0;

  Future<void> setQuery(BookListQuery q) async {
    if (q == _state.query) return;
    _state = _state.copyWith(query: q, error: () => null);
    notifyListeners();

    final cached = _cache[q];
    if (cached != null) {
      _state = _state.copyWith(
        docs: cached.docs,
        hasMore: cached.hasMore,
        loadingFirstPage: cached.loadingFirstPage,
        loadingNextPage: false,
        error: () => cached.error,
      );
      notifyListeners();
      if (cached.docs.isEmpty && cached.loadingFirstPage) {
        await refresh();
      }
      return;
    }

    _cache[q] = _CachedQueryState.empty();
    await refresh();
  }

  Future<void> refresh() async {
    final epoch = ++_requestEpoch;
    final q = _state.query;

    final cached = _cache.putIfAbsent(q, _CachedQueryState.empty);
    cached
      ..docs = <BookDoc>[]
      ..lastDoc = null
      ..hasMore = true
      ..loadingFirstPage = true
      ..loadingNextPage = false
      ..error = null;

    _state = _state.copyWith(
      docs: const [],
      hasMore: true,
      loadingFirstPage: true,
      loadingNextPage: false,
      totalQuantityInLoaded: 0,
      totalAvailableInLoaded: 0,
      error: () => null,
    );
    notifyListeners();

    try {
      final page = await _repo.fetchNextPage(
        query: q,
        pageSize: _pageSize,
        startAfter: null,
      );
      if (epoch != _requestEpoch) return; // stale

      cached.docs = List<BookDoc>.from(page.docs);
      cached.lastDoc = page.lastDoc;
      cached.hasMore = page.hasMore;
      cached.loadingFirstPage = false;
      cached.error = null;

      final totals = _computeTotals(cached.docs);
      _state = _state.copyWith(
        docs: cached.docs,
        hasMore: cached.hasMore,
        loadingFirstPage: false,
        totalQuantityInLoaded: totals.$1,
        totalAvailableInLoaded: totals.$2,
        error: () => null,
      );
      notifyListeners();
    } catch (e) {
      if (epoch != _requestEpoch) return;
      cached.loadingFirstPage = false;
      cached.error = e;
      _state = _state.copyWith(loadingFirstPage: false, error: () => e);
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    final q = _state.query;
    final cached = _cache.putIfAbsent(q, _CachedQueryState.empty);
    if (!cached.hasMore || cached.loadingFirstPage || cached.loadingNextPage)
      return;

    final epoch = ++_requestEpoch;
    cached.loadingNextPage = true;
    _state = _state.copyWith(loadingNextPage: true);
    notifyListeners();

    try {
      final page = await _repo.fetchNextPage(
        query: q,
        pageSize: _pageSize,
        startAfter: cached.lastDoc,
      );
      if (epoch != _requestEpoch) return;

      cached.docs = <BookDoc>[...cached.docs, ...page.docs];
      cached.lastDoc = page.lastDoc;
      cached.hasMore = page.hasMore;
      cached.loadingNextPage = false;
      cached.error = null;

      final totals = _computeTotals(cached.docs);
      _state = _state.copyWith(
        docs: cached.docs,
        hasMore: cached.hasMore,
        loadingNextPage: false,
        totalQuantityInLoaded: totals.$1,
        totalAvailableInLoaded: totals.$2,
        error: () => null,
      );
      notifyListeners();
    } catch (e) {
      if (epoch != _requestEpoch) return;
      cached.loadingNextPage = false;
      cached.error = e;
      _state = _state.copyWith(loadingNextPage: false, error: () => e);
      notifyListeners();
    }
  }

  (int totalQty, int totalAvail) _computeTotals(List<BookDoc> docs) {
    var qty = 0;
    var avail = 0;
    for (final d in docs) {
      final data = d.data();
      final q = (data['quantity'] ?? 0);
      final a = (data['availableQuantity'] ?? data['available'] ?? q);
      if (q is int) {
        qty += q;
      } else if (q is num) {
        qty += q.toInt();
      }
      if (a is int) {
        avail += a;
      } else if (a is num) {
        avail += a.toInt();
      }
    }
    return (qty, avail);
  }
}

class _CachedQueryState {
  List<BookDoc> docs;
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  bool hasMore;
  bool loadingFirstPage;
  bool loadingNextPage;
  Object? error;

  _CachedQueryState({
    required this.docs,
    required this.lastDoc,
    required this.hasMore,
    required this.loadingFirstPage,
    required this.loadingNextPage,
    required this.error,
  });

  factory _CachedQueryState.empty() => _CachedQueryState(
    docs: <BookDoc>[],
    lastDoc: null,
    hasMore: true,
    loadingFirstPage: false,
    loadingNextPage: false,
    error: null,
  );
}

import 'package:flutter/foundation.dart';

enum BookSortKey { title, author, category, available, created }

@immutable
class BookListQuery {
  final String? category; // null = all
  final String searchText; // raw user input
  final BookSortKey sortKey;

  const BookListQuery({
    required this.category,
    required this.searchText,
    required this.sortKey,
  });

  BookListQuery copyWith({
    String? Function()? category,
    String? searchText,
    BookSortKey? sortKey,
  }) {
    return BookListQuery(
      category: category != null ? category() : this.category,
      searchText: searchText ?? this.searchText,
      sortKey: sortKey ?? this.sortKey,
    );
  }

  String get normalizedSearch => searchText.trim();

  bool get hasSearch => normalizedSearch.isNotEmpty;

  /// Heuristic: ISBN tends to be digits + '-' and relatively short.
  bool get isIsbnLike {
    final s = normalizedSearch;
    if (s.isEmpty) return false;
    if (s.length > 20) return false;
    for (final ch in s.codeUnits) {
      final c = String.fromCharCode(ch);
      final ok =
          (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) ||
          c == '-' ||
          c == ' ';
      if (!ok) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is BookListQuery &&
        other.category == category &&
        other.searchText.trim() == searchText.trim() &&
        other.sortKey == sortKey;
  }

  @override
  int get hashCode => Object.hash(category, searchText.trim(), sortKey);
}

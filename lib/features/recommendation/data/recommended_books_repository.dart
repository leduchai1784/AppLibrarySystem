import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO nhẹ cho UI (cache-friendly).
class RecommendedBookLite {
  final String id;
  final String title;
  final String author;
  final String imageUrl;

  const RecommendedBookLite({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  factory RecommendedBookLite.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RecommendedBookLite(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      author: (data['author'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
    );
  }
}

class RecommendedBooksState {
  final bool loading;
  final Object? error;
  final List<String> ids;
  final List<RecommendedBookLite> books; // đã sort theo ids

  const RecommendedBooksState({
    required this.loading,
    required this.error,
    required this.ids,
    required this.books,
  });

  const RecommendedBooksState.loading()
      : loading = true,
        error = null,
        ids = const [],
        books = const [];

  const RecommendedBooksState.empty()
      : loading = false,
        error = null,
        ids = const [],
        books = const [];
}

/// Data layer: gộp stream recommendations + stream books, có cache và giảm jank.
///
/// Firestore schema:
/// - users/{uid}/recommendations/home: { recommendedBookIds: string[] }
/// - books/{bookId}: { title, author, imageUrl, ... }
class RecommendedBooksRepository {
  final FirebaseFirestore _db;

  RecommendedBooksRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final Map<String, RecommendedBookLite> _bookCache = <String, RecommendedBookLite>{};

  Stream<RecommendedBooksState> watchHomeRecommendations(String uid) {
    final controller = StreamController<RecommendedBooksState>.broadcast();

    StreamSubscription? recSub;
    StreamSubscription? booksSub;

    List<String> currentIds = const [];
    var gotRec = false;
    var gotBooks = false;

    void emit({Object? error}) {
      final books = <RecommendedBookLite>[];
      for (final id in currentIds) {
        final hit = _bookCache[id];
        if (hit != null) books.add(hit);
      }
      // Nếu chưa có docs (do security rules / deleted), vẫn trả list theo cache hiện có.
      controller.add(
        RecommendedBooksState(
          loading: !(gotRec && (currentIds.isEmpty || gotBooks)),
          error: error,
          ids: currentIds,
          books: books,
        ),
      );
    }

    controller.onListen = () {
      controller.add(const RecommendedBooksState.loading());

      recSub = _db
          .collection('users')
          .doc(uid)
          .collection('recommendations')
          .doc('home')
          .snapshots()
          .listen(
        (doc) {
          gotRec = true;
          final data = doc.data();
          final raw = (data?['recommendedBookIds'] as List?) ?? const [];
          final ids = raw
              .where((e) => e != null)
              .map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList();

          final limited = ids.length > 10 ? ids.sublist(0, 10) : ids;
          if (_sameList(currentIds, limited)) {
            emit();
            return;
          }

          currentIds = limited;
          gotBooks = false;

          booksSub?.cancel();
          booksSub = null;

          if (currentIds.isEmpty) {
            emit();
            return;
          }

          // Stream books realtime theo danh sách ids. (whereIn max 10)
          booksSub = _db
              .collection('books')
              .where(FieldPath.documentId, whereIn: currentIds)
              .snapshots()
              .listen(
            (snap) {
              gotBooks = true;
              for (final d in snap.docs) {
                _bookCache[d.id] = RecommendedBookLite.fromDoc(d);
              }
              emit();
            },
            onError: (e) {
              gotBooks = true;
              emit(error: e);
            },
          );

          emit();
        },
        onError: (e) {
          gotRec = true;
          currentIds = const [];
          booksSub?.cancel();
          booksSub = null;
          emit(error: e);
        },
      );
    };

    controller.onCancel = () async {
      await recSub?.cancel();
      await booksSub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }
}

bool _sameList(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}


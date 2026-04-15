import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'book_cover_display.dart';

/// Ảnh bìa từ `books/{bookId}.imageUrl` (URL hoặc data URL). Fetch một lần mỗi [bookId].
class BookCoverFromBookId extends StatefulWidget {
  const BookCoverFromBookId({
    super.key,
    required this.bookId,
    this.width = 48,
    this.height = 64,
    this.borderRadius,
  });

  final String bookId;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<BookCoverFromBookId> createState() => _BookCoverFromBookIdState();
}

class _BookCoverFromBookIdState extends State<BookCoverFromBookId> {
  Future<DocumentSnapshot<Map<String, dynamic>>>? _future;

  Future<DocumentSnapshot<Map<String, dynamic>>>? _loadFuture() {
    if (widget.bookId.isEmpty) return null;
    return FirebaseFirestore.instance.collection('books').doc(widget.bookId).get();
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFuture();
  }

  @override
  void didUpdateWidget(BookCoverFromBookId oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      _future = _loadFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(8);
    final w = widget.width;
    final h = widget.height;

    if (widget.bookId.isEmpty || _future == null) {
      return buildBookCoverDisplay(
        imageRef: '',
        width: w,
        height: h,
        borderRadius: radius,
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        final url = (snap.data?.data()?['imageUrl'] ?? '').toString().trim();
        return buildBookCoverDisplay(
          imageRef: url,
          width: w,
          height: h,
          borderRadius: radius,
        );
      },
    );
  }
}

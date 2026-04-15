import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowRecord {
  final String id;
  final String userId;
  final String bookId;
  final DateTime? borrowDate;
  final DateTime? dueDate;
  final DateTime? returnDate;
  final String status; // borrowing | returned | late

  const BorrowRecord({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.borrowDate,
    required this.dueDate,
    required this.returnDate,
    required this.status,
  });

  factory BorrowRecord.fromMap(String id, Map<String, dynamic> data) {
    return BorrowRecord(
      id: id,
      userId: (data['userId'] ?? '') as String,
      bookId: (data['bookId'] ?? '') as String,
      borrowDate: (data['borrowDate'] as Timestamp?)?.toDate(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
      status: (data['status'] ?? 'borrowing') as String,
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/borrow_policy.dart';
import '../gen/l10n/app_localizations.dart';
import 'library_config_service.dart';
import '../models/book.dart';

/// Mã lỗi nghiệp vụ — UI map sang [AppLocalizations] (không phụ thuộc ngôn ngữ cố định trong message).
class BorrowReturnException implements Exception {
  BorrowReturnException(this.code);
  final String code;
  @override
  String toString() => code;
}

class BorrowReturnService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<AppLocalizations> _l10n() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString('web_locale') ?? 'vi';
    return lookupAppLocalizations(Locale(code));
  }

  static String _formatDue(AppLocalizations loc, DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final y = d.year.toString();
    return loc.localeName.startsWith('en') ? '$month/$day/$y' : '$day/$month/$y';
  }

  /// `notifyBorrowReminders` trên `users/{uid}` — mặc định true nếu chưa có field.
  static Future<bool> userWantsBorrowNotifications(String userId) async {
    try {
      final snap = await _db.collection('users').doc(userId).get();
      final v = snap.data()?['notifyBorrowReminders'];
      if (v is bool) return v;
      return true;
    } catch (_) {
      return true;
    }
  }

  static Future<Book> getBookById(String bookId) async {
    final snap = await _db.collection('books').doc(bookId).get();
    if (!snap.exists) {
      throw BorrowReturnException('book_not_found');
    }
    final data = snap.data();
    if (data == null) throw BorrowReturnException('invalid_book_data');
    return Book.fromMap(snap.id, data);
  }

  static Future<Book?> getBookByIsbn(String isbn) async {
    final q = await _db.collection('books').where('isbn', isEqualTo: isbn).limit(1).get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    return Book.fromMap(doc.id, doc.data());
  }

  static Future<bool> hasActiveBorrow({
    required String userId,
    required String bookId,
  }) async {
    final q = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'borrowing')
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  static Future<void> borrowBook({
    required String userId,
    required String bookId,
    int loanDays = BorrowPolicy.defaultLoanDays,
    DateTime? dueDate,
  }) async {
    final bookRef = _db.collection('books').doc(bookId);
    final borrowRef = _db.collection('borrow_records').doc();

    final DateTime resolvedDue = dueDate != null
        ? DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59)
        : DateTime.now().add(Duration(days: BorrowPolicy.clampToLoanRange(loanDays)));
    final bookPre = await bookRef.get();
    final bookTitle = (bookPre.data()?['title'] ?? '') as Object;

    final dup = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'borrowing')
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw BorrowReturnException('already_borrowing');
    }

    final maxActive = await LibraryConfigService.maxActiveBorrowsPerUser();
    final borrowingAll = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'borrowing')
        .get();
    if (borrowingAll.docs.length >= maxActive) {
      throw BorrowReturnException('max_active_borrows');
    }

    await _db.runTransaction((tx) async {
      final bookSnap = await tx.get(bookRef);
      final bookData = bookSnap.data();
      if (bookData == null) throw BorrowReturnException('book_not_found');

      final quantity = (bookData['quantity'] ?? 0) as int;
      final available = (bookData['availableQuantity'] ?? bookData['available'] ?? quantity) as int;

      if (available <= 0) {
        throw BorrowReturnException('out_of_stock');
      }

      tx.update(bookRef, {
        'availableQuantity': available - 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(borrowRef, {
        'userId': userId,
        'bookId': bookId,
        // Snapshot để lịch sử vẫn hiển thị khi sách bị xóa.
        'bookTitleSnapshot': (bookData['title'] ?? '').toString(),
        'bookAuthorSnapshot': (bookData['author'] ?? '').toString(),
        'bookImageUrlSnapshot': (bookData['imageUrl'] ?? '').toString(),
        'borrowDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(resolvedDue),
        'returnDate': null,
        'status': 'borrowing',
        'fineAmount': 0,
      });
    });

    try {
      if (await userWantsBorrowNotifications(userId)) {
        final loc = await _l10n();
        await _db.collection('notifications').add({
          'userId': userId,
          'title': loc.notifBorrowSuccessTitle,
          'body': loc.notifBorrowSuccessBody('$bookTitle', _formatDue(loc, resolvedDue)),
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    } catch (_) {}
  }

  static Future<void> returnBook({
    required String userId,
    required String bookId,
  }) async {
    final bookRef = _db.collection('books').doc(bookId);

    final q = await _db
        .collection('borrow_records')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'borrowing')
        .limit(1)
        .get();
    if (q.docs.isEmpty) {
      throw BorrowReturnException('no_active_borrow');
    }
    final recordDoc = q.docs.first;
    final recordRef = _db.collection('borrow_records').doc(recordDoc.id);
    final due = (recordDoc.data()['dueDate'] as Timestamp?)?.toDate();
    final borrowerId = (recordDoc.data()['userId'] ?? userId) as String;

    final now = DateTime.now();
    final lateDays = due == null ? 0 : _daysLate(due, now);
    final status = lateDays > 0 ? 'late' : 'returned';

    final bookTitleSnap = await bookRef.get();
    final bookTitle = (bookTitleSnap.data()?['title'] ?? '') as Object;

    await _db.runTransaction((tx) async {
      final bookSnap = await tx.get(bookRef);
      final bookData = bookSnap.data();
      if (bookData == null) throw BorrowReturnException('book_not_found');

      final quantity = (bookData['quantity'] ?? 0) as int;
      final available = (bookData['availableQuantity'] ?? bookData['available'] ?? quantity) as int;

      tx.update(bookRef, {
        'availableQuantity': available + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.update(recordRef, {
        'returnDate': FieldValue.serverTimestamp(),
        'status': status,
      });
    });

    try {
      if (await userWantsBorrowNotifications(borrowerId)) {
        final loc = await _l10n();
        final title = status == 'late' ? loc.notifReturnLateTitle : loc.notifReturnOnTimeTitle;
        final body = status == 'late'
            ? loc.notifReturnLateBody('$bookTitle', '$lateDays')
            : loc.notifReturnOnTimeBody('$bookTitle');
        await _db.collection('notifications').add({
          'userId': borrowerId,
          'title': title,
          'body': body,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }
    } catch (_) {}
  }

  static int _daysLate(DateTime due, DateTime now) {
    final dueDateOnly = DateTime(due.year, due.month, due.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final diff = nowDateOnly.difference(dueDateOnly).inDays;
    return diff > 0 ? diff : 0;
  }
}

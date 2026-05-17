import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:library_system/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection('books').limit(5).get();

  print('--- BOOK URLS ---');
  for (var doc in snapshot.docs) {
    print(doc.data()['imageUrl']);
  }
  print('-----------------');
}

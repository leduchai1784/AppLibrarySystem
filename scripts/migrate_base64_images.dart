import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:library_system/firebase_options.dart';
import 'package:library_system/services/cloudinary_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MigrationApp());
}

class MigrationApp extends StatelessWidget {
  const MigrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Migrate Base64 Images')),
        body: const MigrationScreen(),
      ),
    );
  }
}

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final List<String> logs = [];
  bool isMigrating = false;

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _isLoggingIn = false;

  void log(String message) {
    setState(() {
      logs.add(
        '${DateTime.now().toIso8601String().substring(11, 19)} - $message',
      );
    });
    debugPrint(message);
  }

  Future<void> startMigration() async {
    setState(() {
      isMigrating = true;
      logs.clear();
    });

    log('Starting migration...');

    try {
      final db = FirebaseFirestore.instance;
      // Fetch all books (as filtering by 'startsWith' locally is needed for data:image)
      QuerySnapshot snapshot = await db.collection('books').get();
      log('Found ${snapshot.docs.length} books in total.');

      final toMigrate = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final String imageUrl = data['imageUrl'] ?? '';
        return imageUrl.startsWith('data:image');
      }).toList();

      log('Found ${toMigrate.length} books with base64 imageUrl.');

      int successCount = 0;
      int errorCount = 0;

      // Batch of 10
      for (int i = 0; i < toMigrate.length; i += 10) {
        final batchDocs = toMigrate.skip(i).take(10).toList();
        log('Processing batch ${i ~/ 10 + 1} (${batchDocs.length} items)...');

        final futures = batchDocs.map((doc) async {
          final docId = doc.id;
          final data = doc.data() as Map<String, dynamic>;
          final String base64Url = data['imageUrl'];

          try {
            final commaIndex = base64Url.indexOf(',');
            if (commaIndex <= 0) throw Exception('Invalid base64 string');

            final bytes = base64Decode(base64Url.substring(commaIndex + 1));
            final sizeKb = (bytes.length / 1024).toStringAsFixed(1);
            log('Doc $docId: Uploading ${sizeKb}KB...');

            final cloudinaryUrl = await CloudinaryService.uploadBookCoverBytes(
              bytes: bytes,
              filename: 'book_cover_$docId.jpg',
            );

            await db.collection('books').doc(docId).update({
              'imageUrl': cloudinaryUrl,
            });

            log('Doc $docId: Success -> $cloudinaryUrl');
            return true;
          } catch (e) {
            log('Doc $docId: ERROR - $e');
            return false;
          }
        });

        final results = await Future.wait(futures);
        successCount += results.where((r) => r).length;
        errorCount += results.where((r) => !r).length;

        // Brief pause to avoid rate limits
        await Future.delayed(const Duration(milliseconds: 500));
      }

      log('Migration completed! Success: $successCount, Errors: $errorCount');
    } catch (e) {
      log('Fatal error during migration: $e');
    } finally {
      setState(() {
        isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user == null) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Admin Login Required for Migration',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _pwdCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 16),
                if (_isLoggingIn)
                  const CircularProgressIndicator()
                else
                  FilledButton(
                    onPressed: () async {
                      setState(() => _isLoggingIn = true);
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: _emailCtrl.text.trim(),
                          password: _pwdCtrl.text.trim(),
                        );
                      } catch (e) {
                        log('Login failed: $e');
                      }
                      if (mounted) setState(() => _isLoggingIn = false);
                    },
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                Text(
                  logs.isNotEmpty ? logs.last : '',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Logged in as: ${user.email}'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: isMigrating ? null : startMigration,
                child: Text(isMigrating ? 'Migrating...' : 'Start Migration'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Text(
                      logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

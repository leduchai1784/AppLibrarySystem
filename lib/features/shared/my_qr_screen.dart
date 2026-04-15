import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/utils/library_qr_payload.dart';
import '../../gen/l10n/app_localizations.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.myQrTitle)),
        body: Center(child: Text(t.commonSignIn)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.myQrTitle)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snap) {
          final theme = Theme.of(context);
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data?.data() ?? const <String, dynamic>{};
          final fullName = (data['fullName'] ?? '').toString().trim();
          final studentCode = (data['studentCode'] ?? '').toString().trim();
          final payload = LibraryQrPayload.userForBorrow(uid);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            fullName.isEmpty ? t.myQrDefaultDisplayName : fullName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            studentCode.isEmpty ? uid : studentCode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: QrImageView(
                              data: payload,
                              size: 220,
                              version: QrVersions.auto,
                              gapless: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SelectableText(
                            payload,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.myQrHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


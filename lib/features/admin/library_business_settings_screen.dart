import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/borrow_policy.dart';
import '../../services/audit_log_service.dart';
import '../../services/library_config_service.dart';
import '../../gen/l10n/app_localizations.dart';

/// Cấu hình `library_settings/config` — chỉ Admin (Firestore rule).
class LibraryBusinessSettingsScreen extends StatefulWidget {
  const LibraryBusinessSettingsScreen({super.key});

  @override
  State<LibraryBusinessSettingsScreen> createState() => _LibraryBusinessSettingsScreenState();
}

class _LibraryBusinessSettingsScreenState extends State<LibraryBusinessSettingsScreen> {
  final _loanDaysCtrl = TextEditingController();
  final _maxBorrowCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void dispose() {
    _loanDaysCtrl.dispose();
    _maxBorrowCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final m = await LibraryConfigService.getConfigMap();
      final ld = m['loanDays'];
      final mx = m['maxActiveBorrowsPerUser'];
      if (!mounted) return;
      _loanDaysCtrl.text = (ld is int && ld > 0)
          ? '$ld'
          : '${BorrowPolicy.defaultLoanDays}';
      _maxBorrowCtrl.text = (mx is int && mx > 0) ? '$mx' : '5';
    } catch (_) {
      _loanDaysCtrl.text = '${BorrowPolicy.defaultLoanDays}';
      _maxBorrowCtrl.text = '5';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isAdmin) return;

    final ld = int.tryParse(_loanDaysCtrl.text.trim());
    final mx = int.tryParse(_maxBorrowCtrl.text.trim());
    if (ld == null || ld < BorrowPolicy.suggestedMinDays || ld > BorrowPolicy.suggestedMaxDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.libraryConfigLoanDaysInvalid)),
      );
      return;
    }
    if (mx == null || mx < 1 || mx > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.libraryConfigMaxBorrowsInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await LibraryConfigService.configRef.set(
        {
          'loanDays': ld,
          'maxActiveBorrowsPerUser': mx,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
        },
        SetOptions(merge: true),
      );
      await AuditLogService.libraryConfigSaved('loanDays=$ld maxActiveBorrowsPerUser=$mx');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.libraryConfigSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.libraryConfigSaveError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!AppUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(t.libraryBusinessSettingsTitle)),
        body: Center(child: Text(t.adminOnlyLibraryConfig)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.libraryBusinessSettingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.libraryBusinessSettingsSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _loanDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: t.libraryConfigLoanDaysLabel,
                          helperText: t.libraryConfigLoanDaysHelper(
                            BorrowPolicy.suggestedMinDays,
                            BorrowPolicy.suggestedMaxDays,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _maxBorrowCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: t.libraryConfigMaxBorrowsLabel,
                          helperText: t.libraryConfigMaxBorrowsHelper,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(t.libraryConfigSave),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

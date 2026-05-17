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
  State<LibraryBusinessSettingsScreen> createState() =>
      _LibraryBusinessSettingsScreenState();
}

class _LibraryBusinessSettingsScreenState
    extends State<LibraryBusinessSettingsScreen> {
  final _loanDaysCtrl = TextEditingController();
  final _maxBorrowCtrl = TextEditingController();
  final _fastApiBaseUrlCtrl = TextEditingController();
  final _fastApiRecoPathCtrl = TextEditingController();
  final _fastApiRecoTopKCtrl = TextEditingController();
  final _fastApiDevUidCtrl = TextEditingController();
  final _fastApiBookRecoPathCtrl = TextEditingController();
  final _fastApiBookRecoTopKCtrl = TextEditingController();
  final _cloudinaryCloudNameCtrl = TextEditingController();
  final _cloudinaryUploadPresetCtrl = TextEditingController();
  final _cloudinaryFolderCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void dispose() {
    _loanDaysCtrl.dispose();
    _maxBorrowCtrl.dispose();
    _fastApiBaseUrlCtrl.dispose();
    _fastApiRecoPathCtrl.dispose();
    _fastApiRecoTopKCtrl.dispose();
    _fastApiDevUidCtrl.dispose();
    _fastApiBookRecoPathCtrl.dispose();
    _fastApiBookRecoTopKCtrl.dispose();
    _cloudinaryCloudNameCtrl.dispose();
    _cloudinaryUploadPresetCtrl.dispose();
    _cloudinaryFolderCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final m = await LibraryConfigService.getConfigMap();
      final ld = m['loanDays'];
      final mx = m['maxActiveBorrowsPerUser'];
      final fastApi = m['fastApiBaseUrl'];
      final recoPath = m['fastApiRecommendationsPath'];
      final recoTopK = m['fastApiRecommendationsTopK'];
      final devUid = m['fastApiDevUid'];
      final bookRecoPath = m['fastApiBookRecommendPath'];
      final bookRecoTopK = m['fastApiBookRecommendTopK'];
      final cloudName = m['cloudinaryCloudName'];
      final preset = m['cloudinaryUploadPreset'];
      final folder = m['cloudinaryFolder'];
      if (!mounted) return;
      _loanDaysCtrl.text = (ld is int && ld > 0)
          ? '$ld'
          : '${BorrowPolicy.defaultLoanDays}';
      _maxBorrowCtrl.text = (mx is int && mx > 0) ? '$mx' : '5';
      _fastApiBaseUrlCtrl.text = fastApi is String ? fastApi.trim() : '';
      _fastApiRecoPathCtrl.text = recoPath is String ? recoPath.trim() : '';
      if (recoTopK is int && recoTopK > 0) {
        _fastApiRecoTopKCtrl.text = '$recoTopK';
      } else if (recoTopK is num) {
        _fastApiRecoTopKCtrl.text = '${recoTopK.round()}';
      } else {
        _fastApiRecoTopKCtrl.text = '';
      }
      _fastApiDevUidCtrl.text = devUid is String ? devUid.trim() : '';
      _fastApiBookRecoPathCtrl.text = bookRecoPath is String
          ? bookRecoPath.trim()
          : '';
      if (bookRecoTopK is int && bookRecoTopK > 0) {
        _fastApiBookRecoTopKCtrl.text = '$bookRecoTopK';
      } else if (bookRecoTopK is num) {
        _fastApiBookRecoTopKCtrl.text = '${bookRecoTopK.round()}';
      } else {
        _fastApiBookRecoTopKCtrl.text = '';
      }
      _cloudinaryCloudNameCtrl.text = cloudName is String
          ? cloudName.trim()
          : '';
      _cloudinaryUploadPresetCtrl.text = preset is String ? preset.trim() : '';
      _cloudinaryFolderCtrl.text = folder is String ? folder.trim() : '';
    } catch (_) {
      _loanDaysCtrl.text = '${BorrowPolicy.defaultLoanDays}';
      _maxBorrowCtrl.text = '5';
      _fastApiBaseUrlCtrl.text = '';
      _fastApiRecoPathCtrl.text = '';
      _fastApiRecoTopKCtrl.text = '';
      _fastApiDevUidCtrl.text = '';
      _fastApiBookRecoPathCtrl.text = '';
      _fastApiBookRecoTopKCtrl.text = '';
      _cloudinaryCloudNameCtrl.text = '';
      _cloudinaryUploadPresetCtrl.text = '';
      _cloudinaryFolderCtrl.text = '';
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
    final fastApiBaseUrl = _fastApiBaseUrlCtrl.text.trim();
    final fastApiRecoPath = _fastApiRecoPathCtrl.text.trim();
    final fastApiRecoTopKText = _fastApiRecoTopKCtrl.text.trim();
    final fastApiDevUid = _fastApiDevUidCtrl.text.trim();
    final fastApiBookRecoPath = _fastApiBookRecoPathCtrl.text.trim();
    final fastApiBookRecoTopKText = _fastApiBookRecoTopKCtrl.text.trim();
    final cloudinaryCloudName = _cloudinaryCloudNameCtrl.text.trim();
    final cloudinaryUploadPreset = _cloudinaryUploadPresetCtrl.text.trim();
    final cloudinaryFolder = _cloudinaryFolderCtrl.text.trim();
    if (ld == null ||
        ld < BorrowPolicy.suggestedMinDays ||
        ld > BorrowPolicy.suggestedMaxDays) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.libraryConfigLoanDaysInvalid)));
      return;
    }
    if (mx == null || mx < 1 || mx > 99) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.libraryConfigMaxBorrowsInvalid)));
      return;
    }
    if (fastApiBaseUrl.isNotEmpty) {
      final uri = Uri.tryParse(fastApiBaseUrl);
      final ok = uri != null && uri.hasScheme && uri.host.isNotEmpty;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.libraryConfigFastApiBaseUrlInvalid)),
        );
        return;
      }
    }
    if (fastApiRecoPath.isNotEmpty && fastApiRecoPath.contains('://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.libraryConfigFastApiRecommendationsPathInvalid),
        ),
      );
      return;
    }
    int? recoTopK;
    if (fastApiRecoTopKText.isEmpty) {
      recoTopK = null;
    } else {
      recoTopK = int.tryParse(fastApiRecoTopKText);
      if (recoTopK == null || recoTopK < 1 || recoTopK > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.libraryConfigFastApiRecommendationsTopKInvalid),
          ),
        );
        return;
      }
    }
    if (fastApiBookRecoPath.isNotEmpty && fastApiBookRecoPath.contains('://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.libraryConfigFastApiRecommendationsPathInvalid),
        ),
      );
      return;
    }
    int? bookRecoTopK;
    if (fastApiBookRecoTopKText.isEmpty) {
      bookRecoTopK = null;
    } else {
      bookRecoTopK = int.tryParse(fastApiBookRecoTopKText);
      if (bookRecoTopK == null || bookRecoTopK < 1 || bookRecoTopK > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.libraryConfigFastApiBookRecommendTopKInvalid),
          ),
        );
        return;
      }
    }

    final hasAnyCloudinary =
        cloudinaryCloudName.isNotEmpty ||
        cloudinaryUploadPreset.isNotEmpty ||
        cloudinaryFolder.isNotEmpty;
    if (hasAnyCloudinary) {
      if (cloudinaryCloudName.isEmpty || cloudinaryUploadPreset.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloudinary: cần đủ Cloud Name và Upload Preset.'),
          ),
        );
        return;
      }
      if (cloudinaryCloudName.trim().toLowerCase() ==
          cloudinaryUploadPreset.trim().toLowerCase()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cloudinary: Cloud Name KHÔNG phải Upload Preset. '
              'Cloud Name lấy trong Dashboard (mục Cloud name), còn Upload Preset là tên preset unsigned.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final updates = <String, dynamic>{
        'loanDays': ld,
        'maxActiveBorrowsPerUser': mx,
        'fastApiBaseUrl': fastApiBaseUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      };
      if (fastApiRecoPath.isEmpty) {
        updates['fastApiRecommendationsPath'] = FieldValue.delete();
      } else {
        updates['fastApiRecommendationsPath'] = fastApiRecoPath;
      }
      if (recoTopK == null) {
        updates['fastApiRecommendationsTopK'] = FieldValue.delete();
      } else {
        updates['fastApiRecommendationsTopK'] = recoTopK;
      }
      if (fastApiDevUid.isEmpty) {
        updates['fastApiDevUid'] = FieldValue.delete();
      } else {
        updates['fastApiDevUid'] = fastApiDevUid;
      }
      if (fastApiBookRecoPath.isEmpty) {
        updates['fastApiBookRecommendPath'] = FieldValue.delete();
      } else {
        updates['fastApiBookRecommendPath'] = fastApiBookRecoPath;
      }
      if (bookRecoTopK == null) {
        updates['fastApiBookRecommendTopK'] = FieldValue.delete();
      } else {
        updates['fastApiBookRecommendTopK'] = bookRecoTopK;
      }

      if (!hasAnyCloudinary) {
        updates['cloudinaryCloudName'] = FieldValue.delete();
        updates['cloudinaryUploadPreset'] = FieldValue.delete();
        updates['cloudinaryFolder'] = FieldValue.delete();
      } else {
        updates['cloudinaryCloudName'] = cloudinaryCloudName;
        updates['cloudinaryUploadPreset'] = cloudinaryUploadPreset;
        if (cloudinaryFolder.isEmpty) {
          updates['cloudinaryFolder'] = FieldValue.delete();
        } else {
          updates['cloudinaryFolder'] = cloudinaryFolder;
        }
      }

      await LibraryConfigService.configRef.set(
        updates,
        SetOptions(merge: true),
      );
      await AuditLogService.libraryConfigSaved(
        'loanDays=$ld maxActiveBorrowsPerUser=$mx fastApiBaseUrl=$fastApiBaseUrl recoPath=$fastApiRecoPath topK=$recoTopK bookReco=$fastApiBookRecoPath bookTopK=$bookRecoTopK devUid=${fastApiDevUid.isEmpty ? '' : 'set'} cloudinary=${hasAnyCloudinary ? 'set' : 'clear'}',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.libraryConfigSaved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.libraryConfigSaveError('$e'))));
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cloudinary (lưu ảnh bìa sách)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _cloudinaryCloudNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cloud Name',
                          helperText: 'Lấy trong Cloudinary Dashboard',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cloudinaryUploadPresetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Upload Preset (Unsigned)',
                          helperText: 'Ví dụ: librarysystembooks',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cloudinaryFolderCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Folder (optional)',
                          helperText: 'Ví dụ: library/books',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 22),
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiBaseUrlCtrl,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: t.libraryConfigFastApiBaseUrlLabel,
                          helperText: t.libraryConfigFastApiBaseUrlHelper,
                          border: const OutlineInputBorder(),
                          hintText: 'http://10.10.10.165:8000',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiRecoPathCtrl,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText:
                              t.libraryConfigFastApiRecommendationsPathLabel,
                          helperText:
                              t.libraryConfigFastApiRecommendationsPathHelper,
                          border: const OutlineInputBorder(),
                          hintText: 'recommend/me',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiRecoTopKCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              t.libraryConfigFastApiRecommendationsTopKLabel,
                          helperText:
                              t.libraryConfigFastApiRecommendationsTopKHelper,
                          border: const OutlineInputBorder(),
                          hintText: '10',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiDevUidCtrl,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: t.libraryConfigFastApiDevUidLabel,
                          helperText: t.libraryConfigFastApiDevUidHelper,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiBookRecoPathCtrl,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText:
                              t.libraryConfigFastApiBookRecommendPathLabel,
                          helperText:
                              t.libraryConfigFastApiBookRecommendPathHelper,
                          border: const OutlineInputBorder(),
                          hintText: 'recommend',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fastApiBookRecoTopKCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              t.libraryConfigFastApiBookRecommendTopKLabel,
                          helperText:
                              t.libraryConfigFastApiBookRecommendTopKHelper,
                          border: const OutlineInputBorder(),
                          hintText: '5',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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

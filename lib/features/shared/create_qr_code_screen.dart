import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình tạo QR code (phỏng theo mockup create_qr_code_screen)
class CreateQrCodeScreen extends StatefulWidget {
  const CreateQrCodeScreen({super.key});

  @override
  State<CreateQrCodeScreen> createState() => _CreateQrCodeScreenState();
}

class _CreateQrCodeScreenState extends State<CreateQrCodeScreen> {
  final _picker = ImagePicker();
  bool _syncedColorFromSettings = false;

  // 0: URL, 1: Text, 2: vCard, 3: WiFi, 4: Email
  int _typeIndex = 0;

  // Shared
  final _nameController = TextEditingController();
  Uint8List? _logoBytes;

  // URL
  String _url = '';

  // Text
  String _text = '';

  // vCard
  String _vcardFullName = '';
  String _vcardEmail = '';

  // WiFi
  String _wifiSsid = '';
  String _wifiPassword = '';

  // Email
  String _emailTo = '';
  String _emailSubject = '';
  String _emailBody = '';

  // QR customization
  Color _qrColor = Color(AppSettingsController.defaultQrColorArgb);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_syncedColorFromSettings) {
      _syncedColorFromSettings = true;
      final s = context.read<AppSettingsController>();
      setState(() => _qrColor = s.qrDefaultColor);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _payload {
    switch (_typeIndex) {
      case 0:
        return _url.trim();
      case 1:
        return _text.trim();
      case 2:
        return _buildVCard();
      case 3:
        return _buildWifiPayload();
      case 4:
        return _buildMailtoPayload();
      default:
        return _url.trim();
    }
  }

  String _buildVCard() {
    final name = _vcardFullName.trim();
    final email = _vcardEmail.trim();
    if (name.isEmpty && email.isEmpty) return '';
    // vCard basic format
    return [
      'BEGIN:VCARD',
      'VERSION:3.0',
      if (name.isNotEmpty) 'FN:$name',
      if (email.isNotEmpty) 'EMAIL:$email',
      'END:VCARD',
    ].join('\n');
  }

  String _buildWifiPayload() {
    final ssid = _wifiSsid.trim();
    final pass = _wifiPassword;
    if (ssid.isEmpty && pass.isEmpty) return '';
    final enc = pass.isNotEmpty ? 'WPA' : '';
    return 'WIFI:T:$enc;S:$ssid;P:$pass;;';
  }

  String _buildMailtoPayload() {
    final to = _emailTo.trim();
    if (to.isEmpty) return '';
    final subject = Uri.encodeComponent(_emailSubject.trim());
    final body = Uri.encodeComponent(_emailBody.trim());
    return 'mailto:$to?subject=$subject&body=$body';
  }

  Future<void> _pickLogo() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    if (!mounted) return;
    setState(() => _logoBytes = bytes);
  }

  void _onCreate() {
    final t = AppLocalizations.of(context)!;
    if (_payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.createQrEnterContent)),
      );
      return;
    }

    final name = _nameController.text.trim().isEmpty ? t.createQrUnnamed : _nameController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.createQrCreatedToast(name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final payload = _payload;
    final qrPreviewSize = context.watch<AppSettingsController>().qrDefaultPixelSize;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(t.createQrTitle),
        actions: [
          TextButton(
            onPressed: _onCreate,
            child: Text(t.createQrSave, style: const TextStyle(fontWeight: FontWeight.w800)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Type selector (tabs)
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final labels = [
                    t.createQrTypeUrl,
                    t.createQrTypeText,
                    t.createQrTypeVcard,
                    t.createQrTypeWifi,
                    t.createQrTypeEmail,
                  ];
                  final active = _typeIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _typeIndex = index),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? theme.colorScheme.primary : theme.cardColor,
                        borderRadius: BorderRadius.circular(999),
                        border: active
                            ? null
                            : Border.all(color: theme.dividerColor.withOpacity(0.65)),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: active ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildInputCard(theme),
                    const SizedBox(height: 14),
                    _buildCustomizationCard(theme),
                    const SizedBox(height: 14),
                    _buildPreviewCard(theme, payload, qrPreviewSize),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _onCreate,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.createQrActionButton, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.createQrContentTitle, style: AppTextStyles.h3),
            const SizedBox(height: 12),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.createQrNameLabel,
                hintText: t.createQrNameHint,
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),

            const SizedBox(height: 12),
            if (_typeIndex == 0)
              TextField(
                onChanged: (v) => _url = v,
                decoration: InputDecoration(
                  labelText: t.createQrUrlLabel,
                  hintText: t.createQrUrlHint,
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
            if (_typeIndex == 1)
              TextField(
                onChanged: (v) => _text = v,
                decoration: InputDecoration(
                  labelText: t.createQrTextLabel,
                  hintText: t.createQrTextHint,
                  prefixIcon: const Icon(Icons.text_fields),
                ),
                maxLines: 3,
              ),
            if (_typeIndex == 2) ...[
              TextField(
                onChanged: (v) => _vcardFullName = v,
                decoration: InputDecoration(
                  labelText: t.createQrVcardFullNameLabel,
                  hintText: t.createQrVcardFullNameHint,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _vcardEmail = v,
                decoration: InputDecoration(
                  labelText: t.createQrEmailLabel,
                  hintText: t.createQrEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
            ],
            if (_typeIndex == 3) ...[
              TextField(
                onChanged: (v) => _wifiSsid = v,
                decoration: InputDecoration(
                  labelText: t.createQrWifiSsidLabel,
                  hintText: t.createQrWifiSsidHint,
                  prefixIcon: const Icon(Icons.wifi),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _wifiPassword = v,
                decoration: InputDecoration(
                  labelText: t.createQrWifiPasswordLabel,
                  hintText: t.createQrWifiPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
            ],
            if (_typeIndex == 4) ...[
              TextField(
                onChanged: (v) => _emailTo = v,
                decoration: InputDecoration(
                  labelText: t.createQrEmailToLabel,
                  hintText: t.createQrEmailToHint,
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _emailSubject = v,
                decoration: InputDecoration(
                  labelText: t.createQrEmailSubjectLabel,
                  hintText: t.createQrEmailSubjectHint,
                  prefixIcon: const Icon(Icons.subject_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _emailBody = v,
                decoration: InputDecoration(
                  labelText: t.createQrEmailBodyLabel,
                  hintText: t.createQrEmailBodyHint,
                  prefixIcon: const Icon(Icons.message_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationCard(ThemeData theme) {
    final t = AppLocalizations.of(context)!;
    final colors = <Color>[
      const Color(0xFF000000),
      const Color(0xFF1e94f6),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.createQrDesignTitle, style: AppTextStyles.h3),
            const SizedBox(height: 12),

            Text(t.createQrColorLabel, style: AppTextStyles.caption),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in colors)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => setState(() => _qrColor = c),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _qrColor == c ? theme.colorScheme.primary : theme.dividerColor,
                              width: 2,
                            ),
                          ),
                          child: _qrColor == c
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Text(t.createQrLogoOptional, style: AppTextStyles.caption),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(t.createQrUploadLogo),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _logoBytes == null ? null : () => setState(() => _logoBytes = null),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, String payload, double qrSize) {
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.createQrPreviewTitle, style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withOpacity(0.55)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      QrImageView(
                        data: payload.isEmpty ? ' ' : payload,
                        size: qrSize,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        foregroundColor: _qrColor,
                      ),
                      if (_logoBytes != null)
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: Image.memory(_logoBytes!, fit: BoxFit.cover),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameController.text.trim().isEmpty
                        ? t.qrCreateCatalogDefaultTitle
                        : _nameController.text.trim(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    payload.isEmpty ? t.qrCreateEmptyPayload : payload,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


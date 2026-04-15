import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/settings/app_settings_controller.dart';
import '../../gen/l10n/app_localizations.dart';

/// Màn hình quét QR dùng chung (trả về rawValue qua Navigator.pop)
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    required this.title,
    this.hint,
  });

  final String title;
  final String? hint;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _handled = false;

  Future<void> _handleTapToFocus(TapDownDetails details, Size size) async {
    final settings = context.read<AppSettingsController>();
    if (!settings.scannerAutofocusEnabled) return;
    if (size.width <= 0 || size.height <= 0) return;
    final p = details.localPosition;
    final normalized = Offset(p.dx / size.width, p.dy / size.height);
    try {
      await _controller.setFocusPoint(normalized);
    } catch (_) {
      // Ignore focus errors (device-dependent).
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            tooltip: t.qrScannerFlashTooltip,
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: t.qrScannerSwitchCameraTooltip,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _handleTapToFocus(d, size),
                child: MobileScanner(
                  controller: _controller,
                  onDetect: (capture) async {
                    if (_handled) return;
                    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue?.trim() : null;
                    if (raw == null || raw.isEmpty) return;
                    _handled = true;

                    final soundOn = context.read<AppSettingsController>().scannerSoundEnabled;
                    if (soundOn) {
                      // Âm thanh hệ thống: phụ thuộc chế độ im lặng/âm lượng của máy.
                      // Dùng alert + rung để dễ nhận biết khi test.
                      SystemSound.play(SystemSoundType.alert);
                      HapticFeedback.mediumImpact();
                    }

                    if (!mounted) return;
                    Navigator.pop(context, raw);
                  },
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.hint ?? t.qrScannerDefaultHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


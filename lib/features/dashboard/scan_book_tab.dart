import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/borrow_policy.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../core/utils/library_qr_payload.dart';
import '../../gen/l10n/app_localizations.dart';
import '../../models/book.dart';
import '../../services/borrow_return_service.dart';

/// Tab quét QR Code sách - dùng chung Admin và Sinh viên.
/// Camera chỉ chạy khi [scannerTabActive] và không có màn đè (Tạo phiếu mượn, v.v.) — không xử lý trùng với [QrScannerScreen] trên route khác.
class ScanBookTab extends StatefulWidget {
  const ScanBookTab({super.key, this.scannerTabActive = true});

  /// `false` khi dashboard không ở tab Quét — tắt camera nền.
  final bool scannerTabActive;

  @override
  State<ScanBookTab> createState() => _ScanBookTabState();
}

class _ScanBookTabState extends State<ScanBookTab> with SingleTickerProviderStateMixin, RouteAware {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final ImagePicker _imagePicker = ImagePicker();

  bool _handling = false;
  String? _lastValue;

  /// Có route khác đè lên dashboard (ví dụ Tạo phiếu mượn / QrScannerScreen).
  bool _routeCoveredByOverlay = false;

  late final AnimationController _scanLineController;

  /// Chỉ xử lý mã khi tab Quét đang hiển thị và dashboard là route hiện tại (không bị che).
  bool get _mayProcessScan =>
      widget.scannerTabActive && !_routeCoveredByOverlay && (ModalRoute.of(context)?.isCurrent ?? false);

  Future<void> _syncCameraToPolicy() async {
    if (!mounted) return;
    if (_mayProcessScan) {
      await _controller.start();
    } else {
      await _controller.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Lặp liên tục để tạo hiệu ứng "scan line".
    _scanLineController.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.scannerTabActive) {
        _controller.stop();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppRoutes.routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      AppRoutes.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRoutes.routeObserver.unsubscribe(this);
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _routeCoveredByOverlay = true;
    _syncCameraToPolicy();
  }

  @override
  void didPopNext() {
    _routeCoveredByOverlay = false;
    _syncCameraToPolicy();
  }

  @override
  void didUpdateWidget(ScanBookTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scannerTabActive != widget.scannerTabActive) {
      _syncCameraToPolicy();
    }
  }

  String _borrowErrMessage(BuildContext context, String code) {
    final t = AppLocalizations.of(context)!;
    switch (code) {
      case 'book_not_found':
        return t.brErrBookNotFound;
      case 'invalid_book_data':
        return t.brErrInvalidBookData;
      case 'out_of_stock':
        return t.brErrOutOfStock;
      case 'already_borrowing':
        return t.brErrAlreadyBorrowing;
      case 'max_active_borrows':
        return t.brErrMaxActiveBorrows;
      case 'no_active_borrow':
        return t.brErrNoActiveBorrow;
      default:
        return t.genericErrorWithMessage(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: (capture) async {
                  if (!_mayProcessScan) return;
                  if (_handling) return;
                  final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue?.trim() : null;
                  if (raw == null || raw.isEmpty) return;

                  if (raw == _lastValue) return;
                  _lastValue = raw;
                  _handling = true;

                  try {
                    final soundOn = context.read<AppSettingsController>().scannerSoundEnabled;
                    if (soundOn) {
                      SystemSound.play(SystemSoundType.alert);
                      HapticFeedback.mediumImpact();
                    }
                    await _controller.stop();
                    await _handleScannedValue(raw);
                  } finally {
                    _handling = false;
                    if (mounted && _mayProcessScan) {
                      await _controller.start();
                    }
                  }
                },
              ),
              // Làm nền tối để nổi khung scan.
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Corner markers (giống mockup)
                      _CornerMarker(
                        color: theme.colorScheme.primary,
                        alignment: Alignment.topLeft,
                      ),
                      _CornerMarker(
                        color: theme.colorScheme.primary,
                        alignment: Alignment.topRight,
                      ),
                      _CornerMarker(
                        color: theme.colorScheme.primary,
                        alignment: Alignment.bottomLeft,
                      ),
                      _CornerMarker(
                        color: theme.colorScheme.primary,
                        alignment: Alignment.bottomRight,
                      ),
                      // Scan line animation
                      AnimatedBuilder(
                        animation: _scanLineController,
                        builder: (context, _) {
                          const lineHeight = 2.0;
                          const inset = 18.0;
                          final t = _scanLineController.value;
                          final usableHeight = 240 - inset * 2 - lineHeight;
                          final top = inset + (usableHeight * t);
                          return Positioned(
                            left: inset,
                            right: inset,
                            top: top,
                            child: Container(
                              height: lineHeight,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _CircleIconButton(
                      onPressed: () => _controller.toggleTorch(),
                      icon: Icons.flash_on,
                      tooltip: t.scanFlashTooltip,
                    ),
                    const Spacer(),
                    _CircleIconButton(
                      onPressed: () => _controller.switchCamera(),
                      icon: Icons.cameraswitch,
                      tooltip: t.scanSwitchCameraTooltip,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text(
                      t.scanAlignHint,
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    if (!_mayProcessScan) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.scanTabNeedSwitchToScan)),
                        );
                      }
                      return;
                    }
                    if (_handling) return;
                    _handling = true;
                    try {
                      await _pickAndScanImage();
                    } finally {
                      _handling = false;
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.scanTabUploadImage,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => AppRoutes.pushRoot(context, AppRoutes.borrowHistory),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.scanTabHistory,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleScannedValue(String value) async {
    if (!_mayProcessScan) return;
    final t = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.needReSignIn)));
      }
      return;
    }

    final parsed = LibraryQrParseResult.parse(value);

    if (parsed.borrowRecordId != null && parsed.borrowRecordId!.isNotEmpty) {
      if (!AppUser.isStaff) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.borrowTicketStaffOnlyReturn)),
          );
        }
        return;
      }
      if (!mounted) return;
      AppRoutes.openReturnBook(context, arguments: {'borrowRecordId': parsed.borrowRecordId});
      return;
    }

    if (parsed.userId != null && parsed.userId!.isNotEmpty) {
      if (!AppUser.isStaff) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.studentQrUsedForStaffCreateBorrow)),
          );
        }
        return;
      }
      if (!mounted) return;
      AppRoutes.openBorrowCreate(context, arguments: {'userId': parsed.userId});
      return;
    }

    final lookupKey = parsed.bookLookupKey.trim();
    if (lookupKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.qrInvalid)));
      }
      return;
    }

    Book? book;
    try {
      // QR sách: thường là bookId; có thể là ISBN
      book = await BorrowReturnService.getBookById(lookupKey);
    } catch (_) {
      book = await BorrowReturnService.getBookByIsbn(lookupKey);
    }

    if (book == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.bookNotFoundFromQr)));
      }
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _BookActionSheet(
        book: book!,
        isStaff: AppUser.isStaff,
        onBorrowStudent: () async {
          Navigator.pop(ctx);
          await _borrowForCurrentUser(uid, book!.id);
        },
        onReturnStudent: () async {
          Navigator.pop(ctx);
          await _returnForCurrentUser(uid, book!.id);
        },
        onAdminBorrow: () {
          Navigator.pop(ctx);
          AppRoutes.openBorrowCreate(context, arguments: {'bookId': book!.id});
        },
        onAdminReturn: () {
          Navigator.pop(ctx);
          AppRoutes.openReturnBook(context, arguments: {'bookId': book!.id});
        },
      ),
    );
  }

  Future<void> _borrowForCurrentUser(String uid, String bookId) async {
    var loanDays = BorrowPolicy.defaultLoanDays;
    try {
      final cfg = await FirebaseFirestore.instance.collection('library_settings').doc('config').get();
      final v = cfg.data()?['loanDays'];
      if (v is int && v > 0) loanDays = BorrowPolicy.clampToLoanRange(v);
    } catch (_) {}
    try {
      await BorrowReturnService.borrowBook(userId: uid, bookId: bookId, loanDays: loanDays);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.borrowSuccess)));
      }
    } on BorrowReturnException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_borrowErrMessage(context, e.code))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.borrowFailed('$e'))));
      }
    }
  }

  Future<void> _returnForCurrentUser(String uid, String bookId) async {
    try {
      await BorrowReturnService.returnBook(userId: uid, bookId: bookId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.returnSuccess)));
      }
    } on BorrowReturnException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_borrowErrMessage(context, e.code))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.returnFailed('$e'))));
      }
    }
  }

  Future<void> _pickAndScanImage() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final capture = await _controller.analyzeImage(file.path);
      final raw = capture?.barcodes.isNotEmpty == true ? capture!.barcodes.first.rawValue?.trim() : null;
      if (raw == null || raw.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.noQrFoundInImage)),
          );
        }
        return;
      }

      await _handleScannedValue(raw);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotScanImage('$e'))),
        );
      }
    }
  }
}

class _BookActionSheet extends StatelessWidget {
  final Book book;
  final bool isStaff;
  final VoidCallback onBorrowStudent;
  final VoidCallback onReturnStudent;
  final VoidCallback onAdminBorrow;
  final VoidCallback onAdminReturn;

  const _BookActionSheet({
    required this.book,
    required this.isStaff,
    required this.onBorrowStudent,
    required this.onReturnStudent,
    required this.onAdminBorrow,
    required this.onAdminReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final availableColor = book.availableQuantity > 0 ? Colors.green : Colors.red;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.bookInfoTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(book.title.isEmpty ? t.scanBookUntitled : book.title, style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text(
              t.scanBookRemaining('${book.availableQuantity}', '${book.quantity}'),
              style: AppTextStyles.body.copyWith(color: availableColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(t.bookIdDebugLabel(book.id), style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            if (!isStaff) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: book.availableQuantity > 0 ? onBorrowStudent : null,
                  child: Text(t.scanBorrowBookAction),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onReturnStudent,
                  child: Text(t.scanReturnBookAction),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAdminBorrow,
                  child: Text(t.scanAdminCreateBorrowAction),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onAdminReturn,
                  child: Text(t.scanAdminReturnBookAction),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const _CircleIconButton({
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.28),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final Color color;
  final Alignment alignment;

  const _CornerMarker({
    required this.color,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    const stroke = 4.0;

    Border border;
    if (alignment == Alignment.topLeft) {
      border = Border(
        left: BorderSide(color: color, width: stroke),
        top: BorderSide(color: color, width: stroke),
      );
    } else if (alignment == Alignment.topRight) {
      border = Border(
        right: BorderSide(color: color, width: stroke),
        top: BorderSide(color: color, width: stroke),
      );
    } else if (alignment == Alignment.bottomLeft) {
      border = Border(
        left: BorderSide(color: color, width: stroke),
        bottom: BorderSide(color: color, width: stroke),
      );
    } else {
      border = Border(
        right: BorderSide(color: color, width: stroke),
        bottom: BorderSide(color: color, width: stroke),
      );
    }

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(border: border),
        ),
      ),
    );
  }
}

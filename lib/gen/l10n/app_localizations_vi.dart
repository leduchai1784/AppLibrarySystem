// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Thư viện số';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonSignOut => 'Đăng xuất';

  @override
  String get commonSignIn => 'Đăng nhập';

  @override
  String get loadMore => 'Tải thêm';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabBorrowing => 'Đang mượn';

  @override
  String get tabHistory => 'Lịch sử';

  @override
  String get tabScan => 'Quét';

  @override
  String get tabManage => 'Quản lý';

  @override
  String get tabBooks => 'Sách';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsLanguageAppearance => 'Ngôn ngữ & giao diện';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get defaultQrColorTitle => 'Màu QR mặc định';

  @override
  String get defaultQrSizeTitle => 'Kích thước QR mặc định';

  @override
  String get qrSizeSmall200 => 'Nhỏ (200px)';

  @override
  String get qrSizeMedium256 => 'Vừa (256px)';

  @override
  String get qrSizeLarge300 => 'Lớn (300px)';

  @override
  String get settingsAppPreferences => 'Tùy chọn ứng dụng';

  @override
  String get settingsDefaultQrStyle => 'Cấu hình QR mặc định';

  @override
  String get settingsDefaultColor => 'Màu mặc định';

  @override
  String get settingsDefaultSize => 'Kích thước mặc định';

  @override
  String get settingsCameraScanning => 'Camera & quét mã';

  @override
  String get settingsSecurity => 'Bảo mật';

  @override
  String get settingsBiometricsUnsupported => 'Thiết bị không hỗ trợ';

  @override
  String get settingsBiometricsHint =>
      'Thử mở khóa bằng vân tay/Face ID trước.';

  @override
  String get settingsAppLockHint =>
      'Khi ra khỏi app và quay lại, cần xác thực.';

  @override
  String get settingsAutofocusHint =>
      'Gợi ý cho camera (một số máy luôn lấy nét tự động).';

  @override
  String get settingsBorrowReturnNotifsHint =>
      'Tạo thông báo khi mượn/trả (lưu trên tài khoản).';

  @override
  String get settingsPushNotifsHint =>
      'Hiện tin trên thanh trạng thái khi có thông báo mới (cần quyền).';

  @override
  String get settingsLibraryData => 'Dữ liệu thư viện';

  @override
  String get settingsBackupLibraryJson => 'Sao lưu JSON thư viện';

  @override
  String get settingsBackupMyBorrows => 'Sao lưu phiếu mượn của tôi';

  @override
  String get settingsSignOutAction => 'Đăng xuất';

  @override
  String get systemFeaturesTitle => 'Cấu hình chức năng';

  @override
  String get systemFeaturesSubtitle =>
      'Bật/tắt các chức năng trong app. Thay đổi sẽ áp dụng realtime cho người dùng đang mở ứng dụng.';

  @override
  String get systemFeaturesSaved => 'Đã lưu cấu hình chức năng.';

  @override
  String get systemFeaturesCoreSection => 'Chức năng cốt lõi';

  @override
  String get systemFeaturesAiSection => 'AI';

  @override
  String get systemFeaturesReportsSection => 'Báo cáo';

  @override
  String get systemFeaturesScan => 'Quét QR';

  @override
  String get systemFeaturesScanHint => 'Bật/tắt tab Quét (scan QR/ISBN).';

  @override
  String get systemFeaturesBorrowReturn => 'Mượn/Trả';

  @override
  String get systemFeaturesBorrowReturnHint =>
      'Bật/tắt luồng mượn/trả sách trong app.';

  @override
  String get systemFeaturesAiRecommendations => 'Gợi ý sách';

  @override
  String get systemFeaturesAiRecommendationsHint =>
      'Bật/tắt khu vực gợi ý AI trên trang chủ.';

  @override
  String get systemFeaturesStatistics => 'Thống kê';

  @override
  String get systemFeaturesStatisticsHint => 'Bật/tắt màn Thống kê/Báo cáo.';

  @override
  String get settingsPushNotifications => 'Thông báo đẩy';

  @override
  String get settingsInAppNotifications => 'Thông báo trong app';

  @override
  String get settingsQrDefaultColor => 'Màu QR mặc định';

  @override
  String get settingsQrDefaultSize => 'Kích thước QR mặc định';

  @override
  String get settingsScannerAutofocus => 'Lấy nét tự động';

  @override
  String get settingsScannerBeep => 'Âm thanh khi quét';

  @override
  String get settingsAppLock => 'Khóa ứng dụng';

  @override
  String get settingsPreferBiometrics => 'Ưu tiên sinh trắc học';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsBackup => 'Sao lưu';

  @override
  String get settingsClearLocalData => 'Xóa dữ liệu cục bộ & đăng xuất';

  @override
  String get clearLocalDataTitle => 'Xóa dữ liệu cục bộ?';

  @override
  String get clearLocalDataBody =>
      'Xóa cài đặt trên máy và đăng xuất. Dữ liệu trên server (Firestore) không bị xóa.';

  @override
  String get clearLocalDataConfirm => 'Xóa & đăng xuất';

  @override
  String get webSystemSettingsTitle => 'Cấu hình hệ thống';

  @override
  String get webSystemSettingsSubtitle =>
      'Tùy chọn trên trình duyệt. Quét QR, camera và khóa ứng dụng chỉnh trong app di động.';

  @override
  String get settingsProviderMissingBody =>
      'Không tìm thấy AppSettingsController (Provider). Kiểm tra main.dart có ChangeNotifierProvider<AppSettingsController> và khởi động lại app (không chỉ hot reload).';

  @override
  String get settingsJsonDownloaded => 'Đã tải file JSON xuống máy.';

  @override
  String settingsExportFailed(Object message) {
    return 'Xuất dữ liệu lỗi: $message';
  }

  @override
  String get settingsBorrowReturnNotificationsTitle =>
      'Thông báo mượn / trả sách';

  @override
  String get settingsBorrowReturnNotificationsBody =>
      'Lưu trên tài khoản. Tắt sẽ không tạo thông báo trong app khi mượn hoặc trả.';

  @override
  String get settingsExportJsonTitle => 'Xuất JSON (sách, danh mục, phiếu)';

  @override
  String get settingsMobileConfigHint =>
      'Trên điện thoại: cấu hình QR mặc định, camera quét, khóa app và sinh trắc học.';

  @override
  String get webDebugPanelHeader =>
      '── Thông tin tra lỗi (chụp màn hình gửi dev) ──';

  @override
  String get webDebugPanelProviderYes => 'có';

  @override
  String get webDebugPanelProviderNo => 'KHÔNG';

  @override
  String get webDebugPanelRoleMismatchHint =>
      'Nếu role là student nhưng Firestore là admin → bấm nút bên dưới rồi F5 trang.';

  @override
  String get myQrTitle => 'QR của tôi';

  @override
  String get myQrHint => 'Đưa mã này cho thủ thư quét khi tạo phiếu mượn.';

  @override
  String get notSignedInTitle => 'Chưa đăng nhập';

  @override
  String get profileButton => 'Hồ sơ';

  @override
  String get myQrButton => 'QR của tôi';

  @override
  String studentCodeLabel(Object code) {
    return 'MSSV: $code';
  }

  @override
  String get quickTasksTitle => 'Tác vụ nhanh';

  @override
  String get quickLibrary => 'Thư viện';

  @override
  String get quickHistoryTab => 'Lịch sử';

  @override
  String get recentBorrowsTitle => 'Mượn gần đây';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get cannotLoadRecentData => 'Không thể tải dữ liệu gần đây';

  @override
  String get noRecentBorrows => 'Chưa có phiếu mượn gần đây';

  @override
  String get needSignInToSeeStats => 'Đăng nhập để xem thống kê';

  @override
  String get needSignIn => 'Cần đăng nhập';

  @override
  String get signInToConfigure => 'Đăng nhập để cấu hình';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get reloadRoleSuccess =>
      'Đã tải lại role từ Firestore. Nếu sidebar vẫn sai, hãy refresh trang.';

  @override
  String get reloadRoleButton => 'Tải lại role từ Firestore';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String get adminSearchHint => 'Tìm kiếm sách, người dùng...';

  @override
  String get adminQuickTasksTitle => 'Tác vụ nhanh';

  @override
  String get adminQuickAddBook => 'Thêm sách';

  @override
  String get adminQuickBookList => 'Danh sách sách';

  @override
  String get adminQuickCreateBorrow => 'Tạo phiếu mượn';

  @override
  String get adminQuickReturn => 'Trả sách';

  @override
  String get adminQuickManageCategories => 'Quản lý danh mục';

  @override
  String get adminQuickManageUsers => 'Quản lý người dùng';

  @override
  String get adminQuickStats => 'Thống kê';

  @override
  String get adminQuickFinePayment => 'Thanh toán phạt';

  @override
  String get adminStatBookTitles => 'Đầu sách';

  @override
  String get adminStatUsers => 'Người dùng';

  @override
  String get adminStatTotalBorrows => 'Phiếu mượn';

  @override
  String get adminStatActiveBorrow => 'Đang mượn';

  @override
  String get qrScannerFlashTooltip => 'Đèn flash';

  @override
  String get qrScannerSwitchCameraTooltip => 'Đổi camera';

  @override
  String get qrScannerDefaultHint => 'Đưa mã QR vào khung hình để quét';

  @override
  String get appLockedTitle => 'Ứng dụng đã khóa';

  @override
  String get appLockedBody => 'Xác thực để tiếp tục sử dụng.';

  @override
  String get unlockAction => 'Mở khóa';

  @override
  String get biometricNotSupported => 'Thiết bị không hỗ trợ xác thực.';

  @override
  String get biometricReason => 'Mở khóa ứng dụng thư viện';

  @override
  String get borrowTicketStaffOnlyReturn =>
      'Mã phiếu mượn chỉ dùng khi trả tại quầy (tài khoản nhân sự).';

  @override
  String get studentQrUsedForStaffCreateBorrow =>
      'Mã sinh viên này dùng khi thủ thư tạo phiếu.';

  @override
  String isbnLabel(Object isbn, Object available, Object quantity) {
    return 'ISBN: $isbn | Còn: $available/$quantity';
  }

  @override
  String cannotUpdateStatus(Object message) {
    return 'Không thể cập nhật trạng thái: $message';
  }

  @override
  String get roleLabelAdminShort => 'Admin';

  @override
  String get roleLabelManagerShort => 'Quản lý';

  @override
  String get roleLabelStudentShort => 'Sinh viên';

  @override
  String lateFineLabel(Object amount) {
    return 'Phạt: $amount';
  }

  @override
  String get ticketIdLabel => 'Mã phiếu';

  @override
  String get borrowDateLabelShort => 'Ngày mượn';

  @override
  String get dueDateLabelShort => 'Hạn trả';

  @override
  String get librarianLabel => 'Thủ thư';

  @override
  String bookIdDebugLabel(Object id) {
    return 'bookId: $id';
  }

  @override
  String get remainingTotalLabel => 'còn/tổng';

  @override
  String get lockedShort => 'Bị khóa';

  @override
  String get bookDetailsAction => 'Chi tiết sách';

  @override
  String get outOfStockCannotBorrow => 'Sách đã hết, không thể tạo phiếu mượn';

  @override
  String get createBorrowRecordAction => 'Tạo phiếu mượn';

  @override
  String get scanBorrowBookAction => 'MƯỢN SÁCH';

  @override
  String get scanReturnBookAction => 'TRẢ SÁCH';

  @override
  String get scanAdminCreateBorrowAction => 'TẠO PHIẾU MƯỢN (ADMIN)';

  @override
  String get scanAdminReturnBookAction => 'TRẢ SÁCH (ADMIN)';

  @override
  String get statsWeekdayMon => 'T2';

  @override
  String get statsWeekdayTue => 'T3';

  @override
  String get statsWeekdayWed => 'T4';

  @override
  String get statsWeekdayThu => 'T5';

  @override
  String get statsWeekdayFri => 'T6';

  @override
  String get statsWeekdaySat => 'T7';

  @override
  String get statsWeekdaySun => 'CN';

  @override
  String get viewFullList => 'Xem toàn bộ danh sách';

  @override
  String excelSelectedFile(Object name) {
    return 'Đã chọn: $name';
  }

  @override
  String get excelNotesErrors => 'Ghi chú / lỗi dòng:';

  @override
  String excelAndMoreLines(Object count) {
    return '… và $count dòng khác';
  }

  @override
  String get orEnterSingleBook => 'Hoặc nhập một cuốn';

  @override
  String get bookBasicInfoSection => 'Thông tin cơ bản';

  @override
  String get bookInventorySection => 'Quản lý kho';

  @override
  String get submitUpdateBook => 'CẬP NHẬT SÁCH';

  @override
  String get submitAddBook => 'THÊM SÁCH';

  @override
  String get bookTitleLabel => 'Tên sách';

  @override
  String get bookTitleHint => 'Nhập tên sách';

  @override
  String get bookAuthorLabel => 'Tác giả';

  @override
  String get bookAuthorHint => 'Nhập tên tác giả';

  @override
  String get bookAuthorPickHint =>
      'Chọn từ danh mục tác giả, hoặc chọn nhập tay rồi gõ bên dưới.';

  @override
  String get bookAuthorManualOption => '— Nhập tay —';

  @override
  String get bookGenreLabel => 'Thể loại';

  @override
  String get bookGenreNone => '— Không chọn —';

  @override
  String get bookCoverSectionTitle => 'Ảnh bìa';

  @override
  String get bookCoverPickGallery => 'Chọn ảnh từ thư viện';

  @override
  String get bookCoverRemove => 'Xóa ảnh bìa';

  @override
  String get bookCoverUrlLabel => 'URL ảnh (https)';

  @override
  String get bookCoverUrlHint =>
      'Tùy chọn — dán link ảnh trực tiếp, hoặc chọn ảnh bên dưới (lưu trong Firestore, không dùng Storage).';

  @override
  String get bookCoverImageTooLarge =>
      'Ảnh vẫn quá lớn sau khi nén. Thử ảnh khác hoặc dùng link HTTPS.';

  @override
  String get bookCoverDataUrlTooLong =>
      'Dữ liệu ảnh mã hóa vượt giới hạn Firestore. Dùng ảnh nhỏ hơn hoặc link HTTPS.';

  @override
  String get bookCategoryLabel => 'Danh mục';

  @override
  String get bookIsbnLabel => 'Mã ISBN';

  @override
  String get bookIsbnHint => '978-xxx-xxx-xxx';

  @override
  String fieldRequiredWithLabel(Object label) {
    return 'Vui lòng nhập $label';
  }

  @override
  String get saveBookSuccessUpdate => 'Cập nhật sách thành công';

  @override
  String get saveBookSuccessAdd => 'Thêm sách thành công';

  @override
  String saveBookError(Object message) {
    return 'Lỗi khi lưu sách: $message';
  }

  @override
  String get cannotCreateTemplate => 'Không tạo được file mẫu.';

  @override
  String shareFileError(Object message) {
    return 'Không chia sẻ / lưu được file: $message';
  }

  @override
  String get excelTemplateSubject => 'Mẫu nhập 5 đầu sách';

  @override
  String get excelTemplateBody =>
      'Excel mẫu — chỉnh sửa nếu cần, rồi dùng nút Chọn file .xlsx ở trên.';

  @override
  String get cannotReadFileContent =>
      'Không đọc được nội dung file. Thử lưu lại bằng Excel (.xlsx) hoặc file nhỏ hơn.';

  @override
  String excelPickReadError(Object message) {
    return 'Lỗi chọn/đọc file: $message';
  }

  @override
  String firestoreWriteError(Object message) {
    return 'Lỗi khi ghi Firestore: $message';
  }

  @override
  String importedNBooksFromExcel(Object count) {
    return 'Đã nhập $count đầu sách từ Excel';
  }

  @override
  String get confirmDeleteTitle => 'Xác nhận xóa';

  @override
  String get confirmDeleteBookBody =>
      'Bạn có chắc muốn xóa sách này? Hành động này không thể hoàn tác.';

  @override
  String get bookDeletedToast => 'Đã xóa sách';

  @override
  String deleteBookError(Object message) {
    return 'Lỗi khi xóa sách: $message';
  }

  @override
  String genericErrorWithMessage(Object message) {
    return 'Lỗi: $message';
  }

  @override
  String bookAuthorPrefix(Object author) {
    return 'Tác giả: $author';
  }

  @override
  String get bookQrTitle => 'Mã QR sách';

  @override
  String get bookInfoSection => 'Thông tin';

  @override
  String get bookDescriptionSection => 'Mô tả';

  @override
  String get bookMissingIdCannotBorrow => 'Chưa có mã sách để tạo phiếu';

  @override
  String bookIdLabel(Object id) {
    return 'Mã sách: $id';
  }

  @override
  String get printNotSupported => 'Tính năng in chưa được hỗ trợ';

  @override
  String sortByLabel(Object sortBy) {
    return 'Sắp xếp: $sortBy';
  }

  @override
  String get editAction => 'Sửa';

  @override
  String get updateAction => 'Cập nhật';

  @override
  String get borrowRecordDetailsTitle => 'Chi tiết phiếu mượn';

  @override
  String get bookLabel => 'Sách';

  @override
  String get missingBookId => '(Không có mã sách)';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get profileTitle => 'Thông tin cá nhân';

  @override
  String get studentAppTitle => 'Library System - Sinh viên';

  @override
  String get borrowedBooksTitle => 'Sách đang mượn';

  @override
  String get borrowHistoryTitle => 'Lịch sử mượn';

  @override
  String get adminUseWebTitle => 'Quản trị viên dùng cổng web';

  @override
  String get adminUseWebBody =>
      'Theo cấu hình hệ thống, tài khoản Admin đăng nhập trên trình duyệt (máy tính / tablet) để quản lý dữ liệu. Ứng dụng di động dành cho Quản lý thao tác trực tiếp và cho Sinh viên.';

  @override
  String get webStaffOnlyTitle => 'Cổng web dành cho Admin và Quản lý';

  @override
  String get webStaffOnlyBody =>
      'Tài khoản sinh viên vui lòng sử dụng ứng dụng trên điện thoại.';

  @override
  String get webRegisterNotAllowedTitle => 'Đăng ký';

  @override
  String get webRegisterNotAllowedBody1 =>
      'Đăng ký tài khoản sinh viên chỉ thực hiện trên ứng dụng di động.';

  @override
  String get webRegisterNotAllowedBody2 =>
      'Trên web chỉ dành cho Admin và Quản lý đăng nhập.';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get markAllRead => 'Đánh dấu đã đọc';

  @override
  String get markedAllRead => 'Đã đánh dấu đã đọc';

  @override
  String errorPrefix(Object message) {
    return 'Lỗi: $message';
  }

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get registerTitle => 'Đăng ký';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get signInWithGoogle => 'Đăng nhập với Google';

  @override
  String get noAccountRegister => 'Chưa có tài khoản? Đăng ký';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get resetPassword => 'Đặt lại mật khẩu';

  @override
  String get agreeTermsRequired =>
      'Vui lòng đồng ý với Điều khoản và Chính sách bảo mật';

  @override
  String get enterEmailPassword => 'Vui lòng nhập email và mật khẩu';

  @override
  String get verifyEmailBeforeLogin =>
      'Email của bạn chưa được xác thực. Vui lòng kiểm tra hộp thư và bấm vào link xác thực trước khi đăng nhập.';

  @override
  String get registerSuccessVerifyEmail =>
      'Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản trước khi đăng nhập.';

  @override
  String get commonOr => 'hoặc';

  @override
  String get noAccountPrefix => 'Chưa có tài khoản?';

  @override
  String get registerAction => 'Đăng ký';

  @override
  String get invalidEmailFormat => 'Định dạng email không hợp lệ';

  @override
  String get resetEmailSentIfExists =>
      'Nếu email tồn tại trong hệ thống, link đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư (kể cả Spam).';

  @override
  String get sendResetLink => 'Gửi link đặt lại mật khẩu';

  @override
  String tryAgainLaterDetails(Object message) {
    return 'Có lỗi xảy ra, vui lòng thử lại sau. Chi tiết: $message';
  }

  @override
  String get scanBookQrTitle => 'Quét QR sách';

  @override
  String get manageTitle => 'Quản lý';

  @override
  String get createNewAccount => 'Tạo tài khoản mới';

  @override
  String get passwordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get passwordMismatch => 'Xác nhận mật khẩu không khớp';

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get emailAlreadyInUse =>
      'Email này đã được sử dụng. Vui lòng đăng nhập hoặc dùng email khác';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get weakPassword =>
      'Mật khẩu quá yếu, vui lòng dùng mật khẩu mạnh hơn';

  @override
  String get passwordStrength => 'Độ mạnh mật khẩu';

  @override
  String get iAgreeWith => 'Tôi đồng ý với';

  @override
  String get termsOfUse => 'Điều khoản sử dụng';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get andWord => 'và';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get alreadyHaveAccountPrefix => 'Đã có tài khoản?';

  @override
  String get signInAction => 'Đăng nhập';

  @override
  String get pleaseEnterFullName => 'Vui lòng nhập họ tên';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập email';

  @override
  String get pleaseEnterPhone => 'Vui lòng nhập số điện thoại';

  @override
  String get bookDetailTitle => 'Chi tiết sách';

  @override
  String get bookNotFound => 'Sách không tồn tại hoặc đã bị xóa';

  @override
  String get bookListTitle => 'Kho sách';

  @override
  String get bookListSelectMode => 'Chọn sách';

  @override
  String bookListSelectedCount(Object count) {
    return 'Đã chọn $count';
  }

  @override
  String get bookListSelectAllVisible => 'Chọn tất cả';

  @override
  String get bookListDeselectAllVisible => 'Bỏ chọn hiển thị';

  @override
  String bookListBulkDelete(Object count) {
    return 'Xóa ($count)';
  }

  @override
  String bookListBulkDeleteConfirm(Object count) {
    return 'Xóa $count đầu sách? Sách đang cho mượn sẽ bị bỏ qua.';
  }

  @override
  String bookListBulkDeleteResult(Object deleted, Object skipped) {
    return 'Đã xóa $deleted. Bỏ qua (đang mượn): $skipped.';
  }

  @override
  String get bookListLongPressHint =>
      'Nhấn giữ một cuốn sách để chọn nhiều, chạm để thêm hoặc bỏ chọn.';

  @override
  String get addBook => 'Thêm sách';

  @override
  String get categoriesManageTitle => 'Quản lý danh mục';

  @override
  String get categoriesManageBooksTitle => 'Quản lý danh mục sách';

  @override
  String get staffOnlyCategoryEdit =>
      'Chỉ quản trị viên hoặc quản lý mới chỉnh danh mục.';

  @override
  String get noCategoriesYet => 'Chưa có danh mục';

  @override
  String get addFirstCategory => 'Thêm danh mục đầu tiên';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get usersManageTitle => 'Quản lý người dùng';

  @override
  String get profileEdit => 'Chỉnh sửa hồ sơ';

  @override
  String get deleteConfirmTitle => 'Xác nhận xóa';

  @override
  String get deleteConfirmBookBody =>
      'Bạn có chắc muốn xóa sách này? Hành động này không thể hoàn tác.';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get deletedBookToast => 'Đã xóa sách';

  @override
  String get viewAsList => 'Xem dạng danh sách';

  @override
  String get viewAsGrid => 'Xem dạng lưới';

  @override
  String get sort => 'Sắp xếp';

  @override
  String get searchBooksHint =>
      'Tìm theo tên, tác giả, ISBN, thể loại, mô tả, năm…';

  @override
  String bookListMatchesCount(int count) {
    return 'Tìm thấy $count cuốn';
  }

  @override
  String get bookListEmptyLibrary => 'Chưa có sách trong thư viện';

  @override
  String get noBooksMatchFilters => 'Chưa có sách nào phù hợp bộ lọc';

  @override
  String cannotLoadList(Object message) {
    return 'Không thể tải danh sách: $message';
  }

  @override
  String get noUsersYet => 'Chưa có người dùng';

  @override
  String get staffOnlyUserManage =>
      'Chỉ quản trị viên (admin) mới được phân quyền tài khoản và khóa người dùng.';

  @override
  String get searchUsersHint => 'Tìm theo tên, email...';

  @override
  String get cannotLoadUsers => 'Không thể tải danh sách người dùng';

  @override
  String get lockedLabel => 'Khóa';

  @override
  String get borrowCreateTitle => 'Tạo phiếu mượn sách';

  @override
  String get returnBookTitle => 'Trả sách';

  @override
  String get scanBookTitle => 'Quét QR sách';

  @override
  String get scanBookHint => 'bookId / ISBN trên tem sách';

  @override
  String get scanStudentTitle => 'Quét QR sinh viên';

  @override
  String get scanStudentHint => 'LIB_USER:... hoặc UID sinh viên';

  @override
  String get scanBorrowTicketTitle => 'Quét phiếu mượn';

  @override
  String get scanBorrowTicketHint => 'Mã LIB_RET:... sau khi mượn';

  @override
  String get cannotReadBorrowTicket =>
      'Không đọc được mã phiếu (cần LIB_RET: hoặc id phiếu)';

  @override
  String get borrowTicketNotFound => 'Không tìm thấy phiếu mượn';

  @override
  String get borrowTicketNotActive => 'Phiếu không ở trạng thái đang mượn.';

  @override
  String get currentBorrowsTitle => 'Sách đang mượn';

  @override
  String get cannotLoadCurrentBorrows => 'Không thể tải danh sách đang mượn';

  @override
  String get noActiveBorrowsStaff => 'Không có phiếu mượn nào đang hoạt động';

  @override
  String get noActiveBorrowsStudent => 'Bạn chưa mượn sách nào';

  @override
  String dueDatePrefix(Object date) {
    return 'Hạn trả: $date';
  }

  @override
  String daysLeftPrefix(Object days) {
    return 'Còn $days ngày';
  }

  @override
  String overduePrefix(Object days) {
    return 'Quá hạn $days ngày';
  }

  @override
  String get returnAction => 'Trả';

  @override
  String get borrowHistoryTitle2 => 'Lịch sử mượn sách';

  @override
  String get cannotLoadBorrowHistory => 'Không thể tải lịch sử mượn';

  @override
  String get noBorrowHistoryStaff => 'Chưa có lịch sử mượn/trả';

  @override
  String get noBorrowHistoryStudent => 'Bạn chưa có lịch sử mượn/trả';

  @override
  String borrowedPrefix(Object borrow, Object ret) {
    return 'Mượn: $borrow - Trả: $ret';
  }

  @override
  String finePrefix(Object amount) {
    return 'Phạt: $amount';
  }

  @override
  String get finePaymentTitle => 'Thanh toán phạt';

  @override
  String get totalFineLabel => 'Tổng tiền phạt';

  @override
  String get fineDetailsTitle => 'Chi tiết phạt';

  @override
  String get paymentMethodTitle => 'Phương thức thanh toán';

  @override
  String get cashAtLibrary => 'Tiền mặt tại thư viện';

  @override
  String get bankTransfer => 'Chuyển khoản';

  @override
  String payAmountButton(Object amount) {
    return 'THANH TOÁN $amount';
  }

  @override
  String get scanStudentQrButton => 'Quét QR SV';

  @override
  String get scanBookQrButton => 'Quét QR sách';

  @override
  String get findAction => 'TÌM';

  @override
  String get createBorrowButton => 'TẠO PHIẾU MƯỢN';

  @override
  String get bookCodeInputTitle => 'Nhập mã sách (bookId hoặc ISBN)';

  @override
  String get bookCodeHint => 'bookId / ISBN';

  @override
  String get studentBorrowerTitle => 'Sinh viên mượn (email hoặc MSSV)';

  @override
  String get studentBorrowerHint => 'Email hoặc MSSV';

  @override
  String get borrowDateLabel => 'Ngày mượn';

  @override
  String expectedReturnDateLabel(Object days) {
    return 'Ngày trả dự kiến (loanDays = $days)';
  }

  @override
  String get borrowDueDateTitle => 'Ngày trả dự kiến';

  @override
  String get borrowDueDateHint =>
      'Từ 3 đến 30 ngày kể từ hôm nay (nên mượn 7–14 ngày). Chạm để chọn.';

  @override
  String get borrowDueDateErrorRange =>
      'Ngày trả phải cách hôm nay từ 3 đến 30 ngày.';

  @override
  String get pleaseEnterBookCode => 'Vui lòng nhập bookId hoặc ISBN';

  @override
  String get bookNotFoundShort => 'Không tìm thấy sách';

  @override
  String bookLookupError(Object message) {
    return 'Lỗi tìm sách: $message';
  }

  @override
  String get pleaseEnterStudentQuery => 'Vui lòng nhập email hoặc MSSV';

  @override
  String get studentNotFound => 'Không tìm thấy sinh viên';

  @override
  String studentLookupError(Object message) {
    return 'Lỗi tìm sinh viên: $message';
  }

  @override
  String get studentLockedCannotBorrow =>
      'Tài khoản sinh viên đang bị khóa, không thể mượn.';

  @override
  String get needReSignIn => 'Bạn cần đăng nhập lại';

  @override
  String get borrowCreatedSuccessTitle => 'Tạo phiếu mượn thành công';

  @override
  String get borrowCreatedSuccessBody => 'Quét QR này tại quầy khi trả sách:';

  @override
  String get scanTabUploadImage => 'Tải ảnh lên';

  @override
  String get scanTabHistory => 'Lịch sử quét';

  @override
  String get scanTabNeedSwitchToScan =>
      'Chuyển sang tab Quét và đóng màn hình đang mở để quét từ ảnh.';

  @override
  String get qrInvalid => 'Mã QR không hợp lệ';

  @override
  String get bookNotFoundFromQr => 'Không tìm thấy sách từ QR/ISBN';

  @override
  String get borrowSuccess => 'Mượn sách thành công';

  @override
  String borrowFailed(Object message) {
    return 'Không thể mượn sách: $message';
  }

  @override
  String get returnSuccess => 'Trả sách thành công';

  @override
  String returnFailed(Object message) {
    return 'Không thể trả sách: $message';
  }

  @override
  String get noQrFoundInImage => 'Không tìm thấy QR trong ảnh đã chọn';

  @override
  String cannotScanImage(Object message) {
    return 'Không thể quét ảnh: $message';
  }

  @override
  String get bookInfoTitle => 'Thông tin sách';

  @override
  String get profileNotSignedIn => 'Chưa đăng nhập';

  @override
  String profileLoadError(Object message) {
    return 'Không tải được hồ sơ: $message';
  }

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String profileUpdateFailed(Object message) {
    return 'Không thể cập nhật: $message';
  }

  @override
  String get profileFullNameLabel => 'Họ và tên';

  @override
  String get profilePhoneLabel => 'Số điện thoại';

  @override
  String get profileStudentCodeLabel => 'MSSV / mã sinh viên';

  @override
  String get profileAddressLabel => 'Địa chỉ';

  @override
  String get profileEmailReadonlyLabel => 'Email (không sửa trong app)';

  @override
  String get profileMissingName => '(Chưa có họ tên)';

  @override
  String get roleAdmin => 'Quản trị viên';

  @override
  String get roleManager => 'Quản lý / thủ thư';

  @override
  String get roleStudent => 'Sinh viên';

  @override
  String get manageCreateBorrow => 'Tạo phiếu mượn';

  @override
  String get manageCreateBorrowSubtitle =>
      'Nhập sách và sinh viên, tạo phiếu mới';

  @override
  String get manageReturnBook => 'Trả sách';

  @override
  String get manageReturnBookSubtitle =>
      'Quét QR phiếu hoặc tìm theo sách + sinh viên';

  @override
  String get manageCurrentBorrows => 'Sách đang mượn';

  @override
  String get manageBorrowHistory => 'Lịch sử mượn';

  @override
  String get manageCategoryManage => 'Quản lý danh mục sách';

  @override
  String get manageUserManage => 'Quản lý người dùng';

  @override
  String get manageStatsReports => 'Thống kê & báo cáo';

  @override
  String get webHello => 'Xin chào';

  @override
  String get webAdminOverviewSubtitle =>
      'Tổng quan kho sách và thao tác mượn — trang quản trị web.';

  @override
  String get webSectionOverview => 'Tổng quan';

  @override
  String get webSectionInventory => 'Kho sách';

  @override
  String get webSectionDesk => 'Bàn làm việc';

  @override
  String get webSectionOperations => 'Vận hành';

  @override
  String get webSectionSystemConfig => 'Cấu hình hệ thống';

  @override
  String get webNotificationsTooltip => 'Thông báo';

  @override
  String get webMenuProfile => 'Hồ sơ';

  @override
  String get webMenuSignOut => 'Đăng xuất';

  @override
  String get webControlCenter => 'Trung tâm điều hành';

  @override
  String get webMetricTitles => 'Đầu sách';

  @override
  String get webMetricTitlesSub => 'tiêu đề trong kho';

  @override
  String get webMetricTotalCopies => 'Bản sách (tổng)';

  @override
  String get webMetricTotalCopiesSub => 'tổng số cuốn';

  @override
  String get webMetricAvailable => 'Còn cho mượn';

  @override
  String get webMetricAvailableSub => 'availableQuantity';

  @override
  String get webMetricBorrowed => 'Đang lưu hành';

  @override
  String get webMetricBorrowedSub => 'đang được mượn';

  @override
  String get webQuickAddBook => 'Thêm sách mới';

  @override
  String get webQuickStats => 'Thống kê';

  @override
  String get createQrTitle => 'Tạo QR Code';

  @override
  String get createQrSave => 'Lưu';

  @override
  String get createQrTypeUrl => 'URL';

  @override
  String get createQrTypeText => 'Text';

  @override
  String get createQrTypeVcard => 'vCard';

  @override
  String get createQrTypeWifi => 'WiFi';

  @override
  String get createQrTypeEmail => 'Email';

  @override
  String get createQrEnterContent => 'Vui lòng nhập nội dung để tạo QR';

  @override
  String createQrCreatedToast(Object name) {
    return 'Đã tạo QR: $name';
  }

  @override
  String get createQrUnnamed => 'Unnamed';

  @override
  String get createQrActionButton => 'TẠO QR CODE';

  @override
  String get createQrContentTitle => 'Nội dung';

  @override
  String get createQrNameLabel => 'Tên QR';

  @override
  String get createQrNameHint => 'Ví dụ: Kệ sách A1 - Tầng 2';

  @override
  String get createQrUrlLabel => 'URL Web';

  @override
  String get createQrUrlHint => 'https://thuvien.example.com';

  @override
  String get createQrTextLabel => 'Text';

  @override
  String get createQrTextHint => 'Nhập nội dung văn bản...';

  @override
  String get createQrVcardFullNameLabel => 'Full name';

  @override
  String get createQrVcardFullNameHint => 'Nguyễn Văn A';

  @override
  String get createQrEmailLabel => 'Email';

  @override
  String get createQrEmailHint => 'name@example.com';

  @override
  String get createQrWifiSsidLabel => 'SSID';

  @override
  String get createQrWifiSsidHint => 'Tên WiFi';

  @override
  String get createQrWifiPasswordLabel => 'Password';

  @override
  String get createQrWifiPasswordHint => 'Mật khẩu WiFi';

  @override
  String get createQrEmailToLabel => 'To';

  @override
  String get createQrEmailToHint => 'to@example.com';

  @override
  String get createQrEmailSubjectLabel => 'Subject';

  @override
  String get createQrEmailSubjectHint => 'Chủ đề...';

  @override
  String get createQrEmailBodyLabel => 'Body';

  @override
  String get createQrEmailBodyHint => 'Nội dung email...';

  @override
  String get createQrDesignTitle => 'Thiết kế';

  @override
  String get createQrColorLabel => 'Màu QR';

  @override
  String get createQrLogoOptional => 'Logo (tuỳ chọn)';

  @override
  String get createQrUploadLogo => 'Tải lên logo';

  @override
  String get createQrPreviewTitle => 'Xem trước';

  @override
  String get scanFlashTooltip => 'Đèn flash';

  @override
  String get scanSwitchCameraTooltip => 'Đổi camera';

  @override
  String get scanAlignHint => 'Đưa QR vào giữa khung';

  @override
  String get borrowScanBookTitle => 'Quét QR sách';

  @override
  String get borrowScanBookHint => 'bookId / ISBN trên tem sách';

  @override
  String get borrowScanStudentTitle => 'Quét QR sinh viên';

  @override
  String get borrowScanStudentHint => 'Mã LIB_USER:... trên hồ sơ SV';

  @override
  String get borrowScannedReturnTicketHelp =>
      'Đây là mã phiếu (khi trả). Vào Trả sách → Quét phiếu mượn.';

  @override
  String get borrowScannedStudentCodeHelp =>
      'Đây là mã sinh viên — dùng ô Sinh viên hoặc nút Quét QR SV';

  @override
  String get borrowScannedBorrowTicketNotForStudent =>
      'Đây là mã phiếu mượn — không dùng cho ô sinh viên';

  @override
  String get borrowSignedInAsAdmin => 'Đăng nhập: Quản trị viên';

  @override
  String get borrowSignedInAsManager => 'Đăng nhập: Quản lý / thủ thư';

  @override
  String get borrowCreateFlowHint =>
      'Quét/nhập sách trước, sau đó sinh viên — chỉ khi đủ hai phần mới tạo phiếu. (Camera ở đây là màn quét riêng, không dùng tab Quét trên trang chủ.)';

  @override
  String get borrowScanStudentTooltip => 'Quét QR sinh viên';

  @override
  String get borrowScanStudentInlineHint => 'Quét QR để lấy uid/email/MSSV';

  @override
  String get borrowBookNotFound => 'Sách không tồn tại';

  @override
  String borrowStudentProfileMissing(Object uid) {
    return 'Không có hồ sơ sinh viên trong Firestore (users/$uid).';
  }

  @override
  String get borrowOutOfStock => 'Sách đã hết (availableQuantity = 0)';

  @override
  String get borrowNotificationTitle => 'Mượn sách thành công';

  @override
  String borrowNotificationBody(Object bookTitle, Object dueDate) {
    return '$bookTitle — hạn trả $dueDate';
  }

  @override
  String get borrowPermissionDeniedHelp =>
      'Không có quyền ghi Firestore (permission-denied). Kiểm tra users.role = manager/admin và đã deploy rules.';

  @override
  String borrowCreateFailedWithCode(Object code, Object message) {
    return 'Không thể tạo phiếu mượn [$code]: $message';
  }

  @override
  String get borrowStepBook => 'Sách';

  @override
  String get borrowStepStudent => 'Sinh viên';

  @override
  String get borrowStepCreateTicket => 'Tạo phiếu';

  @override
  String get statisticsTitle => 'Thống kê';

  @override
  String get statsBooksTitle => 'Đầu sách';

  @override
  String statsBooksCopiesDelta(Object copies) {
    return '$copies bản';
  }

  @override
  String get statsAvailableTitle => 'Còn trong kho';

  @override
  String get statsAvailableDelta => 'Khả dụng';

  @override
  String get statsBorrowingTitle => 'Đang mượn';

  @override
  String get statsBorrowingDelta => 'Phiếu hoạt động';

  @override
  String get statsReturnedLateTitle => 'Đã trả / trễ';

  @override
  String statsLateDelta(Object count) {
    return 'Trễ: $count';
  }

  @override
  String get statsStableDelta => 'Ổn định';

  @override
  String get deskTitle => 'Bàn làm việc thư viện';

  @override
  String get deskSubtitle =>
      'Tra cứu và thao tác mượn/trả bằng mã — không cần quét QR (giao diện web).';

  @override
  String get deskLookupTitle => 'Tra cứu sách';

  @override
  String get deskCodeHint => 'Nhập bookId (Firestore id) hoặc ISBN';

  @override
  String get enterBookIdOrIsbn => 'Nhập bookId hoặc ISBN';

  @override
  String lookupError(Object message) {
    return 'Lỗi tra cứu: $message';
  }

  @override
  String get quickActions => 'Tác vụ nhanh';

  @override
  String get quickCreateBorrow => 'Tạo phiếu mượn';

  @override
  String get quickCreateBorrowSubtitle => 'Nhập bookId & sinh viên';

  @override
  String get quickReturn => 'Trả sách';

  @override
  String get quickReturnSubtitle => 'Theo phiếu đang mượn';

  @override
  String get quickCurrentBorrows => 'Đang mượn';

  @override
  String get quickCurrentBorrowsSubtitle => 'Danh sách phiếu';

  @override
  String get quickHistory => 'Lịch sử';

  @override
  String get quickHistorySubtitle => 'Toàn bộ phiếu';

  @override
  String get addBookTitle => 'Thêm sách mới';

  @override
  String get editBookTitle => 'Cập nhật sách';

  @override
  String get excelImportTitle => 'Nhập từ file Excel';

  @override
  String get downloadExcelTemplate => 'Tải file mẫu: 5 sách, cột tiếng Việt';

  @override
  String get pickXlsx => 'Chọn file .xlsx';

  @override
  String get importInventory => 'Nhập kho';

  @override
  String importNBooks(Object count) {
    return 'Nhập $count sách';
  }

  @override
  String get categoryAddTitle => 'Thêm danh mục mới';

  @override
  String get categoryRenameTitle => 'Đổi tên danh mục';

  @override
  String get categoryNameHint => 'Tên danh mục';

  @override
  String get categoryNameRequired => 'Nhập tên danh mục';

  @override
  String categoryAddedToast(Object name) {
    return 'Đã thêm danh mục \"$name\"';
  }

  @override
  String get categoryUpdatedToast => 'Đã cập nhật';

  @override
  String get categoryDeleteTitle => 'Xóa danh mục?';

  @override
  String categoryDeleteBody(Object name) {
    return 'Xóa \"$name\" khỏi danh sách quản lý. Không có sách nào đang dùng danh mục này.';
  }

  @override
  String get categoryDeletedToast => 'Đã xóa danh mục';

  @override
  String get categoryDeleteHasBooksTitle => 'Danh mục đang có sách';

  @override
  String categoryDeleteHasBooksBody(Object count, Object name) {
    return 'Có $count đầu sách đang gán danh mục \"$name\". Chuyển sang danh mục khác, hoặc xóa hết các đầu sách đó (không hoàn tác).';
  }

  @override
  String get categoryDeleteMoveToLabel => 'Chuyển tất cả sách sang';

  @override
  String get categoryDeleteButtonReassign => 'Chuyển sách và xóa danh mục';

  @override
  String get categoryDeleteButtonPurgeBooks => 'Xóa hết sách và danh mục';

  @override
  String get categoryDeletePurgeConfirmTitle => 'Xác nhận xóa sách?';

  @override
  String categoryDeletePurgeConfirmBody(Object count) {
    return 'Sẽ xóa vĩnh viễn $count đầu sách đang thuộc danh mục này. Tiếp tục?';
  }

  @override
  String get categoryDeleteToastReassigned => 'Đã chuyển sách và xóa danh mục';

  @override
  String get categoryDeleteToastPurged => 'Đã xóa sách và danh mục';

  @override
  String categoryDeleteNoMoveTarget(Object name) {
    return 'Chưa có danh mục đích. Hãy thêm ít nhất một danh mục khác (khác \"$name\") rồi thử lại, hoặc chọn xóa hết sách.';
  }

  @override
  String get returnFindTitle => 'Tìm phiếu mượn cần trả';

  @override
  String get returnFindBody =>
      'Thủ thư chỉ cần quét QR phiếu mượn (LIB_RET:…) để trả. Trường hợp mất phiếu có thể nhập sách + sinh viên rồi bấm TÌM.';

  @override
  String get enterBookCode => 'Nhập mã sách (bookId hoặc ISBN)';

  @override
  String get bookIdOrIsbnHint => 'bookId / ISBN';

  @override
  String get studentQueryLabel => 'Sinh viên (uid / email hoặc MSSV)';

  @override
  String get studentQueryHint => 'uid / Email hoặc MSSV';

  @override
  String get findBorrowingRecord => 'TÌM PHIẾU ĐANG MƯỢN';

  @override
  String get borrowRecordLabel => 'Phiếu mượn';

  @override
  String get borrowRecordNotSelected =>
      'Chưa chọn phiếu mượn. Hãy tìm theo sách + sinh viên.';

  @override
  String returnLoadRecordError(Object message) {
    return 'Lỗi tải phiếu: $message';
  }

  @override
  String get returnRecentHistory => 'Lịch sử trả gần đây';

  @override
  String get returnEnterBookAndStudent =>
      'Vui lòng nhập mã sách và email/MSSV sinh viên';

  @override
  String get returnBookNotFound => 'Không tìm thấy sách';

  @override
  String get returnStudentNotFound => 'Không tìm thấy sinh viên';

  @override
  String get returnNoActiveBorrowFound =>
      'Không tìm thấy phiếu đang mượn cho sách và sinh viên này';

  @override
  String returnLookupError(Object message) {
    return 'Lỗi tìm phiếu: $message';
  }

  @override
  String get returnNeedRelogin => 'Bạn cần đăng nhập lại';

  @override
  String get returnSuccessToast => 'Xác nhận trả sách thành công';

  @override
  String returnConfirmError(Object message) {
    return 'Không thể trả sách: $message';
  }

  @override
  String get returnDeleteRecord => 'Xóa phiếu';

  @override
  String get returnConfirmButton => 'Xác nhận trả';

  @override
  String get returnCannotLoadHistory => 'Không thể tải lịch sử trả';

  @override
  String get returnNoRecentReturns => 'Chưa có lượt trả nào gần đây';

  @override
  String returnBookPrefix(Object bookId) {
    return 'Book: $bookId';
  }

  @override
  String returnDueDateLabel(Object date) {
    return 'Hạn trả: $date';
  }

  @override
  String get returnMissingBookName => '(Chưa có tên sách)';

  @override
  String returnLateDaysFine(Object days, Object fine) {
    return 'Trễ $days ngày • Phạt tạm tính: $fine';
  }

  @override
  String returnLateWithFine(Object fine) {
    return 'Trả trễ • Phạt: $fine';
  }

  @override
  String get returnOnTime => 'Trả đúng hạn';

  @override
  String get statusAll => 'Tất cả';

  @override
  String get statusBorrowing => 'Đang mượn';

  @override
  String get statusReturned => 'Đã trả';

  @override
  String get statusLate => 'Trả trễ';

  @override
  String get loginSubtitleWeb => 'Cổng quản trị — Admin & Quản lý';

  @override
  String get loginSubtitleMobile =>
      'Sinh viên & Quản lý — Admin dùng trình duyệt web';

  @override
  String get loginSnackWebStaffOnly =>
      'Chỉ tài khoản Admin hoặc Quản lý được đăng nhập trên web. Sinh viên vui lòng dùng ứng dụng di động.';

  @override
  String get loginSnackAdminWebOnly =>
      'Tài khoản Admin chỉ đăng nhập trên trình duyệt web. Quản lý và sinh viên dùng app này.';

  @override
  String get loginSnackGoogleWebStaffOnly =>
      'Chỉ tài khoản Admin hoặc Quản lý được đăng nhập trên web. Tài khoản Google này là sinh viên — vui lòng dùng app di động.';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get loginGoogleFailed => 'Đăng nhập với Google thất bại';

  @override
  String get authErrUserNotFound => 'Không tìm thấy tài khoản với email này';

  @override
  String get authErrWrongPassword => 'Mật khẩu không đúng';

  @override
  String get authErrInvalidCredential => 'Email hoặc mật khẩu không đúng';

  @override
  String get authErrUserDisabled => 'Tài khoản đã bị vô hiệu hóa';

  @override
  String get authErrNetwork =>
      'Không thể kết nối mạng. Vui lòng kiểm tra lại internet.';

  @override
  String get categoryAll => 'Tất cả';

  @override
  String get categoryOther => 'Khác';

  @override
  String get demoCategoryTech => 'Công nghệ';

  @override
  String get demoCategoryEcon => 'Kinh tế';

  @override
  String get demoCategoryLit => 'Văn học';

  @override
  String get demoCategorySci => 'Khoa học';

  @override
  String get demoCategoryHist => 'Lịch sử';

  @override
  String get demoCategoryEdu => 'Giáo dục';

  @override
  String get sortOptionTitle => 'Tên sách';

  @override
  String get sortOptionAuthor => 'Tác giả';

  @override
  String get sortOptionCategory => 'Danh mục';

  @override
  String get sortOptionStock => 'Số lượng còn';

  @override
  String get sortOptionDateAdded => 'Ngày thêm';

  @override
  String get bookStatTotalBooks => 'Tổng sách';

  @override
  String get bookStatAvailable => 'Có sẵn';

  @override
  String get bookStatBorrowed => 'Đang mượn';

  @override
  String get excelImportFormatHint =>
      'File .xlsx — dòng 1 là tiêu đề cột. Bắt buộc: tên sách và tác giả (vd: title, author / tên sách, tác giả). Tùy chọn: danh mục (nhóm demo), thể loại (liên kết genres), mã thể loại (genre id), năm xuất bản, isbn, số lượng, mô tả.';

  @override
  String get bookQuantityLabel => 'Số lượng';

  @override
  String get bookDescriptionSectionTitle => 'Mô tả';

  @override
  String get bookDescriptionFieldLabel => 'Mô tả sách';

  @override
  String get bookDescriptionFieldHint => 'Mô tả ngắn về nội dung cuốn sách…';

  @override
  String get bookDetailTotalQuantity => 'Tổng số lượng';

  @override
  String get bookDetailAvailable => 'Đang có sẵn';

  @override
  String get bookDetailOnLoan => 'Đang được mượn';

  @override
  String get bookDetailQrScanHint => 'Quét mã để tra cứu sách / tạo phiếu mượn';

  @override
  String get bookDetailIsbnTile => 'Mã ISBN';

  @override
  String get bookDetailCategoryTile => 'Danh mục';

  @override
  String get bookDetailAuthorTile => 'Tác giả';

  @override
  String get bookDetailPublishedYearTile => 'Năm xuất bản';

  @override
  String get bookDetailGenreTile => 'Thể loại';

  @override
  String get bookDetailBorrowableTile => 'Cho mượn';

  @override
  String get bookDetailBorrowableYes => 'Còn cho mượn';

  @override
  String get bookDetailBorrowableNo => 'Tạm không cho mượn';

  @override
  String get bookDetailTotalBorrowsTile => 'Tổng lượt mượn';

  @override
  String get bookDetailCreatedAtTile => 'Ngày thêm';

  @override
  String get bookDetailUpdatedAtTile => 'Cập nhật lần cuối';

  @override
  String get bookDetailValueDash => '—';

  @override
  String get bookDetailMetadataSection => 'Hoạt động & cập nhật';

  @override
  String get bookNoDescription => 'Chưa có mô tả cho cuốn sách này.';

  @override
  String get bookDetailActionCreateBorrow => 'Tạo phiếu';

  @override
  String get bookDetailActionShare => 'Chia sẻ';

  @override
  String get bookDetailActionPrint => 'In';

  @override
  String get studentHomeStatUniqueTitles => 'Đầu sách';

  @override
  String get studentHomeStatLibraryStock => 'Kho thư viện';

  @override
  String get studentHomeStatActiveBorrows => 'Đang mượn';

  @override
  String get studentHomeStatActiveTickets => 'Phiếu hoạt động';

  @override
  String get studentHomeStatCategories => 'Danh mục';

  @override
  String get studentHomeStatCategoryKinds => 'Loại sách';

  @override
  String get studentHomeStatBorrowedToday => 'Mượn hôm nay';

  @override
  String get studentHomeStatWithinToday => 'Trong ngày';

  @override
  String timeAgoMinutes(int count) {
    return '$count phút trước';
  }

  @override
  String timeAgoHours(int count) {
    return '$count giờ trước';
  }

  @override
  String timeAgoDays(int count) {
    return '$count ngày trước';
  }

  @override
  String get currentBorrowsPermissionHint =>
      'Gợi ý: nếu báo permission-denied, hãy kiểm tra tài liệu user trên Firestore (collection users) có trường role là manager hoặc admin, và đã deploy firestore.rules.';

  @override
  String borrowSheetFine(Object amount) {
    return 'Phạt: $amount';
  }

  @override
  String bookTitleFallback(Object id) {
    return 'Sách ($id)';
  }

  @override
  String get userNamePlaceholder => '(Chưa có tên)';

  @override
  String get statsSectionScansOverTime => 'Lượt quét theo thời gian';

  @override
  String get statsSectionLast7Days => '7 ngày qua';

  @override
  String get statsDateRangeThisWeek => 'Tuần này';

  @override
  String get statsCategoryBreakdownTitle => 'Phân loại';

  @override
  String get statsTopBorrowedTitle => 'Top sách mượn nhiều';

  @override
  String statsFolderLabel(Object name) {
    return 'Thư mục: $name';
  }

  @override
  String get statsBorrowCountUnit => 'lượt mượn';

  @override
  String get statsNoChartData => 'Không có dữ liệu';

  @override
  String get statsEmptyTopBooks => 'Chưa có phiếu mượn';

  @override
  String get statsBookFallbackTitle => 'Sách';

  @override
  String get statsExportReport => 'XUẤT BÁO CÁO';

  @override
  String get statsExportDone => 'Đã bắt đầu tải file báo cáo.';

  @override
  String statsExportError(Object error) {
    return 'Xuất thất bại: $error';
  }

  @override
  String get statsPermissionDenied => 'Bạn không có quyền xem thống kê.';

  @override
  String get statsLoadError =>
      'Không thể tải dữ liệu thống kê (kiểm tra quyền Firestore).';

  @override
  String get statsDateRangeHelp =>
      'Chọn khoảng ngày (áp dụng cho lượt mượn & báo cáo)';

  @override
  String get statsDatePickerDone => 'XONG';

  @override
  String get statsDatePickerCancel => 'HỦY';

  @override
  String get statsExportPickFormat => 'Chọn định dạng xuất';

  @override
  String get statsExportFormatExcel => 'Microsoft Excel (.xlsx)';

  @override
  String get statsExportFormatPdf => 'PDF (.pdf)';

  @override
  String get statsOverviewSection => 'Tổng quan';

  @override
  String get statsOverviewSubtitle =>
      'Một số chỉ số là toàn thư viện; lượt mượn áp dụng khoảng ngày ở trên.';

  @override
  String get statsCardBookTitles => 'Đầu sách';

  @override
  String statsDeltaTotalPrintCopies(Object copies) {
    return '$copies bản in';
  }

  @override
  String get statsCardUsers => 'Người dùng';

  @override
  String get statsDeltaAccounts => 'Tài khoản';

  @override
  String get statsCardBorrowTurnsPeriod => 'Lượt mượn (kỳ)';

  @override
  String get statsDeltaByBorrowDate => 'Theo borrowDate';

  @override
  String get statsCardActiveTickets => 'Phiếu đang mượn';

  @override
  String get statsDeltaSystemWide => 'Toàn hệ thống';

  @override
  String get statsCardInStock => 'Còn trong kho';

  @override
  String get statsDeltaTotalAvailable => 'Tổng available';

  @override
  String get statsCardReturnedLatePeriod => 'Đã trả / Trễ (kỳ)';

  @override
  String statsDeltaLateShort(Object count) {
    return 'Trễ: $count';
  }

  @override
  String get statsBorrowReturnPeriodSection => 'Mượn — trả trong kỳ';

  @override
  String get statsKvBorrowingTicketsInPeriod => 'Đang mượn (phiếu trong kỳ)';

  @override
  String get statsKvReturned => 'Đã trả';

  @override
  String get statsKvLateRecorded => 'Trễ hạn (ghi nhận)';

  @override
  String get statsKvOnTimeRate => 'Tỷ lệ trả đúng hạn*';

  @override
  String get statsKvAvgBorrowDaysReturned => 'Thời gian mượn TB (đã trả)';

  @override
  String statsKvAvgBorrowDaysValue(Object days) {
    return '$days ngày';
  }

  @override
  String get statsFootnoteOnTimeReturns =>
      '*Trong các phiếu đã trả có đủ ngày mượn/trả/hạn trong kỳ.';

  @override
  String get statsDailyBorrowsSection => 'Lượt mượn theo ngày (trong kỳ)';

  @override
  String statsTotalTurns(Object count) {
    return 'Tổng $count lượt';
  }

  @override
  String get statsMonthlyBorrowsSection =>
      'Lượt mượn theo tháng (12 tháng gần nhất)';

  @override
  String get statsMonthlyTrendSubtitle => 'So sánh xu hướng theo borrowDate';

  @override
  String get statsCategoriesSection => 'Thể loại / danh mục';

  @override
  String get statsCategoriesDonutsSubtitle =>
      'Trái: tồn đầu sách — Phải: lượt mượn trong kỳ';

  @override
  String get statsDonutByInventory => 'Theo tồn (đầu sách)';

  @override
  String get statsDonutBorrowedInPeriod => 'Được mượn (kỳ)';

  @override
  String get statsTopCategoriesBorrowed => 'Top thể loại được mượn';

  @override
  String get statsBooksSection => 'Sách';

  @override
  String get statsBooksSectionsSubtitle =>
      'Top / ít mượn trong kỳ — Hết hàng — Mới thêm';

  @override
  String get statsTopBorrowedThisPeriod => 'Top mượn trong kỳ';

  @override
  String get statsLeastBorrowedThisPeriod => 'Ít được mượn (kỳ)';

  @override
  String get statsOutOfStockTitle => 'Hết hàng (available ≤ 0)';

  @override
  String get statsOutOfStockEmpty => 'Không có đầu sách nào hết hàng.';

  @override
  String get statsNewBooksInPeriodTitle => 'Sách mới trong kỳ (createdAt)';

  @override
  String get statsNewBooksEmpty => 'Không có sách mới trong khoảng ngày.';

  @override
  String get statsAuthorsByPeriodSection => 'Tác giả (theo lượt mượn kỳ)';

  @override
  String get statsUsersSection => 'Người dùng';

  @override
  String get statsTopUsersPeriod => 'Mượn nhiều trong kỳ (top 10)';

  @override
  String get statsBorrowersActiveTickets => 'Đang mượn (phiếu hoạt động)';

  @override
  String get statsBorrowersOverdue => 'Liên quan trễ hạn (phiếu trễ / quá hạn)';

  @override
  String statsMonthCompareTwo(
    Object m1,
    Object c1,
    Object m2,
    Object c2,
    Object arrow,
    Object diff,
  ) {
    return 'Hai tháng gần nhất: $m1 ($c1) → $m2 ($c2)  $arrow $diff lượt';
  }

  @override
  String statsBookStockSubtitle(Object avail, Object qty, Object authorSuffix) {
    return 'Còn $avail / $qty$authorSuffix';
  }

  @override
  String statsUserBorrowCount(Object count) {
    return '$count lượt';
  }

  @override
  String get statsBorrowersNone => 'Không có';

  @override
  String statsBorrowerOverdueCount(Object count) {
    return 'Trễ $count';
  }

  @override
  String statsBorrowerActiveCount(Object count) {
    return 'Phiếu $count';
  }

  @override
  String get exportStatReportTitleFull => 'Báo cáo thống kê thư viện (đầy đủ)';

  @override
  String get exportStatReportTitlePdf => 'Báo cáo thống kê thư viện';

  @override
  String exportStatDateRange(Object range) {
    return 'Khoảng ngày: $range';
  }

  @override
  String exportStatExportedAt(Object dateTime) {
    return 'Xuất lúc: $dateTime';
  }

  @override
  String get exportStatMetric => 'Chỉ số';

  @override
  String get exportStatValue => 'Giá trị';

  @override
  String get exportStatBookTitlesCount => 'Số đầu sách';

  @override
  String get exportStatTotalUsers => 'Tổng người dùng';

  @override
  String get exportStatTotalCopiesQty => 'Tổng bản (quantity)';

  @override
  String get exportStatTotalAvailableStock => 'Tổng còn trong kho (available)';

  @override
  String get exportStatBorrowsInPeriodBorrowDate =>
      'Lượt mượn trong kỳ (borrowDate)';

  @override
  String get exportStatActiveTicketsSystemWide =>
      'Phiếu đang mượn (toàn hệ thống)';

  @override
  String get exportStatPeriodBorrowingReturnedLate =>
      'Trong kỳ — đang mượn / đã trả / trễ';

  @override
  String get exportStatOnTimeReturnEstimate => 'Tỷ lệ trả đúng hạn (ước lượng)';

  @override
  String get exportStatAvgBorrowDaysReturned => 'Ngày mượn TB (đã trả)';

  @override
  String get exportStatSectionTopBorrowedPeriod => 'Top mượn trong kỳ';

  @override
  String get exportColRank => 'Hạng';

  @override
  String get exportColBookTitle => 'Tên sách';

  @override
  String get exportColCategory => 'Danh mục';

  @override
  String get exportColBorrowsShort => 'Lượt';

  @override
  String get exportColBorrowCountLong => 'Lượt mượn';

  @override
  String get exportExcelColId => 'id';

  @override
  String get exportExcelColTitle => 'title';

  @override
  String get exportExcelColAuthor => 'author';

  @override
  String get exportExcelColCategoryField => 'category';

  @override
  String get exportExcelColQuantity => 'quantity';

  @override
  String get exportExcelColAvailableQuantity => 'availableQuantity';

  @override
  String get exportExcelColBorrowId => 'id';

  @override
  String get exportExcelColBookId => 'bookId';

  @override
  String get exportExcelColUserId => 'userId';

  @override
  String get exportExcelColStatus => 'status';

  @override
  String get exportExcelColBorrowDate => 'borrowDate';

  @override
  String get exportExcelColDueDate => 'dueDate';

  @override
  String get exportExcelColReturnDate => 'returnDate';

  @override
  String get exportExcelColBookTitleSnapshot => 'bookTitleSnapshot';

  @override
  String get exportExcelColDisplayName => 'Tên';

  @override
  String get exportExcelColBorrowsInPeriod => 'Lượt (kỳ)';

  @override
  String get exportExcelColAuthorName => 'Tác giả';

  @override
  String get exportExcelColAuthorBorrowsInPeriod => 'Lượt mượn (kỳ)';

  @override
  String get exportExcelEncodeError => 'Không tạo được file Excel.';

  @override
  String get exportPdfTopBooksInRange => 'Top sách mượn (trong khoảng)';

  @override
  String get exportPdfNoTableData => 'Không có dữ liệu.';

  @override
  String exportPdfBorrowRecordsLimited(Object cap, Object total) {
    return 'Phiếu mượn (giới hạn hiển thị $cap / $total)';
  }

  @override
  String get exportPdfNoBorrowRecordsInRange => 'Không có phiếu trong khoảng.';

  @override
  String get exportPdfColTicketId => 'ID phiếu';

  @override
  String get exportPdfColBookId => 'bookId';

  @override
  String get exportPdfColUserId => 'userId';

  @override
  String get exportPdfColStatus => 'Trạng thái';

  @override
  String get exportPdfColBorrowDate => 'Ngày mượn';

  @override
  String get exportPdfColDueDate => 'Hạn trả';

  @override
  String get exportPdfPeriodBorrowReturnLate => 'Kỳ: đang mượn / trả / trễ';

  @override
  String get manageAuthors => 'Tác giả';

  @override
  String get manageGenres => 'Thể loại';

  @override
  String get manageStationery => 'Văn phòng phẩm';

  @override
  String get manageLibraryConfig => 'Quy tắc mượn & giới hạn';

  @override
  String get manageAuditLog => 'Nhật ký thao tác';

  @override
  String get webAdminSettingsSection => 'Quản trị';

  @override
  String get libraryBusinessSettingsTitle => 'Cấu hình nghiệp vụ thư viện';

  @override
  String get libraryBusinessSettingsSubtitle =>
      'Số ngày mượn gợi ý và giới hạn số sách mượn cùng lúc mỗi người.';

  @override
  String get libraryConfigLoanDaysLabel => 'Số ngày mượn gợi ý (phiếu mới)';

  @override
  String libraryConfigLoanDaysHelper(Object min, Object max) {
    return 'Khoảng gợi ý: $min–$max ngày (dùng làm hạn trả mặc định).';
  }

  @override
  String get libraryConfigMaxBorrowsLabel =>
      'Giới hạn số sách mượn cùng lúc / người';

  @override
  String get libraryConfigMaxBorrowsHelper =>
      'Người dùng không thể mượn thêm nếu đã đạt số phiếu đang mượn này.';

  @override
  String get libraryConfigSave => 'Lưu cấu hình';

  @override
  String get libraryConfigSaved => 'Đã lưu cấu hình.';

  @override
  String libraryConfigSaveError(Object error) {
    return 'Không lưu được: $error';
  }

  @override
  String get libraryConfigLoanDaysInvalid =>
      'Số ngày mượn phải nằm trong khoảng gợi ý.';

  @override
  String get libraryConfigMaxBorrowsInvalid => 'Giới hạn phải từ 1 đến 99.';

  @override
  String get adminOnlyLibraryConfig =>
      'Chỉ quản trị viên mới chỉnh được mục này.';

  @override
  String get auditLogTitle => 'Nhật ký thao tác';

  @override
  String get auditLogEmpty => 'Chưa có bản ghi nhật ký.';

  @override
  String get auditLogAdminOnly => 'Chỉ quản trị viên xem được nhật ký.';

  @override
  String auditLogLoadError(Object error) {
    return 'Không tải được nhật ký: $error';
  }

  @override
  String get authorsManageTitle => 'Tác giả';

  @override
  String get staffOnlyAuthorManage => 'Chỉ nhân sự mới quản lý tác giả.';

  @override
  String authorsLoadError(Object error) {
    return 'Không tải được tác giả: $error';
  }

  @override
  String get authorsEmpty => 'Chưa có tác giả.';

  @override
  String get authorsAddFirst => 'Thêm tác giả đầu tiên';

  @override
  String get authorsAdd => 'Thêm tác giả';

  @override
  String get authorsAddTitle => 'Tác giả mới';

  @override
  String get authorsEditTitle => 'Sửa tác giả';

  @override
  String get authorsNameLabel => 'Tên';

  @override
  String get authorsDescLabel => 'Tiểu sử (tuỳ chọn)';

  @override
  String get authorsNameRequired => 'Vui lòng nhập tên.';

  @override
  String authorsAdded(Object name) {
    return 'Đã thêm tác giả: $name';
  }

  @override
  String get authorsUpdated => 'Đã cập nhật tác giả.';

  @override
  String get authorsUntitled => '(Chưa đặt tên)';

  @override
  String get authorsDeleteTitle => 'Xoá tác giả?';

  @override
  String authorsDeleteBody(Object name) {
    return 'Xoá “$name”? Sách tham chiếu không bị xoá.';
  }

  @override
  String get authorsDeleted => 'Đã xoá tác giả.';

  @override
  String authorsDeleteError(Object error) {
    return 'Không xoá được: $error';
  }

  @override
  String get genresManageTitle => 'Thể loại';

  @override
  String get staffOnlyGenreManage => 'Chỉ nhân sự mới quản lý thể loại.';

  @override
  String genresLoadError(Object error) {
    return 'Không tải được thể loại: $error';
  }

  @override
  String get genresEmpty => 'Chưa có thể loại.';

  @override
  String get genresAddFirst => 'Thêm thể loại đầu tiên';

  @override
  String get genresAdd => 'Thêm thể loại';

  @override
  String get genresAddTitle => 'Thể loại mới';

  @override
  String get genresEditTitle => 'Đổi tên thể loại';

  @override
  String get genresNameHint => 'Tên thể loại';

  @override
  String get genresNameRequired => 'Vui lòng nhập tên.';

  @override
  String genresAdded(Object name) {
    return 'Đã thêm thể loại: $name';
  }

  @override
  String get genresUpdated => 'Đã cập nhật thể loại.';

  @override
  String get genresUntitled => '(Chưa đặt tên)';

  @override
  String get genresDeleteTitle => 'Xoá thể loại?';

  @override
  String genresDeleteBody(Object name) {
    return 'Xoá “$name”?';
  }

  @override
  String get genresDeleted => 'Đã xoá thể loại.';

  @override
  String genresDeleteError(Object error) {
    return 'Không xoá được: $error';
  }

  @override
  String get stationeryManageTitle => 'Văn phòng phẩm';

  @override
  String get staffOnlyStationeryManage =>
      'Chỉ nhân sự mới quản lý văn phòng phẩm.';

  @override
  String stationeryLoadError(Object error) {
    return 'Không tải được: $error';
  }

  @override
  String get stationeryEmpty => 'Chưa có mặt hàng.';

  @override
  String get stationeryAddFirst => 'Thêm mặt hàng đầu tiên';

  @override
  String get stationeryAdd => 'Thêm mặt hàng';

  @override
  String get stationeryAddTitle => 'Mặt hàng mới';

  @override
  String get stationeryEditTitle => 'Sửa mặt hàng';

  @override
  String get stationeryNameLabel => 'Tên';

  @override
  String get stationeryQuantityLabel => 'Số lượng';

  @override
  String get stationeryUnitLabel => 'Đơn vị (vd: hộp, xấp)';

  @override
  String get stationeryNameRequired => 'Vui lòng nhập tên.';

  @override
  String stationeryQtyLine(Object qty, Object unit) {
    return '$qty $unit';
  }

  @override
  String get stationeryAdded => 'Đã lưu.';

  @override
  String get stationeryUpdated => 'Đã cập nhật.';

  @override
  String get stationeryUntitled => '(Chưa đặt tên)';

  @override
  String get stationeryDeleteTitle => 'Xoá mặt hàng?';

  @override
  String stationeryDeleteBody(Object name) {
    return 'Xoá “$name”?';
  }

  @override
  String get stationeryDeleted => 'Đã xoá.';

  @override
  String stationeryDeleteError(Object error) {
    return 'Không xoá được: $error';
  }

  @override
  String get userManageStaffHintBody =>
      'Tài khoản mới đăng ký trên app di động. Để cấp quyền Admin hoặc Quản lý: tìm người dùng và đổi vai trò bên dưới. Tạo tài khoản Firebase Auth cho nhân sự (nếu cần) thực hiện trong Firebase Console hoặc backend.';

  @override
  String get userManageChangeRole => 'Đổi vai trò';

  @override
  String get userManagePickRole => 'Gán vai trò';

  @override
  String get userManageRoleChanged => 'Đã cập nhật vai trò.';

  @override
  String userManageRoleError(Object error) {
    return 'Không đổi được vai trò: $error';
  }

  @override
  String get userManageCannotRemoveLastAdmin =>
      'Phải có ít nhất một quản trị viên.';

  @override
  String get userManageCannotLockSelf =>
      'Bạn không thể tự khoá tài khoản của mình tại đây.';

  @override
  String get borrowSameBookAlready => 'Người này đang mượn cuốn sách này rồi.';

  @override
  String borrowMaxActiveReached(Object max) {
    return 'Người này đã đạt giới hạn số sách mượn cùng lúc ($max).';
  }

  @override
  String get brErrMaxActiveBorrows =>
      'Bạn đã đạt giới hạn số sách mượn cùng lúc.';

  @override
  String get scanBookUntitled => '(Chưa có tên sách)';

  @override
  String scanBookRemaining(Object avail, Object qty) {
    return 'Còn: $avail/$qty';
  }

  @override
  String get webDeskUntitledBook => '(Chưa có tiêu đề)';

  @override
  String webDeskRemainingIsbn(Object avail, Object qty, Object isbn) {
    return 'Còn $avail / $qty • ISBN: $isbn';
  }

  @override
  String get userFilterAll => 'Tất cả';

  @override
  String get userFilterAdmin => 'Admin';

  @override
  String get userFilterManager => 'Quản lý';

  @override
  String get userFilterStudent => 'Sinh viên';

  @override
  String get brErrBookNotFound => 'Không tìm thấy sách';

  @override
  String get brErrInvalidBookData => 'Dữ liệu sách không hợp lệ';

  @override
  String get brErrOutOfStock => 'Sách đã hết';

  @override
  String get brErrAlreadyBorrowing => 'Bạn đang mượn sách này';

  @override
  String get brErrNoActiveBorrow => 'Không tìm thấy phiếu mượn đang hoạt động';

  @override
  String get notifBorrowSuccessTitle => 'Mượn sách thành công';

  @override
  String notifBorrowSuccessBody(Object title, Object due) {
    return '$title — hạn trả $due';
  }

  @override
  String get notifReturnLateTitle => 'Trả sách trễ hạn';

  @override
  String get notifReturnOnTimeTitle => 'Đã trả sách';

  @override
  String notifReturnLateBody(Object title, Object days) {
    return '$title — trễ $days ngày';
  }

  @override
  String notifReturnOnTimeBody(Object title) {
    return '$title — cảm ơn bạn đã trả đúng hạn';
  }

  @override
  String notifReturnDeskBody(Object title) {
    return '$title — thủ thư xác nhận trả sách';
  }

  @override
  String get forgotPasswordIntro =>
      'Nhập email bạn đã dùng để đăng ký. Nếu email tồn tại trong hệ thống, chúng tôi sẽ gửi link đặt lại mật khẩu cho bạn.';

  @override
  String notifLoadFailed(Object error) {
    return 'Không tải được thông báo.\nNếu mới deploy, hãy tạo composite index (userId + createdAt) theo link trong console Firebase.\n\n$error';
  }

  @override
  String get notifEmptyStaff =>
      'Chưa có thông báo trên hệ thống.\nThông báo được tạo khi mượn/trả sách.';

  @override
  String get notifEmptyStudent =>
      'Bạn chưa có thông báo.\nSẽ có tin nhắn khi bạn mượn hoặc trả sách.';

  @override
  String get timeJustNow => 'Vừa xong';

  @override
  String categoryLoadFailed(Object error) {
    return 'Không tải được danh mục: $error';
  }

  @override
  String get categoryUntitled => '(Chưa đặt tên)';

  @override
  String get categoryUsedWhenAddingBooks =>
      'Dùng khi thêm sách (trường category)';

  @override
  String get categoryPermissionDeniedHint =>
      'Không có quyền ghi. Trên Firebase, mở Firestore → users → tài khoản của bạn → đặt trường role là \"admin\" hoặc \"manager\" (không chỉ đổi role trong app demo).';

  @override
  String categoryErrorGeneric(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get webStaffAccountFallback => 'Tài khoản';

  @override
  String get myQrDefaultDisplayName => 'Sinh viên';

  @override
  String get qrCreateEmptyPayload => 'Chưa có nội dung';

  @override
  String get qrCreateCatalogDefaultTitle => 'Danh mục thư viện';

  @override
  String get fineDemoTotalAmount => '50.000 đ';

  @override
  String get fineDemoTotalExplanation => 'Trả trễ 5 ngày x 10.000 đ/ngày';

  @override
  String get fineDemoLineAmount => '20.000 đ';

  @override
  String get fineDemoLineLateLabel => 'Trả trễ 2 ngày';

  @override
  String get excelErrNoSheetRows => 'File không có sheet chứa dòng dữ liệu.';

  @override
  String get excelErrSheetEmpty => 'Sheet trống.';

  @override
  String excelErrReadFailed(Object primary, Object fallback) {
    return 'Không đọc được file .xlsx.\n• Lỗi bộ đọc chính: $primary\n• Lỗi bộ đọc dự phòng: $fallback\nGợi ý: mở file trong Microsoft Excel → File → Save As → chọn định dạng “Excel Workbook (.xlsx)”.';
  }

  @override
  String excelErrReadFailedShort(Object error) {
    return 'Không đọc được file .xlsx: $error. Thử lưu lại bằng Excel (.xlsx) hoặc xuất lại từ Google Sheets (Tải xuống → Microsoft Excel).';
  }

  @override
  String get excelErrHeaderRow =>
      'Dòng 1 cần có cột nhận diện được cho tên sách (title / tên sách) và tác giả (author / tác giả).';

  @override
  String excelErrRowMissingTitle(Object row) {
    return 'Dòng $row: thiếu tên sách';
  }

  @override
  String excelErrRowMissingAuthor(Object row) {
    return 'Dòng $row: thiếu tác giả';
  }

  @override
  String excelErrRowInvalidQuantity(Object row) {
    return 'Dòng $row: số lượng không hợp lệ (tối thiểu 1)';
  }

  @override
  String get excelErrNoValidRows =>
      'Không có dòng dữ liệu hợp lệ (bỏ qua dòng trống).';

  @override
  String excelErrEnsureCategory(Object error) {
    return 'Không thể tạo danh mục hoặc gắn thể loại/tác giả: $error';
  }

  @override
  String get excelSampleSheetName => 'MauNhapSach';

  @override
  String get excelSampleColTitle => 'Tên sách';

  @override
  String get excelSampleColAuthor => 'Tác giả';

  @override
  String get excelSampleColCategory => 'Danh mục';

  @override
  String get excelSampleColGenre => 'Thể loại';

  @override
  String get excelSampleColPublishedYear => 'Năm xuất bản';

  @override
  String get excelSampleColIsbn => 'ISBN';

  @override
  String get excelSampleColQuantity => 'Số lượng';

  @override
  String get excelSampleColDescription => 'Mô tả';

  @override
  String get excelTemplateFileName => 'mau_nhap_sach_5_dong.xlsx';

  @override
  String get pushChannelName => 'Thư viện';

  @override
  String get pushChannelDescription => 'Thông báo mượn trả và nhắc hạn';

  @override
  String get pushDefaultTitle => 'Thư viện';

  @override
  String get pushFallbackTitle => 'Thông báo';

  @override
  String get errorWidgetDebugTitle => 'Lỗi build widget (debug)';

  @override
  String get errorWidgetReleaseTitle => 'Đã xảy ra lỗi';

  @override
  String get errorWidgetDebugDetailHint =>
      'Chi tiết giống console — có thể chọn và copy.';

  @override
  String get errorWidgetReleaseHint =>
      'Vui lòng thử lại hoặc liên hệ quản trị.';

  @override
  String get errorNoStack => '(không có stack)';
}

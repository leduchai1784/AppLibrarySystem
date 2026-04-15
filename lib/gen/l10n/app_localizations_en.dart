// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digital Library';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonSignIn => 'Sign in';

  @override
  String get loadMore => 'Load more';

  @override
  String get tabHome => 'Home';

  @override
  String get tabBorrowing => 'Borrowing';

  @override
  String get tabHistory => 'History';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabManage => 'Manage';

  @override
  String get tabBooks => 'Books';

  @override
  String get tabSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguageAppearance => 'Language & appearance';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get defaultQrColorTitle => 'Default QR color';

  @override
  String get defaultQrSizeTitle => 'Default QR size';

  @override
  String get qrSizeSmall200 => 'Small (200px)';

  @override
  String get qrSizeMedium256 => 'Medium (256px)';

  @override
  String get qrSizeLarge300 => 'Large (300px)';

  @override
  String get settingsAppPreferences => 'App preferences';

  @override
  String get settingsDefaultQrStyle => 'Default QR style';

  @override
  String get settingsDefaultColor => 'Default color';

  @override
  String get settingsDefaultSize => 'Default size';

  @override
  String get settingsCameraScanning => 'Camera & scanning';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsBiometricsUnsupported => 'Not supported on this device';

  @override
  String get settingsBiometricsHint =>
      'Try fingerprint / Face ID when unlocking.';

  @override
  String get settingsAppLockHint =>
      'Requires authentication when returning from background.';

  @override
  String get settingsAutofocusHint => 'Hint for the camera (device-dependent).';

  @override
  String get settingsBorrowReturnNotifsHint =>
      'Notifications when you borrow/return (saved on your account).';

  @override
  String get settingsPushNotifsHint =>
      'Show alerts when new library notifications arrive.';

  @override
  String get settingsLibraryData => 'Library data';

  @override
  String get settingsBackupLibraryJson => 'Backup library JSON';

  @override
  String get settingsBackupMyBorrows => 'Backup my borrows (JSON)';

  @override
  String get settingsSignOutAction => 'Sign out';

  @override
  String get systemFeaturesTitle => 'Feature settings';

  @override
  String get systemFeaturesSubtitle =>
      'Turn features on/off. Changes apply in real time.';

  @override
  String get systemFeaturesSaved => 'Feature settings saved.';

  @override
  String get systemFeaturesCoreSection => 'Core features';

  @override
  String get systemFeaturesAiSection => 'AI';

  @override
  String get systemFeaturesReportsSection => 'Reports';

  @override
  String get systemFeaturesScan => 'QR scanning';

  @override
  String get systemFeaturesScanHint => 'Enable/disable the Scan tab (QR/ISBN).';

  @override
  String get systemFeaturesBorrowReturn => 'Borrow/Return';

  @override
  String get systemFeaturesBorrowReturnHint =>
      'Enable/disable borrowing & returning flow.';

  @override
  String get systemFeaturesAiRecommendations => 'Book suggestions';

  @override
  String get systemFeaturesAiRecommendationsHint =>
      'Enable/disable AI suggestions section on Home.';

  @override
  String get systemFeaturesStatistics => 'Statistics';

  @override
  String get systemFeaturesStatisticsHint =>
      'Enable/disable Statistics/Reports screen.';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsInAppNotifications => 'In-app notifications';

  @override
  String get settingsQrDefaultColor => 'Default QR color';

  @override
  String get settingsQrDefaultSize => 'Default QR size';

  @override
  String get settingsScannerAutofocus => 'Autofocus';

  @override
  String get settingsScannerBeep => 'Beep on scan';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsPreferBiometrics => 'Prefer biometrics';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsClearLocalData => 'Clear local data & sign out';

  @override
  String get clearLocalDataTitle => 'Clear local app data?';

  @override
  String get clearLocalDataBody =>
      'Removes on-device settings and signs you out. Cloud data is not deleted.';

  @override
  String get clearLocalDataConfirm => 'Clear & sign out';

  @override
  String get webSystemSettingsTitle => 'System settings';

  @override
  String get webSystemSettingsSubtitle =>
      'Browser preferences. QR, camera and app lock are configured in the mobile app.';

  @override
  String get settingsProviderMissingBody =>
      'AppSettingsController provider not found. Check main.dart has ChangeNotifierProvider<AppSettingsController> and restart the app (not just hot reload).';

  @override
  String get settingsJsonDownloaded => 'JSON file downloaded.';

  @override
  String settingsExportFailed(Object message) {
    return 'Export failed: $message';
  }

  @override
  String get settingsBorrowReturnNotificationsTitle =>
      'Borrow & return notifications';

  @override
  String get settingsBorrowReturnNotificationsBody =>
      'Saved on your account. When off, in-app notifications for borrow/return are not created.';

  @override
  String get settingsExportJsonTitle =>
      'Export JSON (books, categories, records)';

  @override
  String get settingsMobileConfigHint =>
      'On mobile: default QR style, scanner, app lock and biometrics.';

  @override
  String get webDebugPanelHeader => '── Debug info (screenshot to dev) ──';

  @override
  String get webDebugPanelProviderYes => 'yes';

  @override
  String get webDebugPanelProviderNo => 'NO';

  @override
  String get webDebugPanelRoleMismatchHint =>
      'If role is student but Firestore is admin → click the button below then refresh the page.';

  @override
  String get myQrTitle => 'My QR';

  @override
  String get myQrHint =>
      'Show this code to the librarian when creating a borrow record.';

  @override
  String get notSignedInTitle => 'Not signed in';

  @override
  String get profileButton => 'Profile';

  @override
  String get myQrButton => 'My QR';

  @override
  String studentCodeLabel(Object code) {
    return 'Student ID: $code';
  }

  @override
  String get quickTasksTitle => 'Quick tasks';

  @override
  String get quickLibrary => 'Library';

  @override
  String get quickHistoryTab => 'History';

  @override
  String get recentBorrowsTitle => 'Recent borrows';

  @override
  String get seeAll => 'See all';

  @override
  String get cannotLoadRecentData => 'Unable to load recent data';

  @override
  String get noRecentBorrows => 'No recent borrows yet';

  @override
  String get needSignInToSeeStats => 'Sign in to see statistics';

  @override
  String get needSignIn => 'Please sign in';

  @override
  String get signInToConfigure => 'Sign in to configure';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageEnglish => 'English';

  @override
  String get reloadRoleSuccess =>
      'Reloaded role from Firestore. If sidebar is still incorrect, refresh the page.';

  @override
  String get reloadRoleButton => 'Reload role from Firestore';

  @override
  String get viewDetails => 'View details';

  @override
  String get adminSearchHint => 'Search books, users...';

  @override
  String get adminQuickTasksTitle => 'Quick tasks';

  @override
  String get adminQuickAddBook => 'Add book';

  @override
  String get adminQuickBookList => 'Book list';

  @override
  String get adminQuickCreateBorrow => 'Create borrow record';

  @override
  String get adminQuickReturn => 'Return book';

  @override
  String get adminQuickManageCategories => 'Manage categories';

  @override
  String get adminQuickManageUsers => 'Manage users';

  @override
  String get adminQuickStats => 'Statistics';

  @override
  String get adminQuickFinePayment => 'Fine payment';

  @override
  String get adminStatBookTitles => 'Titles';

  @override
  String get adminStatUsers => 'Users';

  @override
  String get adminStatTotalBorrows => 'Borrow records';

  @override
  String get adminStatActiveBorrow => 'Borrowing';

  @override
  String get qrScannerFlashTooltip => 'Flash';

  @override
  String get qrScannerSwitchCameraTooltip => 'Switch camera';

  @override
  String get qrScannerDefaultHint =>
      'Place the QR code inside the frame to scan';

  @override
  String get appLockedTitle => 'App locked';

  @override
  String get appLockedBody => 'Authenticate to continue.';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get biometricNotSupported =>
      'This device does not support authentication.';

  @override
  String get biometricReason => 'Unlock the library app';

  @override
  String get borrowTicketStaffOnlyReturn =>
      'Borrow ticket QR is only used for returning at the desk (staff accounts).';

  @override
  String get studentQrUsedForStaffCreateBorrow =>
      'This student QR is used when librarians create a borrow record.';

  @override
  String isbnLabel(Object isbn, Object available, Object quantity) {
    return 'ISBN: $isbn | Available: $available/$quantity';
  }

  @override
  String cannotUpdateStatus(Object message) {
    return 'Unable to update status: $message';
  }

  @override
  String get roleLabelAdminShort => 'Admin';

  @override
  String get roleLabelManagerShort => 'Manager';

  @override
  String get roleLabelStudentShort => 'Student';

  @override
  String lateFineLabel(Object amount) {
    return 'Fine: $amount';
  }

  @override
  String get ticketIdLabel => 'Ticket id';

  @override
  String get borrowDateLabelShort => 'Borrow date';

  @override
  String get dueDateLabelShort => 'Due date';

  @override
  String get librarianLabel => 'Librarian';

  @override
  String bookIdDebugLabel(Object id) {
    return 'bookId: $id';
  }

  @override
  String get remainingTotalLabel => 'remaining/total';

  @override
  String get lockedShort => 'Locked';

  @override
  String get bookDetailsAction => 'Book details';

  @override
  String get outOfStockCannotBorrow =>
      'Book is out of stock. Cannot create borrow record.';

  @override
  String get createBorrowRecordAction => 'Create borrow record';

  @override
  String get scanBorrowBookAction => 'BORROW BOOK';

  @override
  String get scanReturnBookAction => 'RETURN BOOK';

  @override
  String get scanAdminCreateBorrowAction => 'CREATE BORROW (ADMIN)';

  @override
  String get scanAdminReturnBookAction => 'RETURN BOOK (ADMIN)';

  @override
  String get statsWeekdayMon => 'Mon';

  @override
  String get statsWeekdayTue => 'Tue';

  @override
  String get statsWeekdayWed => 'Wed';

  @override
  String get statsWeekdayThu => 'Thu';

  @override
  String get statsWeekdayFri => 'Fri';

  @override
  String get statsWeekdaySat => 'Sat';

  @override
  String get statsWeekdaySun => 'Sun';

  @override
  String get viewFullList => 'View full list';

  @override
  String excelSelectedFile(Object name) {
    return 'Selected: $name';
  }

  @override
  String get excelNotesErrors => 'Notes / row errors:';

  @override
  String excelAndMoreLines(Object count) {
    return '... and $count more lines';
  }

  @override
  String get orEnterSingleBook => 'Or enter a single book';

  @override
  String get bookBasicInfoSection => 'Basic information';

  @override
  String get bookInventorySection => 'Inventory';

  @override
  String get submitUpdateBook => 'UPDATE BOOK';

  @override
  String get submitAddBook => 'ADD BOOK';

  @override
  String get bookTitleLabel => 'Book title';

  @override
  String get bookTitleHint => 'Enter book title';

  @override
  String get bookAuthorLabel => 'Author';

  @override
  String get bookAuthorHint => 'Enter author name';

  @override
  String get bookAuthorPickHint =>
      'Pick from the author catalog, or choose manual entry and type below.';

  @override
  String get bookAuthorManualOption => '— Manual entry —';

  @override
  String get bookGenreLabel => 'Genre';

  @override
  String get bookGenreNone => '— None —';

  @override
  String get bookCoverSectionTitle => 'Cover image';

  @override
  String get bookCoverPickGallery => 'Choose from gallery';

  @override
  String get bookCoverRemove => 'Remove image';

  @override
  String get bookCoverUrlLabel => 'Image URL (https)';

  @override
  String get bookCoverUrlHint =>
      'Optional — paste a direct image link, or pick a photo below (saved in Firestore, no Storage).';

  @override
  String get bookCoverImageTooLarge =>
      'Image file is still too large. Try another photo or use an HTTPS link.';

  @override
  String get bookCoverDataUrlTooLong =>
      'Encoded image exceeds Firestore limit. Use a smaller photo or an HTTPS link.';

  @override
  String get bookCategoryLabel => 'Category';

  @override
  String get bookIsbnLabel => 'ISBN';

  @override
  String get bookIsbnHint => '978-xxx-xxx-xxx';

  @override
  String fieldRequiredWithLabel(Object label) {
    return 'Please enter $label';
  }

  @override
  String get saveBookSuccessUpdate => 'Book updated successfully';

  @override
  String get saveBookSuccessAdd => 'Book added successfully';

  @override
  String saveBookError(Object message) {
    return 'Failed to save book: $message';
  }

  @override
  String get cannotCreateTemplate => 'Cannot generate template file.';

  @override
  String shareFileError(Object message) {
    return 'Cannot share/save file: $message';
  }

  @override
  String get excelTemplateSubject => 'Sample import template (5 books)';

  @override
  String get excelTemplateBody =>
      'Edit the sample Excel, then use the \"Choose .xlsx\" button above.';

  @override
  String get cannotReadFileContent =>
      'Cannot read file content. Try saving again as .xlsx or using a smaller file.';

  @override
  String excelPickReadError(Object message) {
    return 'File pick/read error: $message';
  }

  @override
  String firestoreWriteError(Object message) {
    return 'Firestore write error: $message';
  }

  @override
  String importedNBooksFromExcel(Object count) {
    return 'Imported $count books from Excel';
  }

  @override
  String get confirmDeleteTitle => 'Confirm delete';

  @override
  String get confirmDeleteBookBody =>
      'Are you sure you want to delete this book? This action cannot be undone.';

  @override
  String get bookDeletedToast => 'Book deleted';

  @override
  String deleteBookError(Object message) {
    return 'Failed to delete book: $message';
  }

  @override
  String genericErrorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String bookAuthorPrefix(Object author) {
    return 'Author: $author';
  }

  @override
  String get bookQrTitle => 'Book QR';

  @override
  String get bookInfoSection => 'Information';

  @override
  String get bookDescriptionSection => 'Description';

  @override
  String get bookMissingIdCannotBorrow =>
      'No book id available to create borrow record';

  @override
  String bookIdLabel(Object id) {
    return 'Book id: $id';
  }

  @override
  String get printNotSupported => 'Print is not supported yet';

  @override
  String sortByLabel(Object sortBy) {
    return 'Sort: $sortBy';
  }

  @override
  String get editAction => 'Edit';

  @override
  String get updateAction => 'Update';

  @override
  String get borrowRecordDetailsTitle => 'Borrow record details';

  @override
  String get bookLabel => 'Book';

  @override
  String get missingBookId => '(Missing book id)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get profileTitle => 'Profile';

  @override
  String get studentAppTitle => 'Library System - Student';

  @override
  String get borrowedBooksTitle => 'Borrowed books';

  @override
  String get borrowHistoryTitle => 'Borrow history';

  @override
  String get adminUseWebTitle => 'Admin uses the web portal';

  @override
  String get adminUseWebBody =>
      'Per system policy, Admin accounts sign in on the web (desktop/tablet) to manage data. The mobile app is for managers and students.';

  @override
  String get webStaffOnlyTitle => 'Web portal for Admin & Manager';

  @override
  String get webStaffOnlyBody => 'Student accounts: please use the mobile app.';

  @override
  String get webRegisterNotAllowedTitle => 'Register';

  @override
  String get webRegisterNotAllowedBody1 =>
      'Student registration is only available in the mobile app.';

  @override
  String get webRegisterNotAllowedBody2 =>
      'On the web, only Admin and Manager can sign in.';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get markedAllRead => 'Marked as read';

  @override
  String errorPrefix(Object message) {
    return 'Error: $message';
  }

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Register';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get noAccountRegister => 'No account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get agreeTermsRequired =>
      'Please agree to the Terms and Privacy Policy';

  @override
  String get enterEmailPassword => 'Please enter email and password';

  @override
  String get verifyEmailBeforeLogin =>
      'Your email is not verified. Please check your inbox and verify before signing in.';

  @override
  String get registerSuccessVerifyEmail =>
      'Registered successfully. Please verify your email before signing in.';

  @override
  String get commonOr => 'or';

  @override
  String get noAccountPrefix => 'No account?';

  @override
  String get registerAction => 'Register';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get resetEmailSentIfExists =>
      'If the email exists, a reset link has been sent. Please check your inbox (including Spam).';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String tryAgainLaterDetails(Object message) {
    return 'Something went wrong. Please try again later. Details: $message';
  }

  @override
  String get scanBookQrTitle => 'Scan book QR';

  @override
  String get manageTitle => 'Manage';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Password confirmation does not match';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get emailAlreadyInUse =>
      'This email is already in use. Please sign in or use another email.';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get weakPassword => 'Weak password. Please choose a stronger one.';

  @override
  String get passwordStrength => 'Password strength';

  @override
  String get iAgreeWith => 'I agree with';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get andWord => 'and';

  @override
  String get signUp => 'Sign up';

  @override
  String get alreadyHaveAccountPrefix => 'Already have an account?';

  @override
  String get signInAction => 'Sign in';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get bookDetailTitle => 'Book details';

  @override
  String get bookNotFound => 'This book does not exist or was deleted.';

  @override
  String get bookListTitle => 'Books';

  @override
  String get bookListSelectMode => 'Select books';

  @override
  String bookListSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get bookListSelectAllVisible => 'Select all visible';

  @override
  String get bookListDeselectAllVisible => 'Deselect all visible';

  @override
  String bookListBulkDelete(Object count) {
    return 'Delete ($count)';
  }

  @override
  String bookListBulkDeleteConfirm(Object count) {
    return 'Delete $count books? Books still on loan will be skipped.';
  }

  @override
  String bookListBulkDeleteResult(Object deleted, Object skipped) {
    return 'Deleted $deleted. Skipped (on loan): $skipped.';
  }

  @override
  String get bookListLongPressHint =>
      'Long-press a book to select multiple, then tap to add or remove.';

  @override
  String get addBook => 'Add book';

  @override
  String get categoriesManageTitle => 'Manage categories';

  @override
  String get categoriesManageBooksTitle => 'Manage book categories';

  @override
  String get staffOnlyCategoryEdit =>
      'Only Admin or Manager can edit categories.';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get addFirstCategory => 'Add your first category';

  @override
  String get addCategory => 'Add category';

  @override
  String get usersManageTitle => 'Manage users';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get deleteConfirmTitle => 'Confirm delete';

  @override
  String get deleteConfirmBookBody =>
      'Are you sure you want to delete this book? This action cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deletedBookToast => 'Book deleted';

  @override
  String get viewAsList => 'View as list';

  @override
  String get viewAsGrid => 'View as grid';

  @override
  String get sort => 'Sort';

  @override
  String get searchBooksHint =>
      'Search by title, author, ISBN, category, description, year…';

  @override
  String bookListMatchesCount(int count) {
    return '$count matching books';
  }

  @override
  String get bookListEmptyLibrary => 'No books in the library yet';

  @override
  String get noBooksMatchFilters => 'No books match your filters';

  @override
  String cannotLoadList(Object message) {
    return 'Failed to load list: $message';
  }

  @override
  String get noUsersYet => 'No users yet';

  @override
  String get staffOnlyUserManage =>
      'Only Admin can assign roles and lock users.';

  @override
  String get searchUsersHint => 'Search by name, email…';

  @override
  String get cannotLoadUsers => 'Failed to load users';

  @override
  String get lockedLabel => 'Locked';

  @override
  String get borrowCreateTitle => 'Create borrow record';

  @override
  String get returnBookTitle => 'Return book';

  @override
  String get scanBookTitle => 'Scan book QR';

  @override
  String get scanBookHint => 'bookId / ISBN on the book label';

  @override
  String get scanStudentTitle => 'Scan student QR';

  @override
  String get scanStudentHint => 'LIB_USER:... or student UID';

  @override
  String get scanBorrowTicketTitle => 'Scan borrow ticket';

  @override
  String get scanBorrowTicketHint => 'LIB_RET:... after borrowing';

  @override
  String get cannotReadBorrowTicket =>
      'Cannot read the ticket code (needs LIB_RET:... or record id)';

  @override
  String get borrowTicketNotFound => 'Borrow record not found';

  @override
  String get borrowTicketNotActive =>
      'This record is not active (status is not borrowing).';

  @override
  String get currentBorrowsTitle => 'Currently borrowed';

  @override
  String get cannotLoadCurrentBorrows => 'Failed to load current borrows';

  @override
  String get noActiveBorrowsStaff => 'No active borrow records';

  @override
  String get noActiveBorrowsStudent => 'You have no borrowed books';

  @override
  String dueDatePrefix(Object date) {
    return 'Due: $date';
  }

  @override
  String daysLeftPrefix(Object days) {
    return '$days days left';
  }

  @override
  String overduePrefix(Object days) {
    return 'Overdue $days days';
  }

  @override
  String get returnAction => 'Return';

  @override
  String get borrowHistoryTitle2 => 'Borrow history';

  @override
  String get cannotLoadBorrowHistory => 'Failed to load borrow history';

  @override
  String get noBorrowHistoryStaff => 'No borrow/return history yet';

  @override
  String get noBorrowHistoryStudent => 'You have no borrow/return history';

  @override
  String borrowedPrefix(Object borrow, Object ret) {
    return 'Borrowed: $borrow - Returned: $ret';
  }

  @override
  String finePrefix(Object amount) {
    return 'Fine: $amount';
  }

  @override
  String get finePaymentTitle => 'Fine payment';

  @override
  String get totalFineLabel => 'Total fine';

  @override
  String get fineDetailsTitle => 'Fine details';

  @override
  String get paymentMethodTitle => 'Payment method';

  @override
  String get cashAtLibrary => 'Cash at library';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String payAmountButton(Object amount) {
    return 'PAY $amount';
  }

  @override
  String get scanStudentQrButton => 'Scan student QR';

  @override
  String get scanBookQrButton => 'Scan book QR';

  @override
  String get findAction => 'Find';

  @override
  String get createBorrowButton => 'CREATE BORROW RECORD';

  @override
  String get bookCodeInputTitle => 'Enter book code (bookId or ISBN)';

  @override
  String get bookCodeHint => 'bookId / ISBN';

  @override
  String get studentBorrowerTitle => 'Borrower (email or student code)';

  @override
  String get studentBorrowerHint => 'Email or student code';

  @override
  String get borrowDateLabel => 'Borrow date';

  @override
  String expectedReturnDateLabel(Object days) {
    return 'Expected return date (loanDays = $days)';
  }

  @override
  String get borrowDueDateTitle => 'Expected return date';

  @override
  String get borrowDueDateHint =>
      '3–30 days from today (recommended 7–14). Tap to choose.';

  @override
  String get borrowDueDateErrorRange =>
      'Return date must be between 3 and 30 days from today.';

  @override
  String get pleaseEnterBookCode => 'Please enter bookId or ISBN';

  @override
  String get bookNotFoundShort => 'Book not found';

  @override
  String bookLookupError(Object message) {
    return 'Book lookup failed: $message';
  }

  @override
  String get pleaseEnterStudentQuery => 'Please enter email or student code';

  @override
  String get studentNotFound => 'Student not found';

  @override
  String studentLookupError(Object message) {
    return 'Student lookup failed: $message';
  }

  @override
  String get studentLockedCannotBorrow =>
      'This student account is locked and cannot borrow.';

  @override
  String get needReSignIn => 'Please sign in again';

  @override
  String get borrowCreatedSuccessTitle => 'Borrow record created';

  @override
  String get borrowCreatedSuccessBody =>
      'Scan this QR at the desk when returning:';

  @override
  String get scanTabUploadImage => 'Upload image';

  @override
  String get scanTabHistory => 'Scan history';

  @override
  String get scanTabNeedSwitchToScan =>
      'Switch to Scan tab and close overlays to scan from image.';

  @override
  String get qrInvalid => 'Invalid QR code';

  @override
  String get bookNotFoundFromQr => 'No book found from QR/ISBN';

  @override
  String get borrowSuccess => 'Borrowed successfully';

  @override
  String borrowFailed(Object message) {
    return 'Borrow failed: $message';
  }

  @override
  String get returnSuccess => 'Returned successfully';

  @override
  String returnFailed(Object message) {
    return 'Return failed: $message';
  }

  @override
  String get noQrFoundInImage => 'No QR found in the selected image';

  @override
  String cannotScanImage(Object message) {
    return 'Cannot scan image: $message';
  }

  @override
  String get bookInfoTitle => 'Book information';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String profileLoadError(Object message) {
    return 'Failed to load profile: $message';
  }

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String profileUpdateFailed(Object message) {
    return 'Update failed: $message';
  }

  @override
  String get profileFullNameLabel => 'Full name';

  @override
  String get profilePhoneLabel => 'Phone number';

  @override
  String get profileStudentCodeLabel => 'Student code';

  @override
  String get profileAddressLabel => 'Address';

  @override
  String get profileEmailReadonlyLabel => 'Email (read-only in app)';

  @override
  String get profileMissingName => '(Missing full name)';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleManager => 'Manager / Librarian';

  @override
  String get roleStudent => 'Student';

  @override
  String get manageCreateBorrow => 'Create borrow record';

  @override
  String get manageCreateBorrowSubtitle =>
      'Enter book and student to create a new record';

  @override
  String get manageReturnBook => 'Return book';

  @override
  String get manageReturnBookSubtitle =>
      'Scan ticket QR or search by book + student';

  @override
  String get manageCurrentBorrows => 'Current borrows';

  @override
  String get manageBorrowHistory => 'Borrow history';

  @override
  String get manageCategoryManage => 'Manage categories';

  @override
  String get manageUserManage => 'Manage users';

  @override
  String get manageStatsReports => 'Statistics & reports';

  @override
  String get webHello => 'Hello';

  @override
  String get webAdminOverviewSubtitle =>
      'Books inventory & borrow operations — web admin portal.';

  @override
  String get webSectionOverview => 'Overview';

  @override
  String get webSectionInventory => 'Inventory';

  @override
  String get webSectionDesk => 'Desk';

  @override
  String get webSectionOperations => 'Operations';

  @override
  String get webSectionSystemConfig => 'System configuration';

  @override
  String get webNotificationsTooltip => 'Notifications';

  @override
  String get webMenuProfile => 'Profile';

  @override
  String get webMenuSignOut => 'Sign out';

  @override
  String get webControlCenter => 'Control center';

  @override
  String get webMetricTitles => 'Titles';

  @override
  String get webMetricTitlesSub => 'in inventory';

  @override
  String get webMetricTotalCopies => 'Total copies';

  @override
  String get webMetricTotalCopiesSub => 'all copies';

  @override
  String get webMetricAvailable => 'Available';

  @override
  String get webMetricAvailableSub => 'availableQuantity';

  @override
  String get webMetricBorrowed => 'Borrowed';

  @override
  String get webMetricBorrowedSub => 'currently borrowed';

  @override
  String get webQuickAddBook => 'Add new book';

  @override
  String get webQuickStats => 'Statistics';

  @override
  String get createQrTitle => 'Create QR code';

  @override
  String get createQrSave => 'Save';

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
  String get createQrEnterContent => 'Please enter content to generate QR';

  @override
  String createQrCreatedToast(Object name) {
    return 'Created QR: $name';
  }

  @override
  String get createQrUnnamed => 'Unnamed';

  @override
  String get createQrActionButton => 'CREATE QR CODE';

  @override
  String get createQrContentTitle => 'Content';

  @override
  String get createQrNameLabel => 'QR name';

  @override
  String get createQrNameHint => 'e.g. Shelf A1 - Floor 2';

  @override
  String get createQrUrlLabel => 'Web URL';

  @override
  String get createQrUrlHint => 'https://library.example.com';

  @override
  String get createQrTextLabel => 'Text';

  @override
  String get createQrTextHint => 'Enter text...';

  @override
  String get createQrVcardFullNameLabel => 'Full name';

  @override
  String get createQrVcardFullNameHint => 'John Doe';

  @override
  String get createQrEmailLabel => 'Email';

  @override
  String get createQrEmailHint => 'name@example.com';

  @override
  String get createQrWifiSsidLabel => 'SSID';

  @override
  String get createQrWifiSsidHint => 'WiFi name';

  @override
  String get createQrWifiPasswordLabel => 'Password';

  @override
  String get createQrWifiPasswordHint => 'WiFi password';

  @override
  String get createQrEmailToLabel => 'To';

  @override
  String get createQrEmailToHint => 'to@example.com';

  @override
  String get createQrEmailSubjectLabel => 'Subject';

  @override
  String get createQrEmailSubjectHint => 'Subject...';

  @override
  String get createQrEmailBodyLabel => 'Body';

  @override
  String get createQrEmailBodyHint => 'Email body...';

  @override
  String get createQrDesignTitle => 'Design';

  @override
  String get createQrColorLabel => 'QR color';

  @override
  String get createQrLogoOptional => 'Logo (optional)';

  @override
  String get createQrUploadLogo => 'Upload logo';

  @override
  String get createQrPreviewTitle => 'Preview';

  @override
  String get scanFlashTooltip => 'Flash';

  @override
  String get scanSwitchCameraTooltip => 'Switch camera';

  @override
  String get scanAlignHint => 'Align QR code within the frame';

  @override
  String get borrowScanBookTitle => 'Scan book QR';

  @override
  String get borrowScanBookHint => 'bookId / ISBN on book label';

  @override
  String get borrowScanStudentTitle => 'Scan student QR';

  @override
  String get borrowScanStudentHint => 'LIB_USER:... on student profile';

  @override
  String get borrowScannedReturnTicketHelp =>
      'This is a return ticket QR. Go to Return → Scan ticket.';

  @override
  String get borrowScannedStudentCodeHelp =>
      'This is a student QR — use Student field or Scan student button.';

  @override
  String get borrowScannedBorrowTicketNotForStudent =>
      'This is a borrow ticket QR — not for student field.';

  @override
  String get borrowSignedInAsAdmin => 'Signed in: Admin';

  @override
  String get borrowSignedInAsManager => 'Signed in: Manager / Librarian';

  @override
  String get borrowCreateFlowHint =>
      'Scan/enter the book first, then the student — a record is created only when both are filled. (Camera here is a separate scanner screen.)';

  @override
  String get borrowScanStudentTooltip => 'Scan student QR';

  @override
  String get borrowScanStudentInlineHint =>
      'Scan QR to get uid/email/student ID';

  @override
  String get borrowBookNotFound => 'Book does not exist';

  @override
  String borrowStudentProfileMissing(Object uid) {
    return 'Student profile missing in Firestore (users/$uid).';
  }

  @override
  String get borrowOutOfStock => 'Book is out of stock (availableQuantity = 0)';

  @override
  String get borrowNotificationTitle => 'Borrow created';

  @override
  String borrowNotificationBody(Object bookTitle, Object dueDate) {
    return '$bookTitle — due $dueDate';
  }

  @override
  String get borrowPermissionDeniedHelp =>
      'No permission to write Firestore (permission-denied). Check users.role = manager/admin and deployed rules.';

  @override
  String borrowCreateFailedWithCode(Object code, Object message) {
    return 'Cannot create borrow record [$code]: $message';
  }

  @override
  String get borrowStepBook => 'Book';

  @override
  String get borrowStepStudent => 'Student';

  @override
  String get borrowStepCreateTicket => 'Create ticket';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statsBooksTitle => 'Titles';

  @override
  String statsBooksCopiesDelta(Object copies) {
    return '$copies copies';
  }

  @override
  String get statsAvailableTitle => 'Available';

  @override
  String get statsAvailableDelta => 'Available';

  @override
  String get statsBorrowingTitle => 'Borrowing';

  @override
  String get statsBorrowingDelta => 'Active records';

  @override
  String get statsReturnedLateTitle => 'Returned / Late';

  @override
  String statsLateDelta(Object count) {
    return 'Late: $count';
  }

  @override
  String get statsStableDelta => 'Stable';

  @override
  String get deskTitle => 'Library desk';

  @override
  String get deskSubtitle =>
      'Lookup and handle borrow/return by code — no camera needed (web).';

  @override
  String get deskLookupTitle => 'Book lookup';

  @override
  String get deskCodeHint => 'Enter bookId (Firestore id) or ISBN';

  @override
  String get enterBookIdOrIsbn => 'Enter bookId or ISBN';

  @override
  String lookupError(Object message) {
    return 'Lookup error: $message';
  }

  @override
  String get quickActions => 'Quick actions';

  @override
  String get quickCreateBorrow => 'Create borrow record';

  @override
  String get quickCreateBorrowSubtitle => 'Enter bookId & student';

  @override
  String get quickReturn => 'Return book';

  @override
  String get quickReturnSubtitle => 'By active record';

  @override
  String get quickCurrentBorrows => 'Borrowing';

  @override
  String get quickCurrentBorrowsSubtitle => 'Records list';

  @override
  String get quickHistory => 'History';

  @override
  String get quickHistorySubtitle => 'All records';

  @override
  String get addBookTitle => 'Add new book';

  @override
  String get editBookTitle => 'Update book';

  @override
  String get excelImportTitle => 'Import from Excel';

  @override
  String get downloadExcelTemplate =>
      'Download template: 5 books (Vietnamese columns)';

  @override
  String get pickXlsx => 'Choose .xlsx file';

  @override
  String get importInventory => 'Import';

  @override
  String importNBooks(Object count) {
    return 'Import $count books';
  }

  @override
  String get categoryAddTitle => 'Add new category';

  @override
  String get categoryRenameTitle => 'Rename category';

  @override
  String get categoryNameHint => 'Category name';

  @override
  String get categoryNameRequired => 'Please enter category name';

  @override
  String categoryAddedToast(Object name) {
    return 'Added category \"$name\"';
  }

  @override
  String get categoryUpdatedToast => 'Updated';

  @override
  String get categoryDeleteTitle => 'Delete category?';

  @override
  String categoryDeleteBody(Object name) {
    return 'Remove \"$name\" from the catalog list. No books are currently using this category.';
  }

  @override
  String get categoryDeletedToast => 'Category deleted';

  @override
  String get categoryDeleteHasBooksTitle => 'Category still has books';

  @override
  String categoryDeleteHasBooksBody(Object count, Object name) {
    return '$count book(s) use \"$name\". Move them to another category, or delete those books (cannot be undone).';
  }

  @override
  String get categoryDeleteMoveToLabel => 'Move all books to';

  @override
  String get categoryDeleteButtonReassign => 'Move books & delete category';

  @override
  String get categoryDeleteButtonPurgeBooks => 'Delete those books & category';

  @override
  String get categoryDeletePurgeConfirmTitle => 'Delete books?';

  @override
  String categoryDeletePurgeConfirmBody(Object count) {
    return 'This will permanently delete $count book(s). Continue?';
  }

  @override
  String get categoryDeleteToastReassigned => 'Books moved; category deleted';

  @override
  String get categoryDeleteToastPurged => 'Books and category deleted';

  @override
  String categoryDeleteNoMoveTarget(Object name) {
    return 'No target category. Add another category (other than \"$name\") first, or delete all books in this category.';
  }

  @override
  String get returnFindTitle => 'Find the borrow record to return';

  @override
  String get returnFindBody =>
      'Librarians can scan the ticket QR (LIB_RET:…) to return. If the ticket is lost, enter book + student and search.';

  @override
  String get enterBookCode => 'Enter book code (bookId or ISBN)';

  @override
  String get bookIdOrIsbnHint => 'bookId / ISBN';

  @override
  String get studentQueryLabel => 'Student (uid / email or student ID)';

  @override
  String get studentQueryHint => 'uid / Email or student ID';

  @override
  String get findBorrowingRecord => 'FIND ACTIVE BORROW';

  @override
  String get borrowRecordLabel => 'Borrow record';

  @override
  String get borrowRecordNotSelected =>
      'No record selected. Search by book + student.';

  @override
  String returnLoadRecordError(Object message) {
    return 'Failed to load record: $message';
  }

  @override
  String get returnRecentHistory => 'Recent returns';

  @override
  String get returnEnterBookAndStudent =>
      'Please enter book code and student email/ID';

  @override
  String get returnBookNotFound => 'Book not found';

  @override
  String get returnStudentNotFound => 'Student not found';

  @override
  String get returnNoActiveBorrowFound =>
      'No active borrow record found for this book and student';

  @override
  String returnLookupError(Object message) {
    return 'Failed to lookup record: $message';
  }

  @override
  String get returnNeedRelogin => 'Please sign in again';

  @override
  String get returnSuccessToast => 'Return confirmed successfully';

  @override
  String returnConfirmError(Object message) {
    return 'Unable to return: $message';
  }

  @override
  String get returnDeleteRecord => 'Delete record';

  @override
  String get returnConfirmButton => 'Confirm return';

  @override
  String get returnCannotLoadHistory => 'Unable to load return history';

  @override
  String get returnNoRecentReturns => 'No recent returns';

  @override
  String returnBookPrefix(Object bookId) {
    return 'Book: $bookId';
  }

  @override
  String returnDueDateLabel(Object date) {
    return 'Due: $date';
  }

  @override
  String get returnMissingBookName => '(Missing book title)';

  @override
  String returnLateDaysFine(Object days, Object fine) {
    return 'Late $days days • Est. fine: $fine';
  }

  @override
  String returnLateWithFine(Object fine) {
    return 'Late • Fine: $fine';
  }

  @override
  String get returnOnTime => 'On time';

  @override
  String get statusAll => 'All';

  @override
  String get statusBorrowing => 'Borrowing';

  @override
  String get statusReturned => 'Returned';

  @override
  String get statusLate => 'Late';

  @override
  String get loginSubtitleWeb => 'Admin & Manager portal';

  @override
  String get loginSubtitleMobile =>
      'Students & Managers — Admin uses the web browser';

  @override
  String get loginSnackWebStaffOnly =>
      'Only Admin or Manager accounts can sign in on the web. Students, please use the mobile app.';

  @override
  String get loginSnackAdminWebOnly =>
      'Admin accounts can only sign in on the web browser. Managers and students use this app.';

  @override
  String get loginSnackGoogleWebStaffOnly =>
      'Only Admin or Manager accounts can sign in on the web. This Google account is a student — please use the mobile app.';

  @override
  String get loginFailed => 'Sign in failed';

  @override
  String get loginGoogleFailed => 'Google sign-in failed';

  @override
  String get authErrUserNotFound => 'No account found for this email';

  @override
  String get authErrWrongPassword => 'Incorrect password';

  @override
  String get authErrInvalidCredential => 'Incorrect email or password';

  @override
  String get authErrUserDisabled => 'This account has been disabled';

  @override
  String get authErrNetwork =>
      'Network error. Please check your internet connection.';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryOther => 'Other';

  @override
  String get demoCategoryTech => 'Technology';

  @override
  String get demoCategoryEcon => 'Economics';

  @override
  String get demoCategoryLit => 'Literature';

  @override
  String get demoCategorySci => 'Science';

  @override
  String get demoCategoryHist => 'History';

  @override
  String get demoCategoryEdu => 'Education';

  @override
  String get sortOptionTitle => 'Title';

  @override
  String get sortOptionAuthor => 'Author';

  @override
  String get sortOptionCategory => 'Category';

  @override
  String get sortOptionStock => 'Available copies';

  @override
  String get sortOptionDateAdded => 'Date added';

  @override
  String get bookStatTotalBooks => 'Total books';

  @override
  String get bookStatAvailable => 'Available';

  @override
  String get bookStatBorrowed => 'On loan';

  @override
  String get excelImportFormatHint =>
      '.xlsx file — row 1 is the header. Required: book title and author (e.g. title, author). Optional: category (demo group), genre / thể loại (links to genres), genre id, published year, isbn, quantity, description.';

  @override
  String get bookQuantityLabel => 'Quantity';

  @override
  String get bookDescriptionSectionTitle => 'Description';

  @override
  String get bookDescriptionFieldLabel => 'Book description';

  @override
  String get bookDescriptionFieldHint => 'Short description of the book…';

  @override
  String get bookDetailTotalQuantity => 'Total copies';

  @override
  String get bookDetailAvailable => 'Available';

  @override
  String get bookDetailOnLoan => 'On loan';

  @override
  String get bookDetailQrScanHint =>
      'Scan the code to look up the book or create a borrow record';

  @override
  String get bookDetailIsbnTile => 'ISBN';

  @override
  String get bookDetailCategoryTile => 'Category';

  @override
  String get bookDetailAuthorTile => 'Author';

  @override
  String get bookDetailPublishedYearTile => 'Published year';

  @override
  String get bookDetailGenreTile => 'Genre';

  @override
  String get bookDetailBorrowableTile => 'Borrowing';

  @override
  String get bookDetailBorrowableYes => 'Available';

  @override
  String get bookDetailBorrowableNo => 'Unavailable';

  @override
  String get bookDetailTotalBorrowsTile => 'Total borrows';

  @override
  String get bookDetailCreatedAtTile => 'Date added';

  @override
  String get bookDetailUpdatedAtTile => 'Last updated';

  @override
  String get bookDetailValueDash => '—';

  @override
  String get bookDetailMetadataSection => 'Activity & updates';

  @override
  String get bookNoDescription => 'No description for this book yet.';

  @override
  String get bookDetailActionCreateBorrow => 'Create slip';

  @override
  String get bookDetailActionShare => 'Share';

  @override
  String get bookDetailActionPrint => 'Print';

  @override
  String get studentHomeStatUniqueTitles => 'Titles';

  @override
  String get studentHomeStatLibraryStock => 'Library stock';

  @override
  String get studentHomeStatActiveBorrows => 'Borrowing';

  @override
  String get studentHomeStatActiveTickets => 'Active slips';

  @override
  String get studentHomeStatCategories => 'Categories';

  @override
  String get studentHomeStatCategoryKinds => 'Book types';

  @override
  String get studentHomeStatBorrowedToday => 'Borrowed today';

  @override
  String get studentHomeStatWithinToday => 'Today';

  @override
  String timeAgoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String timeAgoHours(int count) {
    return '$count h ago';
  }

  @override
  String timeAgoDays(int count) {
    return '$count days ago';
  }

  @override
  String get currentBorrowsPermissionHint =>
      'Tip: if you see permission-denied, check the user document in Firestore (collection users) has field role set to manager or admin, and that firestore.rules is deployed.';

  @override
  String borrowSheetFine(Object amount) {
    return 'Fine: $amount';
  }

  @override
  String bookTitleFallback(Object id) {
    return 'Book ($id)';
  }

  @override
  String get userNamePlaceholder => '(No name)';

  @override
  String get statsSectionScansOverTime => 'Borrow events over time';

  @override
  String get statsSectionLast7Days => 'Last 7 days';

  @override
  String get statsDateRangeThisWeek => 'This week';

  @override
  String get statsCategoryBreakdownTitle => 'By category';

  @override
  String get statsTopBorrowedTitle => 'Most borrowed books';

  @override
  String statsFolderLabel(Object name) {
    return 'Category: $name';
  }

  @override
  String get statsBorrowCountUnit => 'borrows';

  @override
  String get statsNoChartData => 'No data';

  @override
  String get statsEmptyTopBooks => 'No borrow records yet';

  @override
  String get statsBookFallbackTitle => 'Book';

  @override
  String get statsExportReport => 'EXPORT REPORT';

  @override
  String get statsExportDone => 'Report file download started.';

  @override
  String statsExportError(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get statsPermissionDenied =>
      'You do not have permission to view statistics.';

  @override
  String get statsLoadError =>
      'Could not load statistics data (check Firestore permissions).';

  @override
  String get statsDateRangeHelp =>
      'Choose a date range (applies to borrows & reports)';

  @override
  String get statsDatePickerDone => 'DONE';

  @override
  String get statsDatePickerCancel => 'CANCEL';

  @override
  String get statsExportPickFormat => 'Choose export format';

  @override
  String get statsExportFormatExcel => 'Microsoft Excel (.xlsx)';

  @override
  String get statsExportFormatPdf => 'PDF (.pdf)';

  @override
  String get statsOverviewSection => 'Overview';

  @override
  String get statsOverviewSubtitle =>
      'Some metrics are library-wide; borrows use the selected date range above.';

  @override
  String get statsCardBookTitles => 'Titles';

  @override
  String statsDeltaTotalPrintCopies(Object copies) {
    return '$copies print copies';
  }

  @override
  String get statsCardUsers => 'Users';

  @override
  String get statsDeltaAccounts => 'Accounts';

  @override
  String get statsCardBorrowTurnsPeriod => 'Borrows (period)';

  @override
  String get statsDeltaByBorrowDate => 'By borrowDate';

  @override
  String get statsCardActiveTickets => 'Active loans';

  @override
  String get statsDeltaSystemWide => 'System-wide';

  @override
  String get statsCardInStock => 'In stock';

  @override
  String get statsDeltaTotalAvailable => 'Total available';

  @override
  String get statsCardReturnedLatePeriod => 'Returned / Late (period)';

  @override
  String statsDeltaLateShort(Object count) {
    return 'Late: $count';
  }

  @override
  String get statsBorrowReturnPeriodSection => 'Borrow & return in period';

  @override
  String get statsKvBorrowingTicketsInPeriod =>
      'Currently borrowing (records in period)';

  @override
  String get statsKvReturned => 'Returned';

  @override
  String get statsKvLateRecorded => 'Late (recorded)';

  @override
  String get statsKvOnTimeRate => 'On-time return rate*';

  @override
  String get statsKvAvgBorrowDaysReturned => 'Avg. borrow span (returned)';

  @override
  String statsKvAvgBorrowDaysValue(Object days) {
    return '$days days';
  }

  @override
  String get statsFootnoteOnTimeReturns =>
      '*Among returned records with borrow/due/return dates in the period.';

  @override
  String get statsDailyBorrowsSection => 'Borrows by day (period)';

  @override
  String statsTotalTurns(Object count) {
    return 'Total $count turns';
  }

  @override
  String get statsMonthlyBorrowsSection => 'Borrows by month (last 12 months)';

  @override
  String get statsMonthlyTrendSubtitle => 'Trend comparison by borrowDate';

  @override
  String get statsCategoriesSection => 'Categories';

  @override
  String get statsCategoriesDonutsSubtitle =>
      'Left: title stock — Right: borrows in period';

  @override
  String get statsDonutByInventory => 'By inventory (titles)';

  @override
  String get statsDonutBorrowedInPeriod => 'Borrowed (period)';

  @override
  String get statsTopCategoriesBorrowed => 'Top borrowed categories';

  @override
  String get statsBooksSection => 'Books';

  @override
  String get statsBooksSectionsSubtitle =>
      'Top / least in period — Out of stock — New titles';

  @override
  String get statsTopBorrowedThisPeriod => 'Most borrowed (period)';

  @override
  String get statsLeastBorrowedThisPeriod => 'Least borrowed (period)';

  @override
  String get statsOutOfStockTitle => 'Out of stock (available ≤ 0)';

  @override
  String get statsOutOfStockEmpty => 'No titles are out of stock.';

  @override
  String get statsNewBooksInPeriodTitle => 'New books in period (createdAt)';

  @override
  String get statsNewBooksEmpty => 'No new books in this date range.';

  @override
  String get statsAuthorsByPeriodSection => 'Authors (by period borrows)';

  @override
  String get statsUsersSection => 'Users';

  @override
  String get statsTopUsersPeriod => 'Most borrows in period (top 10)';

  @override
  String get statsBorrowersActiveTickets =>
      'Currently borrowing (active records)';

  @override
  String get statsBorrowersOverdue => 'Overdue-related (late / past due)';

  @override
  String statsMonthCompareTwo(
    Object m1,
    Object c1,
    Object m2,
    Object c2,
    Object arrow,
    Object diff,
  ) {
    return 'Last two months: $m1 ($c1) → $m2 ($c2)  $arrow $diff turns';
  }

  @override
  String statsBookStockSubtitle(Object avail, Object qty, Object authorSuffix) {
    return '$avail / $qty left$authorSuffix';
  }

  @override
  String statsUserBorrowCount(Object count) {
    return '$count borrows';
  }

  @override
  String get statsBorrowersNone => 'None';

  @override
  String statsBorrowerOverdueCount(Object count) {
    return 'Late $count';
  }

  @override
  String statsBorrowerActiveCount(Object count) {
    return 'Tickets $count';
  }

  @override
  String get exportStatReportTitleFull => 'Library statistics report (full)';

  @override
  String get exportStatReportTitlePdf => 'Library statistics report';

  @override
  String exportStatDateRange(Object range) {
    return 'Date range: $range';
  }

  @override
  String exportStatExportedAt(Object dateTime) {
    return 'Exported at: $dateTime';
  }

  @override
  String get exportStatMetric => 'Metric';

  @override
  String get exportStatValue => 'Value';

  @override
  String get exportStatBookTitlesCount => 'Distinct titles';

  @override
  String get exportStatTotalUsers => 'Total users';

  @override
  String get exportStatTotalCopiesQty => 'Total copies (quantity)';

  @override
  String get exportStatTotalAvailableStock => 'Total in stock (available)';

  @override
  String get exportStatBorrowsInPeriodBorrowDate =>
      'Borrows in period (borrowDate)';

  @override
  String get exportStatActiveTicketsSystemWide =>
      'Active borrow records (system-wide)';

  @override
  String get exportStatPeriodBorrowingReturnedLate =>
      'In period — borrowing / returned / late';

  @override
  String get exportStatOnTimeReturnEstimate => 'On-time return rate (estimate)';

  @override
  String get exportStatAvgBorrowDaysReturned => 'Avg. borrow days (returned)';

  @override
  String get exportStatSectionTopBorrowedPeriod => 'Most borrowed (period)';

  @override
  String get exportColRank => 'Rank';

  @override
  String get exportColBookTitle => 'Book title';

  @override
  String get exportColCategory => 'Category';

  @override
  String get exportColBorrowsShort => 'Count';

  @override
  String get exportColBorrowCountLong => 'Borrows';

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
  String get exportExcelColDisplayName => 'Name';

  @override
  String get exportExcelColBorrowsInPeriod => 'Borrows (period)';

  @override
  String get exportExcelColAuthorName => 'Author';

  @override
  String get exportExcelColAuthorBorrowsInPeriod => 'Borrows in period';

  @override
  String get exportExcelEncodeError => 'Could not create the Excel file.';

  @override
  String get exportPdfTopBooksInRange => 'Top borrowed books (in range)';

  @override
  String get exportPdfNoTableData => 'No data.';

  @override
  String exportPdfBorrowRecordsLimited(Object cap, Object total) {
    return 'Borrow records (showing $cap of $total)';
  }

  @override
  String get exportPdfNoBorrowRecordsInRange =>
      'No borrow records in this range.';

  @override
  String get exportPdfColTicketId => 'Record ID';

  @override
  String get exportPdfColBookId => 'bookId';

  @override
  String get exportPdfColUserId => 'userId';

  @override
  String get exportPdfColStatus => 'Status';

  @override
  String get exportPdfColBorrowDate => 'Borrow date';

  @override
  String get exportPdfColDueDate => 'Due date';

  @override
  String get exportPdfPeriodBorrowReturnLate =>
      'Period: borrowing / returned / late';

  @override
  String get manageAuthors => 'Authors';

  @override
  String get manageGenres => 'Genres';

  @override
  String get manageStationery => 'Stationery';

  @override
  String get manageLibraryConfig => 'Loan rules & limits';

  @override
  String get manageAuditLog => 'Activity log';

  @override
  String get webAdminSettingsSection => 'Administration';

  @override
  String get libraryBusinessSettingsTitle => 'Library business settings';

  @override
  String get libraryBusinessSettingsSubtitle =>
      'Default loan period hint and maximum concurrent borrows per user.';

  @override
  String get libraryConfigLoanDaysLabel =>
      'Suggested loan days (for new borrows)';

  @override
  String libraryConfigLoanDaysHelper(Object min, Object max) {
    return 'Recommended range: $min–$max days (used as default due date).';
  }

  @override
  String get libraryConfigMaxBorrowsLabel => 'Max concurrent borrows per user';

  @override
  String get libraryConfigMaxBorrowsHelper =>
      'A user cannot borrow another book if they already have this many active loans.';

  @override
  String get libraryConfigSave => 'Save configuration';

  @override
  String get libraryConfigSaved => 'Settings saved.';

  @override
  String libraryConfigSaveError(Object error) {
    return 'Could not save: $error';
  }

  @override
  String get libraryConfigLoanDaysInvalid =>
      'Loan days must be within the suggested range.';

  @override
  String get libraryConfigMaxBorrowsInvalid =>
      'Max concurrent borrows must be between 1 and 99.';

  @override
  String get adminOnlyLibraryConfig =>
      'Only administrators can change these settings.';

  @override
  String get auditLogTitle => 'Activity log';

  @override
  String get auditLogEmpty => 'No log entries yet.';

  @override
  String get auditLogAdminOnly =>
      'Only administrators can view the activity log.';

  @override
  String auditLogLoadError(Object error) {
    return 'Could not load log: $error';
  }

  @override
  String get authorsManageTitle => 'Authors';

  @override
  String get staffOnlyAuthorManage => 'Only staff can manage authors.';

  @override
  String authorsLoadError(Object error) {
    return 'Could not load authors: $error';
  }

  @override
  String get authorsEmpty => 'No authors yet.';

  @override
  String get authorsAddFirst => 'Add first author';

  @override
  String get authorsAdd => 'Add author';

  @override
  String get authorsAddTitle => 'New author';

  @override
  String get authorsEditTitle => 'Edit author';

  @override
  String get authorsNameLabel => 'Name';

  @override
  String get authorsDescLabel => 'Bio (optional)';

  @override
  String get authorsNameRequired => 'Please enter a name.';

  @override
  String authorsAdded(Object name) {
    return 'Author added: $name';
  }

  @override
  String get authorsUpdated => 'Author updated.';

  @override
  String get authorsUntitled => '(Untitled)';

  @override
  String get authorsDeleteTitle => 'Delete author?';

  @override
  String authorsDeleteBody(Object name) {
    return 'Delete “$name”? Books referencing this name are not deleted.';
  }

  @override
  String get authorsDeleted => 'Author removed.';

  @override
  String authorsDeleteError(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String get genresManageTitle => 'Genres';

  @override
  String get staffOnlyGenreManage => 'Only staff can manage genres.';

  @override
  String genresLoadError(Object error) {
    return 'Could not load genres: $error';
  }

  @override
  String get genresEmpty => 'No genres yet.';

  @override
  String get genresAddFirst => 'Add first genre';

  @override
  String get genresAdd => 'Add genre';

  @override
  String get genresAddTitle => 'New genre';

  @override
  String get genresEditTitle => 'Rename genre';

  @override
  String get genresNameHint => 'Genre name';

  @override
  String get genresNameRequired => 'Please enter a name.';

  @override
  String genresAdded(Object name) {
    return 'Genre added: $name';
  }

  @override
  String get genresUpdated => 'Genre updated.';

  @override
  String get genresUntitled => '(Untitled)';

  @override
  String get genresDeleteTitle => 'Delete genre?';

  @override
  String genresDeleteBody(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String get genresDeleted => 'Genre removed.';

  @override
  String genresDeleteError(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String get stationeryManageTitle => 'Stationery';

  @override
  String get staffOnlyStationeryManage => 'Only staff can manage stationery.';

  @override
  String stationeryLoadError(Object error) {
    return 'Could not load items: $error';
  }

  @override
  String get stationeryEmpty => 'No stationery items yet.';

  @override
  String get stationeryAddFirst => 'Add first item';

  @override
  String get stationeryAdd => 'Add item';

  @override
  String get stationeryAddTitle => 'New item';

  @override
  String get stationeryEditTitle => 'Edit item';

  @override
  String get stationeryNameLabel => 'Name';

  @override
  String get stationeryQuantityLabel => 'Quantity';

  @override
  String get stationeryUnitLabel => 'Unit (e.g. box, pack)';

  @override
  String get stationeryNameRequired => 'Please enter a name.';

  @override
  String stationeryQtyLine(Object qty, Object unit) {
    return '$qty $unit';
  }

  @override
  String get stationeryAdded => 'Item saved.';

  @override
  String get stationeryUpdated => 'Item updated.';

  @override
  String get stationeryUntitled => '(Untitled)';

  @override
  String get stationeryDeleteTitle => 'Delete item?';

  @override
  String stationeryDeleteBody(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String get stationeryDeleted => 'Item removed.';

  @override
  String stationeryDeleteError(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String get userManageStaffHintBody =>
      'New accounts register in the mobile app. To grant Admin or Manager access: find the user here and change their role. Creating Firebase Auth users for staff must be done in Firebase Console or via backend if needed.';

  @override
  String get userManageChangeRole => 'Change role';

  @override
  String get userManagePickRole => 'Assign role';

  @override
  String get userManageRoleChanged => 'Role updated.';

  @override
  String userManageRoleError(Object error) {
    return 'Could not update role: $error';
  }

  @override
  String get userManageCannotRemoveLastAdmin =>
      'There must be at least one administrator.';

  @override
  String get userManageCannotLockSelf =>
      'You cannot deactivate your own account here.';

  @override
  String get borrowSameBookAlready =>
      'This user already has an active loan for this book.';

  @override
  String borrowMaxActiveReached(Object max) {
    return 'This user already has the maximum concurrent borrows ($max).';
  }

  @override
  String get brErrMaxActiveBorrows =>
      'You have reached the maximum number of concurrent borrows.';

  @override
  String get scanBookUntitled => '(Untitled book)';

  @override
  String scanBookRemaining(Object avail, Object qty) {
    return 'Remaining: $avail/$qty';
  }

  @override
  String get webDeskUntitledBook => '(No title)';

  @override
  String webDeskRemainingIsbn(Object avail, Object qty, Object isbn) {
    return 'Remaining $avail / $qty • ISBN: $isbn';
  }

  @override
  String get userFilterAll => 'All';

  @override
  String get userFilterAdmin => 'Admin';

  @override
  String get userFilterManager => 'Manager';

  @override
  String get userFilterStudent => 'Student';

  @override
  String get brErrBookNotFound => 'Book not found';

  @override
  String get brErrInvalidBookData => 'Invalid book data';

  @override
  String get brErrOutOfStock => 'No copies available';

  @override
  String get brErrAlreadyBorrowing => 'You are already borrowing this book';

  @override
  String get brErrNoActiveBorrow => 'No active borrow record found';

  @override
  String get notifBorrowSuccessTitle => 'Borrow successful';

  @override
  String notifBorrowSuccessBody(Object title, Object due) {
    return '$title — due $due';
  }

  @override
  String get notifReturnLateTitle => 'Returned late';

  @override
  String get notifReturnOnTimeTitle => 'Returned';

  @override
  String notifReturnLateBody(Object title, Object days) {
    return '$title — $days days late';
  }

  @override
  String notifReturnOnTimeBody(Object title) {
    return '$title — thank you for returning on time';
  }

  @override
  String notifReturnDeskBody(Object title) {
    return '$title — return confirmed by staff';
  }

  @override
  String get forgotPasswordIntro =>
      'Enter the email you used to register. If it exists in the system, we will send a password reset link.';

  @override
  String notifLoadFailed(Object error) {
    return 'Could not load notifications.\nIf you just deployed, create the composite index (userId + createdAt) from the link in the Firebase console.\n\n$error';
  }

  @override
  String get notifEmptyStaff =>
      'No notifications in the system yet.\nNotifications are created when books are borrowed or returned.';

  @override
  String get notifEmptyStudent =>
      'You have no notifications yet.\nMessages appear when you borrow or return books.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String categoryLoadFailed(Object error) {
    return 'Could not load categories: $error';
  }

  @override
  String get categoryUntitled => '(Untitled)';

  @override
  String get categoryUsedWhenAddingBooks =>
      'Used when adding books (category field).';

  @override
  String get categoryPermissionDeniedHint =>
      'No write permission. In Firebase, open Firestore → users → your account and set field role to admin or manager (not only changing the role in this demo app).';

  @override
  String categoryErrorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get webStaffAccountFallback => 'Account';

  @override
  String get myQrDefaultDisplayName => 'Student';

  @override
  String get qrCreateEmptyPayload => 'No content yet';

  @override
  String get qrCreateCatalogDefaultTitle => 'Library catalog';

  @override
  String get fineDemoTotalAmount => '50,000 ₫';

  @override
  String get fineDemoTotalExplanation => '5 days late × 10,000 ₫/day';

  @override
  String get fineDemoLineAmount => '20,000 ₫';

  @override
  String get fineDemoLineLateLabel => '2 days late';

  @override
  String get excelErrNoSheetRows =>
      'The file has no sheet containing data rows.';

  @override
  String get excelErrSheetEmpty => 'Empty sheet.';

  @override
  String excelErrReadFailed(Object primary, Object fallback) {
    return 'Could not read .xlsx file.\n• Primary reader: $primary\n• Fallback reader: $fallback\nHint: open in Microsoft Excel → File → Save As → Excel Workbook (.xlsx).';
  }

  @override
  String excelErrReadFailedShort(Object error) {
    return 'Could not read .xlsx file: $error. Try saving again as Excel (.xlsx) or re-export from Google Sheets.';
  }

  @override
  String get excelErrHeaderRow =>
      'Row 1 must include recognizable columns for book title (title / tieu de) and author (author / tac gia).';

  @override
  String excelErrRowMissingTitle(Object row) {
    return 'Row $row: missing book title';
  }

  @override
  String excelErrRowMissingAuthor(Object row) {
    return 'Row $row: missing author';
  }

  @override
  String excelErrRowInvalidQuantity(Object row) {
    return 'Row $row: invalid quantity (minimum 1)';
  }

  @override
  String get excelErrNoValidRows => 'No valid data rows (empty rows ignored).';

  @override
  String excelErrEnsureCategory(Object error) {
    return 'Could not prepare categories or link genres/authors: $error';
  }

  @override
  String get excelSampleSheetName => 'BookImport';

  @override
  String get excelSampleColTitle => 'Title';

  @override
  String get excelSampleColAuthor => 'Author';

  @override
  String get excelSampleColCategory => 'Category';

  @override
  String get excelSampleColGenre => 'Genre';

  @override
  String get excelSampleColPublishedYear => 'Published year';

  @override
  String get excelSampleColIsbn => 'ISBN';

  @override
  String get excelSampleColQuantity => 'Quantity';

  @override
  String get excelSampleColDescription => 'Description';

  @override
  String get excelTemplateFileName => 'book_import_sample_5rows.xlsx';

  @override
  String get pushChannelName => 'Library';

  @override
  String get pushChannelDescription => 'Borrow, return and due date alerts';

  @override
  String get pushDefaultTitle => 'Library';

  @override
  String get pushFallbackTitle => 'Notification';

  @override
  String get errorWidgetDebugTitle => 'Widget build error (debug)';

  @override
  String get errorWidgetReleaseTitle => 'Something went wrong';

  @override
  String get errorWidgetDebugDetailHint =>
      'Details match the console — you can select and copy.';

  @override
  String get errorWidgetReleaseHint =>
      'Please try again or contact an administrator.';

  @override
  String get errorNoStack => '(no stack trace)';
}

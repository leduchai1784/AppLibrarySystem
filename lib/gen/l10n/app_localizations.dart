import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Library'**
  String get appTitle;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get commonSignIn;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabBorrowing.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get tabBorrowing;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get tabScan;

  /// No description provided for @tabManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get tabManage;

  /// No description provided for @tabBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get tabBooks;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguageAppearance.
  ///
  /// In en, this message translates to:
  /// **'Language & appearance'**
  String get settingsLanguageAppearance;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @defaultQrColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Default QR color'**
  String get defaultQrColorTitle;

  /// No description provided for @defaultQrSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Default QR size'**
  String get defaultQrSizeTitle;

  /// No description provided for @qrSizeSmall200.
  ///
  /// In en, this message translates to:
  /// **'Small (200px)'**
  String get qrSizeSmall200;

  /// No description provided for @qrSizeMedium256.
  ///
  /// In en, this message translates to:
  /// **'Medium (256px)'**
  String get qrSizeMedium256;

  /// No description provided for @qrSizeLarge300.
  ///
  /// In en, this message translates to:
  /// **'Large (300px)'**
  String get qrSizeLarge300;

  /// No description provided for @settingsAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsAppPreferences;

  /// No description provided for @settingsDefaultQrStyle.
  ///
  /// In en, this message translates to:
  /// **'Default QR style'**
  String get settingsDefaultQrStyle;

  /// No description provided for @settingsDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Default color'**
  String get settingsDefaultColor;

  /// No description provided for @settingsDefaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default size'**
  String get settingsDefaultSize;

  /// No description provided for @settingsCameraScanning.
  ///
  /// In en, this message translates to:
  /// **'Camera & scanning'**
  String get settingsCameraScanning;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsBiometricsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported on this device'**
  String get settingsBiometricsUnsupported;

  /// No description provided for @settingsBiometricsHint.
  ///
  /// In en, this message translates to:
  /// **'Try fingerprint / Face ID when unlocking.'**
  String get settingsBiometricsHint;

  /// No description provided for @settingsAppLockHint.
  ///
  /// In en, this message translates to:
  /// **'Requires authentication when returning from background.'**
  String get settingsAppLockHint;

  /// No description provided for @settingsAutofocusHint.
  ///
  /// In en, this message translates to:
  /// **'Hint for the camera (device-dependent).'**
  String get settingsAutofocusHint;

  /// No description provided for @settingsBorrowReturnNotifsHint.
  ///
  /// In en, this message translates to:
  /// **'Notifications when you borrow/return (saved on your account).'**
  String get settingsBorrowReturnNotifsHint;

  /// No description provided for @settingsPushNotifsHint.
  ///
  /// In en, this message translates to:
  /// **'Show alerts when new library notifications arrive.'**
  String get settingsPushNotifsHint;

  /// No description provided for @settingsLibraryData.
  ///
  /// In en, this message translates to:
  /// **'Library data'**
  String get settingsLibraryData;

  /// No description provided for @settingsBackupLibraryJson.
  ///
  /// In en, this message translates to:
  /// **'Backup library JSON'**
  String get settingsBackupLibraryJson;

  /// No description provided for @settingsBackupMyBorrows.
  ///
  /// In en, this message translates to:
  /// **'Backup my borrows (JSON)'**
  String get settingsBackupMyBorrows;

  /// No description provided for @settingsSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOutAction;

  /// No description provided for @systemFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature settings'**
  String get systemFeaturesTitle;

  /// No description provided for @systemFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn features on/off. Changes apply in real time.'**
  String get systemFeaturesSubtitle;

  /// No description provided for @systemFeaturesSaved.
  ///
  /// In en, this message translates to:
  /// **'Feature settings saved.'**
  String get systemFeaturesSaved;

  /// No description provided for @systemFeaturesCoreSection.
  ///
  /// In en, this message translates to:
  /// **'Core features'**
  String get systemFeaturesCoreSection;

  /// No description provided for @systemFeaturesAiSection.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get systemFeaturesAiSection;

  /// No description provided for @systemFeaturesReportsSection.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get systemFeaturesReportsSection;

  /// No description provided for @systemFeaturesScan.
  ///
  /// In en, this message translates to:
  /// **'QR scanning'**
  String get systemFeaturesScan;

  /// No description provided for @systemFeaturesScanHint.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable the Scan tab (QR/ISBN).'**
  String get systemFeaturesScanHint;

  /// No description provided for @systemFeaturesBorrowReturn.
  ///
  /// In en, this message translates to:
  /// **'Borrow/Return'**
  String get systemFeaturesBorrowReturn;

  /// No description provided for @systemFeaturesBorrowReturnHint.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable borrowing & returning flow.'**
  String get systemFeaturesBorrowReturnHint;

  /// No description provided for @systemFeaturesAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Book suggestions'**
  String get systemFeaturesAiRecommendations;

  /// No description provided for @systemFeaturesAiRecommendationsHint.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable AI suggestions section on Home.'**
  String get systemFeaturesAiRecommendationsHint;

  /// No description provided for @systemFeaturesStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get systemFeaturesStatistics;

  /// No description provided for @systemFeaturesStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable Statistics/Reports screen.'**
  String get systemFeaturesStatisticsHint;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsInAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'In-app notifications'**
  String get settingsInAppNotifications;

  /// No description provided for @settingsQrDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Default QR color'**
  String get settingsQrDefaultColor;

  /// No description provided for @settingsQrDefaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default QR size'**
  String get settingsQrDefaultSize;

  /// No description provided for @settingsScannerAutofocus.
  ///
  /// In en, this message translates to:
  /// **'Autofocus'**
  String get settingsScannerAutofocus;

  /// No description provided for @settingsScannerBeep.
  ///
  /// In en, this message translates to:
  /// **'Beep on scan'**
  String get settingsScannerBeep;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsPreferBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Prefer biometrics'**
  String get settingsPreferBiometrics;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsClearLocalData.
  ///
  /// In en, this message translates to:
  /// **'Clear local data & sign out'**
  String get settingsClearLocalData;

  /// No description provided for @clearLocalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear local app data?'**
  String get clearLocalDataTitle;

  /// No description provided for @clearLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'Removes on-device settings and signs you out. Cloud data is not deleted.'**
  String get clearLocalDataBody;

  /// No description provided for @clearLocalDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear & sign out'**
  String get clearLocalDataConfirm;

  /// No description provided for @webSystemSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get webSystemSettingsTitle;

  /// No description provided for @webSystemSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browser preferences. QR, camera and app lock are configured in the mobile app.'**
  String get webSystemSettingsSubtitle;

  /// No description provided for @settingsProviderMissingBody.
  ///
  /// In en, this message translates to:
  /// **'AppSettingsController provider not found. Check main.dart has ChangeNotifierProvider<AppSettingsController> and restart the app (not just hot reload).'**
  String get settingsProviderMissingBody;

  /// No description provided for @settingsJsonDownloaded.
  ///
  /// In en, this message translates to:
  /// **'JSON file downloaded.'**
  String get settingsJsonDownloaded;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {message}'**
  String settingsExportFailed(Object message);

  /// No description provided for @settingsBorrowReturnNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow & return notifications'**
  String get settingsBorrowReturnNotificationsTitle;

  /// No description provided for @settingsBorrowReturnNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Saved on your account. When off, in-app notifications for borrow/return are not created.'**
  String get settingsBorrowReturnNotificationsBody;

  /// No description provided for @settingsExportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Export JSON (books, categories, records)'**
  String get settingsExportJsonTitle;

  /// No description provided for @settingsMobileConfigHint.
  ///
  /// In en, this message translates to:
  /// **'On mobile: default QR style, scanner, app lock and biometrics.'**
  String get settingsMobileConfigHint;

  /// No description provided for @webDebugPanelHeader.
  ///
  /// In en, this message translates to:
  /// **'── Debug info (screenshot to dev) ──'**
  String get webDebugPanelHeader;

  /// No description provided for @webDebugPanelProviderYes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get webDebugPanelProviderYes;

  /// No description provided for @webDebugPanelProviderNo.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get webDebugPanelProviderNo;

  /// No description provided for @webDebugPanelRoleMismatchHint.
  ///
  /// In en, this message translates to:
  /// **'If role is student but Firestore is admin → click the button below then refresh the page.'**
  String get webDebugPanelRoleMismatchHint;

  /// No description provided for @myQrTitle.
  ///
  /// In en, this message translates to:
  /// **'My QR'**
  String get myQrTitle;

  /// No description provided for @myQrHint.
  ///
  /// In en, this message translates to:
  /// **'Show this code to the librarian when creating a borrow record.'**
  String get myQrHint;

  /// No description provided for @notSignedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedInTitle;

  /// No description provided for @profileButton.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileButton;

  /// No description provided for @myQrButton.
  ///
  /// In en, this message translates to:
  /// **'My QR'**
  String get myQrButton;

  /// No description provided for @studentCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {code}'**
  String studentCodeLabel(Object code);

  /// No description provided for @quickTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick tasks'**
  String get quickTasksTitle;

  /// No description provided for @quickLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get quickLibrary;

  /// No description provided for @quickHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get quickHistoryTab;

  /// No description provided for @recentBorrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent borrows'**
  String get recentBorrowsTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @cannotLoadRecentData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load recent data'**
  String get cannotLoadRecentData;

  /// No description provided for @noRecentBorrows.
  ///
  /// In en, this message translates to:
  /// **'No recent borrows yet'**
  String get noRecentBorrows;

  /// No description provided for @needSignInToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see statistics'**
  String get needSignInToSeeStats;

  /// No description provided for @needSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get needSignIn;

  /// No description provided for @signInToConfigure.
  ///
  /// In en, this message translates to:
  /// **'Sign in to configure'**
  String get signInToConfigure;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @reloadRoleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reloaded role from Firestore. If sidebar is still incorrect, refresh the page.'**
  String get reloadRoleSuccess;

  /// No description provided for @reloadRoleButton.
  ///
  /// In en, this message translates to:
  /// **'Reload role from Firestore'**
  String get reloadRoleButton;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @adminSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search books, users...'**
  String get adminSearchHint;

  /// No description provided for @adminQuickTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick tasks'**
  String get adminQuickTasksTitle;

  /// No description provided for @adminQuickAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get adminQuickAddBook;

  /// No description provided for @adminQuickBookList.
  ///
  /// In en, this message translates to:
  /// **'Book list'**
  String get adminQuickBookList;

  /// No description provided for @adminQuickCreateBorrow.
  ///
  /// In en, this message translates to:
  /// **'Create borrow record'**
  String get adminQuickCreateBorrow;

  /// No description provided for @adminQuickReturn.
  ///
  /// In en, this message translates to:
  /// **'Return book'**
  String get adminQuickReturn;

  /// No description provided for @adminQuickManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get adminQuickManageCategories;

  /// No description provided for @adminQuickManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get adminQuickManageUsers;

  /// No description provided for @adminQuickStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get adminQuickStats;

  /// No description provided for @adminQuickFinePayment.
  ///
  /// In en, this message translates to:
  /// **'Fine payment'**
  String get adminQuickFinePayment;

  /// No description provided for @adminStatBookTitles.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get adminStatBookTitles;

  /// No description provided for @adminStatUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminStatUsers;

  /// No description provided for @adminStatTotalBorrows.
  ///
  /// In en, this message translates to:
  /// **'Borrow records'**
  String get adminStatTotalBorrows;

  /// No description provided for @adminStatActiveBorrow.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get adminStatActiveBorrow;

  /// No description provided for @qrScannerFlashTooltip.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get qrScannerFlashTooltip;

  /// No description provided for @qrScannerSwitchCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get qrScannerSwitchCameraTooltip;

  /// No description provided for @qrScannerDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code inside the frame to scan'**
  String get qrScannerDefaultHint;

  /// No description provided for @appLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get appLockedTitle;

  /// No description provided for @appLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue.'**
  String get appLockedBody;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @biometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support authentication.'**
  String get biometricNotSupported;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock the library app'**
  String get biometricReason;

  /// No description provided for @borrowTicketStaffOnlyReturn.
  ///
  /// In en, this message translates to:
  /// **'Borrow ticket QR is only used for returning at the desk (staff accounts).'**
  String get borrowTicketStaffOnlyReturn;

  /// No description provided for @studentQrUsedForStaffCreateBorrow.
  ///
  /// In en, this message translates to:
  /// **'This student QR is used when librarians create a borrow record.'**
  String get studentQrUsedForStaffCreateBorrow;

  /// No description provided for @isbnLabel.
  ///
  /// In en, this message translates to:
  /// **'ISBN: {isbn} | Available: {available}/{quantity}'**
  String isbnLabel(Object isbn, Object available, Object quantity);

  /// No description provided for @cannotUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Unable to update status: {message}'**
  String cannotUpdateStatus(Object message);

  /// No description provided for @roleLabelAdminShort.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleLabelAdminShort;

  /// No description provided for @roleLabelManagerShort.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleLabelManagerShort;

  /// No description provided for @roleLabelStudentShort.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleLabelStudentShort;

  /// No description provided for @lateFineLabel.
  ///
  /// In en, this message translates to:
  /// **'Fine: {amount}'**
  String lateFineLabel(Object amount);

  /// No description provided for @ticketIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket id'**
  String get ticketIdLabel;

  /// No description provided for @borrowDateLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Borrow date'**
  String get borrowDateLabelShort;

  /// No description provided for @dueDateLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabelShort;

  /// No description provided for @librarianLabel.
  ///
  /// In en, this message translates to:
  /// **'Librarian'**
  String get librarianLabel;

  /// No description provided for @bookIdDebugLabel.
  ///
  /// In en, this message translates to:
  /// **'bookId: {id}'**
  String bookIdDebugLabel(Object id);

  /// No description provided for @remainingTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'remaining/total'**
  String get remainingTotalLabel;

  /// No description provided for @lockedShort.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedShort;

  /// No description provided for @bookDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Book details'**
  String get bookDetailsAction;

  /// No description provided for @outOfStockCannotBorrow.
  ///
  /// In en, this message translates to:
  /// **'Book is out of stock. Cannot create borrow record.'**
  String get outOfStockCannotBorrow;

  /// No description provided for @createBorrowRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Create borrow record'**
  String get createBorrowRecordAction;

  /// No description provided for @scanBorrowBookAction.
  ///
  /// In en, this message translates to:
  /// **'BORROW BOOK'**
  String get scanBorrowBookAction;

  /// No description provided for @scanReturnBookAction.
  ///
  /// In en, this message translates to:
  /// **'RETURN BOOK'**
  String get scanReturnBookAction;

  /// No description provided for @scanAdminCreateBorrowAction.
  ///
  /// In en, this message translates to:
  /// **'CREATE BORROW (ADMIN)'**
  String get scanAdminCreateBorrowAction;

  /// No description provided for @scanAdminReturnBookAction.
  ///
  /// In en, this message translates to:
  /// **'RETURN BOOK (ADMIN)'**
  String get scanAdminReturnBookAction;

  /// No description provided for @statsWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get statsWeekdayMon;

  /// No description provided for @statsWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get statsWeekdayTue;

  /// No description provided for @statsWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get statsWeekdayWed;

  /// No description provided for @statsWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get statsWeekdayThu;

  /// No description provided for @statsWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get statsWeekdayFri;

  /// No description provided for @statsWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get statsWeekdaySat;

  /// No description provided for @statsWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get statsWeekdaySun;

  /// No description provided for @viewFullList.
  ///
  /// In en, this message translates to:
  /// **'View full list'**
  String get viewFullList;

  /// No description provided for @excelSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String excelSelectedFile(Object name);

  /// No description provided for @excelNotesErrors.
  ///
  /// In en, this message translates to:
  /// **'Notes / row errors:'**
  String get excelNotesErrors;

  /// No description provided for @excelAndMoreLines.
  ///
  /// In en, this message translates to:
  /// **'... and {count} more lines'**
  String excelAndMoreLines(Object count);

  /// No description provided for @orEnterSingleBook.
  ///
  /// In en, this message translates to:
  /// **'Or enter a single book'**
  String get orEnterSingleBook;

  /// No description provided for @bookBasicInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get bookBasicInfoSection;

  /// No description provided for @bookInventorySection.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get bookInventorySection;

  /// No description provided for @submitUpdateBook.
  ///
  /// In en, this message translates to:
  /// **'UPDATE BOOK'**
  String get submitUpdateBook;

  /// No description provided for @submitAddBook.
  ///
  /// In en, this message translates to:
  /// **'ADD BOOK'**
  String get submitAddBook;

  /// No description provided for @bookTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Book title'**
  String get bookTitleLabel;

  /// No description provided for @bookTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter book title'**
  String get bookTitleHint;

  /// No description provided for @bookAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get bookAuthorLabel;

  /// No description provided for @bookAuthorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter author name'**
  String get bookAuthorHint;

  /// No description provided for @bookAuthorPickHint.
  ///
  /// In en, this message translates to:
  /// **'Pick from the author catalog, or choose manual entry and type below.'**
  String get bookAuthorPickHint;

  /// No description provided for @bookAuthorManualOption.
  ///
  /// In en, this message translates to:
  /// **'— Manual entry —'**
  String get bookAuthorManualOption;

  /// No description provided for @bookGenreLabel.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get bookGenreLabel;

  /// No description provided for @bookGenreNone.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get bookGenreNone;

  /// No description provided for @bookCoverSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get bookCoverSectionTitle;

  /// No description provided for @bookCoverPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get bookCoverPickGallery;

  /// No description provided for @bookCoverRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get bookCoverRemove;

  /// No description provided for @bookCoverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL (https)'**
  String get bookCoverUrlLabel;

  /// No description provided for @bookCoverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — paste a direct image link, or pick a photo below (saved in Firestore, no Storage).'**
  String get bookCoverUrlHint;

  /// No description provided for @bookCoverImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image file is still too large. Try another photo or use an HTTPS link.'**
  String get bookCoverImageTooLarge;

  /// No description provided for @bookCoverDataUrlTooLong.
  ///
  /// In en, this message translates to:
  /// **'Encoded image exceeds Firestore limit. Use a smaller photo or an HTTPS link.'**
  String get bookCoverDataUrlTooLong;

  /// No description provided for @bookCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bookCategoryLabel;

  /// No description provided for @bookIsbnLabel.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get bookIsbnLabel;

  /// No description provided for @bookIsbnHint.
  ///
  /// In en, this message translates to:
  /// **'978-xxx-xxx-xxx'**
  String get bookIsbnHint;

  /// No description provided for @fieldRequiredWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter {label}'**
  String fieldRequiredWithLabel(Object label);

  /// No description provided for @saveBookSuccessUpdate.
  ///
  /// In en, this message translates to:
  /// **'Book updated successfully'**
  String get saveBookSuccessUpdate;

  /// No description provided for @saveBookSuccessAdd.
  ///
  /// In en, this message translates to:
  /// **'Book added successfully'**
  String get saveBookSuccessAdd;

  /// No description provided for @saveBookError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save book: {message}'**
  String saveBookError(Object message);

  /// No description provided for @cannotCreateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Cannot generate template file.'**
  String get cannotCreateTemplate;

  /// No description provided for @shareFileError.
  ///
  /// In en, this message translates to:
  /// **'Cannot share/save file: {message}'**
  String shareFileError(Object message);

  /// No description provided for @excelTemplateSubject.
  ///
  /// In en, this message translates to:
  /// **'Sample import template (5 books)'**
  String get excelTemplateSubject;

  /// No description provided for @excelTemplateBody.
  ///
  /// In en, this message translates to:
  /// **'Edit the sample Excel, then use the \"Choose .xlsx\" button above.'**
  String get excelTemplateBody;

  /// No description provided for @cannotReadFileContent.
  ///
  /// In en, this message translates to:
  /// **'Cannot read file content. Try saving again as .xlsx or using a smaller file.'**
  String get cannotReadFileContent;

  /// No description provided for @excelPickReadError.
  ///
  /// In en, this message translates to:
  /// **'File pick/read error: {message}'**
  String excelPickReadError(Object message);

  /// No description provided for @firestoreWriteError.
  ///
  /// In en, this message translates to:
  /// **'Firestore write error: {message}'**
  String firestoreWriteError(Object message);

  /// No description provided for @importedNBooksFromExcel.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} books from Excel'**
  String importedNBooksFromExcel(Object count);

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteBookBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book? This action cannot be undone.'**
  String get confirmDeleteBookBody;

  /// No description provided for @bookDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Book deleted'**
  String get bookDeletedToast;

  /// No description provided for @deleteBookError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete book: {message}'**
  String deleteBookError(Object message);

  /// No description provided for @genericErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String genericErrorWithMessage(Object message);

  /// No description provided for @bookAuthorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Author: {author}'**
  String bookAuthorPrefix(Object author);

  /// No description provided for @bookQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Book QR'**
  String get bookQrTitle;

  /// No description provided for @bookInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get bookInfoSection;

  /// No description provided for @bookDescriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get bookDescriptionSection;

  /// No description provided for @bookMissingIdCannotBorrow.
  ///
  /// In en, this message translates to:
  /// **'No book id available to create borrow record'**
  String get bookMissingIdCannotBorrow;

  /// No description provided for @bookIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Book id: {id}'**
  String bookIdLabel(Object id);

  /// No description provided for @printNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Print is not supported yet'**
  String get printNotSupported;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort: {sortBy}'**
  String sortByLabel(Object sortBy);

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @borrowRecordDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow record details'**
  String get borrowRecordDetailsTitle;

  /// No description provided for @bookLabel.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookLabel;

  /// No description provided for @missingBookId.
  ///
  /// In en, this message translates to:
  /// **'(Missing book id)'**
  String get missingBookId;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @studentAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Library System - Student'**
  String get studentAppTitle;

  /// No description provided for @borrowedBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowed books'**
  String get borrowedBooksTitle;

  /// No description provided for @borrowHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow history'**
  String get borrowHistoryTitle;

  /// No description provided for @adminUseWebTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin uses the web portal'**
  String get adminUseWebTitle;

  /// No description provided for @adminUseWebBody.
  ///
  /// In en, this message translates to:
  /// **'Per system policy, Admin accounts sign in on the web (desktop/tablet) to manage data. The mobile app is for managers and students.'**
  String get adminUseWebBody;

  /// No description provided for @webStaffOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Web portal for Admin & Manager'**
  String get webStaffOnlyTitle;

  /// No description provided for @webStaffOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Student accounts: please use the mobile app.'**
  String get webStaffOnlyBody;

  /// No description provided for @webRegisterNotAllowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get webRegisterNotAllowedTitle;

  /// No description provided for @webRegisterNotAllowedBody1.
  ///
  /// In en, this message translates to:
  /// **'Student registration is only available in the mobile app.'**
  String get webRegisterNotAllowedBody1;

  /// No description provided for @webRegisterNotAllowedBody2.
  ///
  /// In en, this message translates to:
  /// **'On the web, only Admin and Manager can sign in.'**
  String get webRegisterNotAllowedBody2;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLogin;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @markedAllRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get markedAllRead;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(Object message);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @agreeTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms and Privacy Policy'**
  String get agreeTermsRequired;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @verifyEmailBeforeLogin.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified. Please check your inbox and verify before signing in.'**
  String get verifyEmailBeforeLogin;

  /// No description provided for @registerSuccessVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully. Please verify your email before signing in.'**
  String get registerSuccessVerifyEmail;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @noAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get noAccountPrefix;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAction;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @resetEmailSentIfExists.
  ///
  /// In en, this message translates to:
  /// **'If the email exists, a reset link has been sent. Please check your inbox (including Spam).'**
  String get resetEmailSentIfExists;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @tryAgainLaterDetails.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later. Details: {message}'**
  String tryAgainLaterDetails(Object message);

  /// No description provided for @scanBookQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan book QR'**
  String get scanBookQrTitle;

  /// No description provided for @manageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manageTitle;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match'**
  String get passwordMismatch;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Please sign in or use another email.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password. Please choose a stronger one.'**
  String get weakPassword;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get passwordStrength;

  /// No description provided for @iAgreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with'**
  String get iAgreeWith;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andWord;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrefix;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @bookDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Book details'**
  String get bookDetailTitle;

  /// No description provided for @bookNotFound.
  ///
  /// In en, this message translates to:
  /// **'This book does not exist or was deleted.'**
  String get bookNotFound;

  /// No description provided for @bookListTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get bookListTitle;

  /// No description provided for @bookListSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select books'**
  String get bookListSelectMode;

  /// No description provided for @bookListSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String bookListSelectedCount(Object count);

  /// No description provided for @bookListSelectAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Select all visible'**
  String get bookListSelectAllVisible;

  /// No description provided for @bookListDeselectAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Deselect all visible'**
  String get bookListDeselectAllVisible;

  /// No description provided for @bookListBulkDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String bookListBulkDelete(Object count);

  /// No description provided for @bookListBulkDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} books? Books still on loan will be skipped.'**
  String bookListBulkDeleteConfirm(Object count);

  /// No description provided for @bookListBulkDeleteResult.
  ///
  /// In en, this message translates to:
  /// **'Deleted {deleted}. Skipped (on loan): {skipped}.'**
  String bookListBulkDeleteResult(Object deleted, Object skipped);

  /// No description provided for @bookListLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a book to select multiple, then tap to add or remove.'**
  String get bookListLongPressHint;

  /// No description provided for @addBook.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// No description provided for @categoriesManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get categoriesManageTitle;

  /// No description provided for @categoriesManageBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage book categories'**
  String get categoriesManageBooksTitle;

  /// No description provided for @staffOnlyCategoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Only Admin or Manager can edit categories.'**
  String get staffOnlyCategoryEdit;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @addFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Add your first category'**
  String get addFirstCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @usersManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get usersManageTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBookBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book? This action cannot be undone.'**
  String get deleteConfirmBookBody;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deletedBookToast.
  ///
  /// In en, this message translates to:
  /// **'Book deleted'**
  String get deletedBookToast;

  /// No description provided for @viewAsList.
  ///
  /// In en, this message translates to:
  /// **'View as list'**
  String get viewAsList;

  /// No description provided for @viewAsGrid.
  ///
  /// In en, this message translates to:
  /// **'View as grid'**
  String get viewAsGrid;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @searchBooksHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, ISBN, category, description, year…'**
  String get searchBooksHint;

  /// No description provided for @bookListMatchesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} matching books'**
  String bookListMatchesCount(int count);

  /// No description provided for @bookListEmptyLibrary.
  ///
  /// In en, this message translates to:
  /// **'No books in the library yet'**
  String get bookListEmptyLibrary;

  /// No description provided for @noBooksMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No books match your filters'**
  String get noBooksMatchFilters;

  /// No description provided for @cannotLoadList.
  ///
  /// In en, this message translates to:
  /// **'Failed to load list: {message}'**
  String cannotLoadList(Object message);

  /// No description provided for @noUsersYet.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get noUsersYet;

  /// No description provided for @staffOnlyUserManage.
  ///
  /// In en, this message translates to:
  /// **'Only Admin can assign roles and lock users.'**
  String get staffOnlyUserManage;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email…'**
  String get searchUsersHint;

  /// No description provided for @cannotLoadUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get cannotLoadUsers;

  /// No description provided for @lockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedLabel;

  /// No description provided for @borrowCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create borrow record'**
  String get borrowCreateTitle;

  /// No description provided for @returnBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Return book'**
  String get returnBookTitle;

  /// No description provided for @scanBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan book QR'**
  String get scanBookTitle;

  /// No description provided for @scanBookHint.
  ///
  /// In en, this message translates to:
  /// **'bookId / ISBN on the book label'**
  String get scanBookHint;

  /// No description provided for @scanStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR'**
  String get scanStudentTitle;

  /// No description provided for @scanStudentHint.
  ///
  /// In en, this message translates to:
  /// **'LIB_USER:... or student UID'**
  String get scanStudentHint;

  /// No description provided for @scanBorrowTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan borrow ticket'**
  String get scanBorrowTicketTitle;

  /// No description provided for @scanBorrowTicketHint.
  ///
  /// In en, this message translates to:
  /// **'LIB_RET:... after borrowing'**
  String get scanBorrowTicketHint;

  /// No description provided for @cannotReadBorrowTicket.
  ///
  /// In en, this message translates to:
  /// **'Cannot read the ticket code (needs LIB_RET:... or record id)'**
  String get cannotReadBorrowTicket;

  /// No description provided for @borrowTicketNotFound.
  ///
  /// In en, this message translates to:
  /// **'Borrow record not found'**
  String get borrowTicketNotFound;

  /// No description provided for @borrowTicketNotActive.
  ///
  /// In en, this message translates to:
  /// **'This record is not active (status is not borrowing).'**
  String get borrowTicketNotActive;

  /// No description provided for @currentBorrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Currently borrowed'**
  String get currentBorrowsTitle;

  /// No description provided for @cannotLoadCurrentBorrows.
  ///
  /// In en, this message translates to:
  /// **'Failed to load current borrows'**
  String get cannotLoadCurrentBorrows;

  /// No description provided for @noActiveBorrowsStaff.
  ///
  /// In en, this message translates to:
  /// **'No active borrow records'**
  String get noActiveBorrowsStaff;

  /// No description provided for @noActiveBorrowsStudent.
  ///
  /// In en, this message translates to:
  /// **'You have no borrowed books'**
  String get noActiveBorrowsStudent;

  /// No description provided for @dueDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueDatePrefix(Object date);

  /// No description provided for @daysLeftPrefix.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeftPrefix(Object days);

  /// No description provided for @overduePrefix.
  ///
  /// In en, this message translates to:
  /// **'Overdue {days} days'**
  String overduePrefix(Object days);

  /// No description provided for @returnAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnAction;

  /// No description provided for @borrowHistoryTitle2.
  ///
  /// In en, this message translates to:
  /// **'Borrow history'**
  String get borrowHistoryTitle2;

  /// No description provided for @cannotLoadBorrowHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load borrow history'**
  String get cannotLoadBorrowHistory;

  /// No description provided for @noBorrowHistoryStaff.
  ///
  /// In en, this message translates to:
  /// **'No borrow/return history yet'**
  String get noBorrowHistoryStaff;

  /// No description provided for @noBorrowHistoryStudent.
  ///
  /// In en, this message translates to:
  /// **'You have no borrow/return history'**
  String get noBorrowHistoryStudent;

  /// No description provided for @borrowedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Borrowed: {borrow} - Returned: {ret}'**
  String borrowedPrefix(Object borrow, Object ret);

  /// No description provided for @finePrefix.
  ///
  /// In en, this message translates to:
  /// **'Fine: {amount}'**
  String finePrefix(Object amount);

  /// No description provided for @finePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine payment'**
  String get finePaymentTitle;

  /// No description provided for @totalFineLabel.
  ///
  /// In en, this message translates to:
  /// **'Total fine'**
  String get totalFineLabel;

  /// No description provided for @fineDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fine details'**
  String get fineDetailsTitle;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodTitle;

  /// No description provided for @cashAtLibrary.
  ///
  /// In en, this message translates to:
  /// **'Cash at library'**
  String get cashAtLibrary;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @payAmountButton.
  ///
  /// In en, this message translates to:
  /// **'PAY {amount}'**
  String payAmountButton(Object amount);

  /// No description provided for @scanStudentQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR'**
  String get scanStudentQrButton;

  /// No description provided for @scanBookQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan book QR'**
  String get scanBookQrButton;

  /// No description provided for @findAction.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findAction;

  /// No description provided for @createBorrowButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE BORROW RECORD'**
  String get createBorrowButton;

  /// No description provided for @bookCodeInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter book code (bookId or ISBN)'**
  String get bookCodeInputTitle;

  /// No description provided for @bookCodeHint.
  ///
  /// In en, this message translates to:
  /// **'bookId / ISBN'**
  String get bookCodeHint;

  /// No description provided for @studentBorrowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrower (email or student code)'**
  String get studentBorrowerTitle;

  /// No description provided for @studentBorrowerHint.
  ///
  /// In en, this message translates to:
  /// **'Email or student code'**
  String get studentBorrowerHint;

  /// No description provided for @borrowDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrow date'**
  String get borrowDateLabel;

  /// No description provided for @expectedReturnDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected return date (loanDays = {days})'**
  String expectedReturnDateLabel(Object days);

  /// No description provided for @borrowDueDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Expected return date'**
  String get borrowDueDateTitle;

  /// No description provided for @borrowDueDateHint.
  ///
  /// In en, this message translates to:
  /// **'3–30 days from today (recommended 7–14). Tap to choose.'**
  String get borrowDueDateHint;

  /// No description provided for @borrowDueDateErrorRange.
  ///
  /// In en, this message translates to:
  /// **'Return date must be between 3 and 30 days from today.'**
  String get borrowDueDateErrorRange;

  /// No description provided for @pleaseEnterBookCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter bookId or ISBN'**
  String get pleaseEnterBookCode;

  /// No description provided for @bookNotFoundShort.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get bookNotFoundShort;

  /// No description provided for @bookLookupError.
  ///
  /// In en, this message translates to:
  /// **'Book lookup failed: {message}'**
  String bookLookupError(Object message);

  /// No description provided for @pleaseEnterStudentQuery.
  ///
  /// In en, this message translates to:
  /// **'Please enter email or student code'**
  String get pleaseEnterStudentQuery;

  /// No description provided for @studentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Student not found'**
  String get studentNotFound;

  /// No description provided for @studentLookupError.
  ///
  /// In en, this message translates to:
  /// **'Student lookup failed: {message}'**
  String studentLookupError(Object message);

  /// No description provided for @studentLockedCannotBorrow.
  ///
  /// In en, this message translates to:
  /// **'This student account is locked and cannot borrow.'**
  String get studentLockedCannotBorrow;

  /// No description provided for @needReSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get needReSignIn;

  /// No description provided for @borrowCreatedSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow record created'**
  String get borrowCreatedSuccessTitle;

  /// No description provided for @borrowCreatedSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR at the desk when returning:'**
  String get borrowCreatedSuccessBody;

  /// No description provided for @scanTabUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get scanTabUploadImage;

  /// No description provided for @scanTabHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get scanTabHistory;

  /// No description provided for @scanTabNeedSwitchToScan.
  ///
  /// In en, this message translates to:
  /// **'Switch to Scan tab and close overlays to scan from image.'**
  String get scanTabNeedSwitchToScan;

  /// No description provided for @qrInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get qrInvalid;

  /// No description provided for @bookNotFoundFromQr.
  ///
  /// In en, this message translates to:
  /// **'No book found from QR/ISBN'**
  String get bookNotFoundFromQr;

  /// No description provided for @borrowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrowed successfully'**
  String get borrowSuccess;

  /// No description provided for @borrowFailed.
  ///
  /// In en, this message translates to:
  /// **'Borrow failed: {message}'**
  String borrowFailed(Object message);

  /// No description provided for @returnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Returned successfully'**
  String get returnSuccess;

  /// No description provided for @returnFailed.
  ///
  /// In en, this message translates to:
  /// **'Return failed: {message}'**
  String returnFailed(Object message);

  /// No description provided for @noQrFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR found in the selected image'**
  String get noQrFoundInImage;

  /// No description provided for @cannotScanImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot scan image: {message}'**
  String cannotScanImage(Object message);

  /// No description provided for @bookInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Book information'**
  String get bookInfoTitle;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {message}'**
  String profileLoadError(Object message);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {message}'**
  String profileUpdateFailed(Object message);

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullNameLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhoneLabel;

  /// No description provided for @profileStudentCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Student code'**
  String get profileStudentCodeLabel;

  /// No description provided for @profileAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddressLabel;

  /// No description provided for @profileEmailReadonlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (read-only in app)'**
  String get profileEmailReadonlyLabel;

  /// No description provided for @profileMissingName.
  ///
  /// In en, this message translates to:
  /// **'(Missing full name)'**
  String get profileMissingName;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager / Librarian'**
  String get roleManager;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @manageCreateBorrow.
  ///
  /// In en, this message translates to:
  /// **'Create borrow record'**
  String get manageCreateBorrow;

  /// No description provided for @manageCreateBorrowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter book and student to create a new record'**
  String get manageCreateBorrowSubtitle;

  /// No description provided for @manageReturnBook.
  ///
  /// In en, this message translates to:
  /// **'Return book'**
  String get manageReturnBook;

  /// No description provided for @manageReturnBookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan ticket QR or search by book + student'**
  String get manageReturnBookSubtitle;

  /// No description provided for @manageCurrentBorrows.
  ///
  /// In en, this message translates to:
  /// **'Current borrows'**
  String get manageCurrentBorrows;

  /// No description provided for @manageBorrowHistory.
  ///
  /// In en, this message translates to:
  /// **'Borrow history'**
  String get manageBorrowHistory;

  /// No description provided for @manageCategoryManage.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategoryManage;

  /// No description provided for @manageUserManage.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUserManage;

  /// No description provided for @manageStatsReports.
  ///
  /// In en, this message translates to:
  /// **'Statistics & reports'**
  String get manageStatsReports;

  /// No description provided for @webHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get webHello;

  /// No description provided for @webAdminOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Books inventory & borrow operations — web admin portal.'**
  String get webAdminOverviewSubtitle;

  /// No description provided for @webSectionOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get webSectionOverview;

  /// No description provided for @webSectionInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get webSectionInventory;

  /// No description provided for @webSectionDesk.
  ///
  /// In en, this message translates to:
  /// **'Desk'**
  String get webSectionDesk;

  /// No description provided for @webSectionOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get webSectionOperations;

  /// No description provided for @webSectionSystemConfig.
  ///
  /// In en, this message translates to:
  /// **'System configuration'**
  String get webSectionSystemConfig;

  /// No description provided for @webNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get webNotificationsTooltip;

  /// No description provided for @webMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get webMenuProfile;

  /// No description provided for @webMenuSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get webMenuSignOut;

  /// No description provided for @webControlCenter.
  ///
  /// In en, this message translates to:
  /// **'Control center'**
  String get webControlCenter;

  /// No description provided for @webMetricTitles.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get webMetricTitles;

  /// No description provided for @webMetricTitlesSub.
  ///
  /// In en, this message translates to:
  /// **'in inventory'**
  String get webMetricTitlesSub;

  /// No description provided for @webMetricTotalCopies.
  ///
  /// In en, this message translates to:
  /// **'Total copies'**
  String get webMetricTotalCopies;

  /// No description provided for @webMetricTotalCopiesSub.
  ///
  /// In en, this message translates to:
  /// **'all copies'**
  String get webMetricTotalCopiesSub;

  /// No description provided for @webMetricAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get webMetricAvailable;

  /// No description provided for @webMetricAvailableSub.
  ///
  /// In en, this message translates to:
  /// **'availableQuantity'**
  String get webMetricAvailableSub;

  /// No description provided for @webMetricBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get webMetricBorrowed;

  /// No description provided for @webMetricBorrowedSub.
  ///
  /// In en, this message translates to:
  /// **'currently borrowed'**
  String get webMetricBorrowedSub;

  /// No description provided for @webQuickAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add new book'**
  String get webQuickAddBook;

  /// No description provided for @webQuickStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get webQuickStats;

  /// No description provided for @createQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Create QR code'**
  String get createQrTitle;

  /// No description provided for @createQrSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get createQrSave;

  /// No description provided for @createQrTypeUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get createQrTypeUrl;

  /// No description provided for @createQrTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get createQrTypeText;

  /// No description provided for @createQrTypeVcard.
  ///
  /// In en, this message translates to:
  /// **'vCard'**
  String get createQrTypeVcard;

  /// No description provided for @createQrTypeWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get createQrTypeWifi;

  /// No description provided for @createQrTypeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get createQrTypeEmail;

  /// No description provided for @createQrEnterContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter content to generate QR'**
  String get createQrEnterContent;

  /// No description provided for @createQrCreatedToast.
  ///
  /// In en, this message translates to:
  /// **'Created QR: {name}'**
  String createQrCreatedToast(Object name);

  /// No description provided for @createQrUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get createQrUnnamed;

  /// No description provided for @createQrActionButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE QR CODE'**
  String get createQrActionButton;

  /// No description provided for @createQrContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get createQrContentTitle;

  /// No description provided for @createQrNameLabel.
  ///
  /// In en, this message translates to:
  /// **'QR name'**
  String get createQrNameLabel;

  /// No description provided for @createQrNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Shelf A1 - Floor 2'**
  String get createQrNameHint;

  /// No description provided for @createQrUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Web URL'**
  String get createQrUrlLabel;

  /// No description provided for @createQrUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://library.example.com'**
  String get createQrUrlHint;

  /// No description provided for @createQrTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get createQrTextLabel;

  /// No description provided for @createQrTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text...'**
  String get createQrTextHint;

  /// No description provided for @createQrVcardFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get createQrVcardFullNameLabel;

  /// No description provided for @createQrVcardFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get createQrVcardFullNameHint;

  /// No description provided for @createQrEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get createQrEmailLabel;

  /// No description provided for @createQrEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get createQrEmailHint;

  /// No description provided for @createQrWifiSsidLabel.
  ///
  /// In en, this message translates to:
  /// **'SSID'**
  String get createQrWifiSsidLabel;

  /// No description provided for @createQrWifiSsidHint.
  ///
  /// In en, this message translates to:
  /// **'WiFi name'**
  String get createQrWifiSsidHint;

  /// No description provided for @createQrWifiPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get createQrWifiPasswordLabel;

  /// No description provided for @createQrWifiPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'WiFi password'**
  String get createQrWifiPasswordHint;

  /// No description provided for @createQrEmailToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get createQrEmailToLabel;

  /// No description provided for @createQrEmailToHint.
  ///
  /// In en, this message translates to:
  /// **'to@example.com'**
  String get createQrEmailToHint;

  /// No description provided for @createQrEmailSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get createQrEmailSubjectLabel;

  /// No description provided for @createQrEmailSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Subject...'**
  String get createQrEmailSubjectHint;

  /// No description provided for @createQrEmailBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get createQrEmailBodyLabel;

  /// No description provided for @createQrEmailBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Email body...'**
  String get createQrEmailBodyHint;

  /// No description provided for @createQrDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get createQrDesignTitle;

  /// No description provided for @createQrColorLabel.
  ///
  /// In en, this message translates to:
  /// **'QR color'**
  String get createQrColorLabel;

  /// No description provided for @createQrLogoOptional.
  ///
  /// In en, this message translates to:
  /// **'Logo (optional)'**
  String get createQrLogoOptional;

  /// No description provided for @createQrUploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get createQrUploadLogo;

  /// No description provided for @createQrPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get createQrPreviewTitle;

  /// No description provided for @scanFlashTooltip.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get scanFlashTooltip;

  /// No description provided for @scanSwitchCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get scanSwitchCameraTooltip;

  /// No description provided for @scanAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Align QR code within the frame'**
  String get scanAlignHint;

  /// No description provided for @borrowScanBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan book QR'**
  String get borrowScanBookTitle;

  /// No description provided for @borrowScanBookHint.
  ///
  /// In en, this message translates to:
  /// **'bookId / ISBN on book label'**
  String get borrowScanBookHint;

  /// No description provided for @borrowScanStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR'**
  String get borrowScanStudentTitle;

  /// No description provided for @borrowScanStudentHint.
  ///
  /// In en, this message translates to:
  /// **'LIB_USER:... on student profile'**
  String get borrowScanStudentHint;

  /// No description provided for @borrowScannedReturnTicketHelp.
  ///
  /// In en, this message translates to:
  /// **'This is a return ticket QR. Go to Return → Scan ticket.'**
  String get borrowScannedReturnTicketHelp;

  /// No description provided for @borrowScannedStudentCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'This is a student QR — use Student field or Scan student button.'**
  String get borrowScannedStudentCodeHelp;

  /// No description provided for @borrowScannedBorrowTicketNotForStudent.
  ///
  /// In en, this message translates to:
  /// **'This is a borrow ticket QR — not for student field.'**
  String get borrowScannedBorrowTicketNotForStudent;

  /// No description provided for @borrowSignedInAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Signed in: Admin'**
  String get borrowSignedInAsAdmin;

  /// No description provided for @borrowSignedInAsManager.
  ///
  /// In en, this message translates to:
  /// **'Signed in: Manager / Librarian'**
  String get borrowSignedInAsManager;

  /// No description provided for @borrowCreateFlowHint.
  ///
  /// In en, this message translates to:
  /// **'Scan/enter the book first, then the student — a record is created only when both are filled. (Camera here is a separate scanner screen.)'**
  String get borrowCreateFlowHint;

  /// No description provided for @borrowScanStudentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR'**
  String get borrowScanStudentTooltip;

  /// No description provided for @borrowScanStudentInlineHint.
  ///
  /// In en, this message translates to:
  /// **'Scan QR to get uid/email/student ID'**
  String get borrowScanStudentInlineHint;

  /// No description provided for @borrowBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book does not exist'**
  String get borrowBookNotFound;

  /// No description provided for @borrowStudentProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'Student profile missing in Firestore (users/{uid}).'**
  String borrowStudentProfileMissing(Object uid);

  /// No description provided for @borrowOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Book is out of stock (availableQuantity = 0)'**
  String get borrowOutOfStock;

  /// No description provided for @borrowNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow created'**
  String get borrowNotificationTitle;

  /// No description provided for @borrowNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{bookTitle} — due {dueDate}'**
  String borrowNotificationBody(Object bookTitle, Object dueDate);

  /// No description provided for @borrowPermissionDeniedHelp.
  ///
  /// In en, this message translates to:
  /// **'No permission to write Firestore (permission-denied). Check users.role = manager/admin and deployed rules.'**
  String get borrowPermissionDeniedHelp;

  /// No description provided for @borrowCreateFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Cannot create borrow record [{code}]: {message}'**
  String borrowCreateFailedWithCode(Object code, Object message);

  /// No description provided for @borrowStepBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get borrowStepBook;

  /// No description provided for @borrowStepStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get borrowStepStudent;

  /// No description provided for @borrowStepCreateTicket.
  ///
  /// In en, this message translates to:
  /// **'Create ticket'**
  String get borrowStepCreateTicket;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statsBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get statsBooksTitle;

  /// No description provided for @statsBooksCopiesDelta.
  ///
  /// In en, this message translates to:
  /// **'{copies} copies'**
  String statsBooksCopiesDelta(Object copies);

  /// No description provided for @statsAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statsAvailableTitle;

  /// No description provided for @statsAvailableDelta.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statsAvailableDelta;

  /// No description provided for @statsBorrowingTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get statsBorrowingTitle;

  /// No description provided for @statsBorrowingDelta.
  ///
  /// In en, this message translates to:
  /// **'Active records'**
  String get statsBorrowingDelta;

  /// No description provided for @statsReturnedLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Returned / Late'**
  String get statsReturnedLateTitle;

  /// No description provided for @statsLateDelta.
  ///
  /// In en, this message translates to:
  /// **'Late: {count}'**
  String statsLateDelta(Object count);

  /// No description provided for @statsStableDelta.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get statsStableDelta;

  /// No description provided for @deskTitle.
  ///
  /// In en, this message translates to:
  /// **'Library desk'**
  String get deskTitle;

  /// No description provided for @deskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lookup and handle borrow/return by code — no camera needed (web).'**
  String get deskSubtitle;

  /// No description provided for @deskLookupTitle.
  ///
  /// In en, this message translates to:
  /// **'Book lookup'**
  String get deskLookupTitle;

  /// No description provided for @deskCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter bookId (Firestore id) or ISBN'**
  String get deskCodeHint;

  /// No description provided for @enterBookIdOrIsbn.
  ///
  /// In en, this message translates to:
  /// **'Enter bookId or ISBN'**
  String get enterBookIdOrIsbn;

  /// No description provided for @lookupError.
  ///
  /// In en, this message translates to:
  /// **'Lookup error: {message}'**
  String lookupError(Object message);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @quickCreateBorrow.
  ///
  /// In en, this message translates to:
  /// **'Create borrow record'**
  String get quickCreateBorrow;

  /// No description provided for @quickCreateBorrowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter bookId & student'**
  String get quickCreateBorrowSubtitle;

  /// No description provided for @quickReturn.
  ///
  /// In en, this message translates to:
  /// **'Return book'**
  String get quickReturn;

  /// No description provided for @quickReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By active record'**
  String get quickReturnSubtitle;

  /// No description provided for @quickCurrentBorrows.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get quickCurrentBorrows;

  /// No description provided for @quickCurrentBorrowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Records list'**
  String get quickCurrentBorrowsSubtitle;

  /// No description provided for @quickHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get quickHistory;

  /// No description provided for @quickHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All records'**
  String get quickHistorySubtitle;

  /// No description provided for @addBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new book'**
  String get addBookTitle;

  /// No description provided for @editBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Update book'**
  String get editBookTitle;

  /// No description provided for @excelImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Excel'**
  String get excelImportTitle;

  /// No description provided for @downloadExcelTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download template: 5 books (Vietnamese columns)'**
  String get downloadExcelTemplate;

  /// No description provided for @pickXlsx.
  ///
  /// In en, this message translates to:
  /// **'Choose .xlsx file'**
  String get pickXlsx;

  /// No description provided for @importInventory.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importInventory;

  /// No description provided for @importNBooks.
  ///
  /// In en, this message translates to:
  /// **'Import {count} books'**
  String importNBooks(Object count);

  /// No description provided for @categoryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new category'**
  String get categoryAddTitle;

  /// No description provided for @categoryRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get categoryRenameTitle;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameHint;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get categoryNameRequired;

  /// No description provided for @categoryAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Added category \"{name}\"'**
  String categoryAddedToast(Object name);

  /// No description provided for @categoryUpdatedToast.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get categoryUpdatedToast;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the catalog list. No books are currently using this category.'**
  String categoryDeleteBody(Object name);

  /// No description provided for @categoryDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeletedToast;

  /// No description provided for @categoryDeleteHasBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Category still has books'**
  String get categoryDeleteHasBooksTitle;

  /// No description provided for @categoryDeleteHasBooksBody.
  ///
  /// In en, this message translates to:
  /// **'{count} book(s) use \"{name}\". Move them to another category, or delete those books (cannot be undone).'**
  String categoryDeleteHasBooksBody(Object count, Object name);

  /// No description provided for @categoryDeleteMoveToLabel.
  ///
  /// In en, this message translates to:
  /// **'Move all books to'**
  String get categoryDeleteMoveToLabel;

  /// No description provided for @categoryDeleteButtonReassign.
  ///
  /// In en, this message translates to:
  /// **'Move books & delete category'**
  String get categoryDeleteButtonReassign;

  /// No description provided for @categoryDeleteButtonPurgeBooks.
  ///
  /// In en, this message translates to:
  /// **'Delete those books & category'**
  String get categoryDeleteButtonPurgeBooks;

  /// No description provided for @categoryDeletePurgeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete books?'**
  String get categoryDeletePurgeConfirmTitle;

  /// No description provided for @categoryDeletePurgeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count} book(s). Continue?'**
  String categoryDeletePurgeConfirmBody(Object count);

  /// No description provided for @categoryDeleteToastReassigned.
  ///
  /// In en, this message translates to:
  /// **'Books moved; category deleted'**
  String get categoryDeleteToastReassigned;

  /// No description provided for @categoryDeleteToastPurged.
  ///
  /// In en, this message translates to:
  /// **'Books and category deleted'**
  String get categoryDeleteToastPurged;

  /// No description provided for @categoryDeleteNoMoveTarget.
  ///
  /// In en, this message translates to:
  /// **'No target category. Add another category (other than \"{name}\") first, or delete all books in this category.'**
  String categoryDeleteNoMoveTarget(Object name);

  /// No description provided for @returnFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find the borrow record to return'**
  String get returnFindTitle;

  /// No description provided for @returnFindBody.
  ///
  /// In en, this message translates to:
  /// **'Librarians can scan the ticket QR (LIB_RET:…) to return. If the ticket is lost, enter book + student and search.'**
  String get returnFindBody;

  /// No description provided for @enterBookCode.
  ///
  /// In en, this message translates to:
  /// **'Enter book code (bookId or ISBN)'**
  String get enterBookCode;

  /// No description provided for @bookIdOrIsbnHint.
  ///
  /// In en, this message translates to:
  /// **'bookId / ISBN'**
  String get bookIdOrIsbnHint;

  /// No description provided for @studentQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'Student (uid / email or student ID)'**
  String get studentQueryLabel;

  /// No description provided for @studentQueryHint.
  ///
  /// In en, this message translates to:
  /// **'uid / Email or student ID'**
  String get studentQueryHint;

  /// No description provided for @findBorrowingRecord.
  ///
  /// In en, this message translates to:
  /// **'FIND ACTIVE BORROW'**
  String get findBorrowingRecord;

  /// No description provided for @borrowRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrow record'**
  String get borrowRecordLabel;

  /// No description provided for @borrowRecordNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No record selected. Search by book + student.'**
  String get borrowRecordNotSelected;

  /// No description provided for @returnLoadRecordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load record: {message}'**
  String returnLoadRecordError(Object message);

  /// No description provided for @returnRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent returns'**
  String get returnRecentHistory;

  /// No description provided for @returnEnterBookAndStudent.
  ///
  /// In en, this message translates to:
  /// **'Please enter book code and student email/ID'**
  String get returnEnterBookAndStudent;

  /// No description provided for @returnBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get returnBookNotFound;

  /// No description provided for @returnStudentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Student not found'**
  String get returnStudentNotFound;

  /// No description provided for @returnNoActiveBorrowFound.
  ///
  /// In en, this message translates to:
  /// **'No active borrow record found for this book and student'**
  String get returnNoActiveBorrowFound;

  /// No description provided for @returnLookupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to lookup record: {message}'**
  String returnLookupError(Object message);

  /// No description provided for @returnNeedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get returnNeedRelogin;

  /// No description provided for @returnSuccessToast.
  ///
  /// In en, this message translates to:
  /// **'Return confirmed successfully'**
  String get returnSuccessToast;

  /// No description provided for @returnConfirmError.
  ///
  /// In en, this message translates to:
  /// **'Unable to return: {message}'**
  String returnConfirmError(Object message);

  /// No description provided for @returnDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get returnDeleteRecord;

  /// No description provided for @returnConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm return'**
  String get returnConfirmButton;

  /// No description provided for @returnCannotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load return history'**
  String get returnCannotLoadHistory;

  /// No description provided for @returnNoRecentReturns.
  ///
  /// In en, this message translates to:
  /// **'No recent returns'**
  String get returnNoRecentReturns;

  /// No description provided for @returnBookPrefix.
  ///
  /// In en, this message translates to:
  /// **'Book: {bookId}'**
  String returnBookPrefix(Object bookId);

  /// No description provided for @returnDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String returnDueDateLabel(Object date);

  /// No description provided for @returnMissingBookName.
  ///
  /// In en, this message translates to:
  /// **'(Missing book title)'**
  String get returnMissingBookName;

  /// No description provided for @returnLateDaysFine.
  ///
  /// In en, this message translates to:
  /// **'Late {days} days • Est. fine: {fine}'**
  String returnLateDaysFine(Object days, Object fine);

  /// No description provided for @returnLateWithFine.
  ///
  /// In en, this message translates to:
  /// **'Late • Fine: {fine}'**
  String returnLateWithFine(Object fine);

  /// No description provided for @returnOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get returnOnTime;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusBorrowing.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get statusBorrowing;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// No description provided for @loginSubtitleWeb.
  ///
  /// In en, this message translates to:
  /// **'Admin & Manager portal'**
  String get loginSubtitleWeb;

  /// No description provided for @loginSubtitleMobile.
  ///
  /// In en, this message translates to:
  /// **'Students & Managers — Admin uses the web browser'**
  String get loginSubtitleMobile;

  /// No description provided for @loginSnackWebStaffOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Admin or Manager accounts can sign in on the web. Students, please use the mobile app.'**
  String get loginSnackWebStaffOnly;

  /// No description provided for @loginSnackAdminWebOnly.
  ///
  /// In en, this message translates to:
  /// **'Admin accounts can only sign in on the web browser. Managers and students use this app.'**
  String get loginSnackAdminWebOnly;

  /// No description provided for @loginSnackGoogleWebStaffOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Admin or Manager accounts can sign in on the web. This Google account is a student — please use the mobile app.'**
  String get loginSnackGoogleWebStaffOnly;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get loginFailed;

  /// No description provided for @loginGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get loginGoogleFailed;

  /// No description provided for @authErrUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for this email'**
  String get authErrUserNotFound;

  /// No description provided for @authErrWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authErrWrongPassword;

  /// No description provided for @authErrInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get authErrInvalidCredential;

  /// No description provided for @authErrUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get authErrUserDisabled;

  /// No description provided for @authErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get authErrNetwork;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @demoCategoryTech.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get demoCategoryTech;

  /// No description provided for @demoCategoryEcon.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get demoCategoryEcon;

  /// No description provided for @demoCategoryLit.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get demoCategoryLit;

  /// No description provided for @demoCategorySci.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get demoCategorySci;

  /// No description provided for @demoCategoryHist.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get demoCategoryHist;

  /// No description provided for @demoCategoryEdu.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get demoCategoryEdu;

  /// No description provided for @sortOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortOptionTitle;

  /// No description provided for @sortOptionAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get sortOptionAuthor;

  /// No description provided for @sortOptionCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sortOptionCategory;

  /// No description provided for @sortOptionStock.
  ///
  /// In en, this message translates to:
  /// **'Available copies'**
  String get sortOptionStock;

  /// No description provided for @sortOptionDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortOptionDateAdded;

  /// No description provided for @bookStatTotalBooks.
  ///
  /// In en, this message translates to:
  /// **'Total books'**
  String get bookStatTotalBooks;

  /// No description provided for @bookStatAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookStatAvailable;

  /// No description provided for @bookStatBorrowed.
  ///
  /// In en, this message translates to:
  /// **'On loan'**
  String get bookStatBorrowed;

  /// No description provided for @excelImportFormatHint.
  ///
  /// In en, this message translates to:
  /// **'.xlsx file — row 1 is the header. Required: book title and author (e.g. title, author). Optional: category (demo group), genre / thể loại (links to genres), genre id, published year, isbn, quantity, description.'**
  String get excelImportFormatHint;

  /// No description provided for @bookQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get bookQuantityLabel;

  /// No description provided for @bookDescriptionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get bookDescriptionSectionTitle;

  /// No description provided for @bookDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Book description'**
  String get bookDescriptionFieldLabel;

  /// No description provided for @bookDescriptionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Short description of the book…'**
  String get bookDescriptionFieldHint;

  /// No description provided for @bookDetailTotalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total copies'**
  String get bookDetailTotalQuantity;

  /// No description provided for @bookDetailAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookDetailAvailable;

  /// No description provided for @bookDetailOnLoan.
  ///
  /// In en, this message translates to:
  /// **'On loan'**
  String get bookDetailOnLoan;

  /// No description provided for @bookDetailQrScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the code to look up the book or create a borrow record'**
  String get bookDetailQrScanHint;

  /// No description provided for @bookDetailIsbnTile.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get bookDetailIsbnTile;

  /// No description provided for @bookDetailCategoryTile.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bookDetailCategoryTile;

  /// No description provided for @bookDetailAuthorTile.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get bookDetailAuthorTile;

  /// No description provided for @bookDetailPublishedYearTile.
  ///
  /// In en, this message translates to:
  /// **'Published year'**
  String get bookDetailPublishedYearTile;

  /// No description provided for @bookDetailGenreTile.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get bookDetailGenreTile;

  /// No description provided for @bookDetailBorrowableTile.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get bookDetailBorrowableTile;

  /// No description provided for @bookDetailBorrowableYes.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookDetailBorrowableYes;

  /// No description provided for @bookDetailBorrowableNo.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get bookDetailBorrowableNo;

  /// No description provided for @bookDetailTotalBorrowsTile.
  ///
  /// In en, this message translates to:
  /// **'Total borrows'**
  String get bookDetailTotalBorrowsTile;

  /// No description provided for @bookDetailCreatedAtTile.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get bookDetailCreatedAtTile;

  /// No description provided for @bookDetailUpdatedAtTile.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get bookDetailUpdatedAtTile;

  /// No description provided for @bookDetailValueDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get bookDetailValueDash;

  /// No description provided for @bookDetailMetadataSection.
  ///
  /// In en, this message translates to:
  /// **'Activity & updates'**
  String get bookDetailMetadataSection;

  /// No description provided for @bookNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description for this book yet.'**
  String get bookNoDescription;

  /// No description provided for @bookDetailActionCreateBorrow.
  ///
  /// In en, this message translates to:
  /// **'Create slip'**
  String get bookDetailActionCreateBorrow;

  /// No description provided for @bookDetailActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get bookDetailActionShare;

  /// No description provided for @bookDetailActionPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get bookDetailActionPrint;

  /// No description provided for @studentHomeStatUniqueTitles.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get studentHomeStatUniqueTitles;

  /// No description provided for @studentHomeStatLibraryStock.
  ///
  /// In en, this message translates to:
  /// **'Library stock'**
  String get studentHomeStatLibraryStock;

  /// No description provided for @studentHomeStatActiveBorrows.
  ///
  /// In en, this message translates to:
  /// **'Borrowing'**
  String get studentHomeStatActiveBorrows;

  /// No description provided for @studentHomeStatActiveTickets.
  ///
  /// In en, this message translates to:
  /// **'Active slips'**
  String get studentHomeStatActiveTickets;

  /// No description provided for @studentHomeStatCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get studentHomeStatCategories;

  /// No description provided for @studentHomeStatCategoryKinds.
  ///
  /// In en, this message translates to:
  /// **'Book types'**
  String get studentHomeStatCategoryKinds;

  /// No description provided for @studentHomeStatBorrowedToday.
  ///
  /// In en, this message translates to:
  /// **'Borrowed today'**
  String get studentHomeStatBorrowedToday;

  /// No description provided for @studentHomeStatWithinToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get studentHomeStatWithinToday;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeAgoDays(int count);

  /// No description provided for @currentBorrowsPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: if you see permission-denied, check the user document in Firestore (collection users) has field role set to manager or admin, and that firestore.rules is deployed.'**
  String get currentBorrowsPermissionHint;

  /// No description provided for @borrowSheetFine.
  ///
  /// In en, this message translates to:
  /// **'Fine: {amount}'**
  String borrowSheetFine(Object amount);

  /// No description provided for @bookTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Book ({id})'**
  String bookTitleFallback(Object id);

  /// No description provided for @userNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(No name)'**
  String get userNamePlaceholder;

  /// No description provided for @statsSectionScansOverTime.
  ///
  /// In en, this message translates to:
  /// **'Borrow events over time'**
  String get statsSectionScansOverTime;

  /// No description provided for @statsSectionLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get statsSectionLast7Days;

  /// No description provided for @statsDateRangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsDateRangeThisWeek;

  /// No description provided for @statsCategoryBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get statsCategoryBreakdownTitle;

  /// No description provided for @statsTopBorrowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Most borrowed books'**
  String get statsTopBorrowedTitle;

  /// No description provided for @statsFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String statsFolderLabel(Object name);

  /// No description provided for @statsBorrowCountUnit.
  ///
  /// In en, this message translates to:
  /// **'borrows'**
  String get statsBorrowCountUnit;

  /// No description provided for @statsNoChartData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get statsNoChartData;

  /// No description provided for @statsEmptyTopBooks.
  ///
  /// In en, this message translates to:
  /// **'No borrow records yet'**
  String get statsEmptyTopBooks;

  /// No description provided for @statsBookFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get statsBookFallbackTitle;

  /// No description provided for @statsExportReport.
  ///
  /// In en, this message translates to:
  /// **'EXPORT REPORT'**
  String get statsExportReport;

  /// No description provided for @statsExportDone.
  ///
  /// In en, this message translates to:
  /// **'Report file download started.'**
  String get statsExportDone;

  /// No description provided for @statsExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String statsExportError(Object error);

  /// No description provided for @statsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view statistics.'**
  String get statsPermissionDenied;

  /// No description provided for @statsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics data (check Firestore permissions).'**
  String get statsLoadError;

  /// No description provided for @statsDateRangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range (applies to borrows & reports)'**
  String get statsDateRangeHelp;

  /// No description provided for @statsDatePickerDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get statsDatePickerDone;

  /// No description provided for @statsDatePickerCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get statsDatePickerCancel;

  /// No description provided for @statsExportPickFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose export format'**
  String get statsExportPickFormat;

  /// No description provided for @statsExportFormatExcel.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Excel (.xlsx)'**
  String get statsExportFormatExcel;

  /// No description provided for @statsExportFormatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF (.pdf)'**
  String get statsExportFormatPdf;

  /// No description provided for @statsOverviewSection.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get statsOverviewSection;

  /// No description provided for @statsOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Some metrics are library-wide; borrows use the selected date range above.'**
  String get statsOverviewSubtitle;

  /// No description provided for @statsCardBookTitles.
  ///
  /// In en, this message translates to:
  /// **'Titles'**
  String get statsCardBookTitles;

  /// No description provided for @statsDeltaTotalPrintCopies.
  ///
  /// In en, this message translates to:
  /// **'{copies} print copies'**
  String statsDeltaTotalPrintCopies(Object copies);

  /// No description provided for @statsCardUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get statsCardUsers;

  /// No description provided for @statsDeltaAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get statsDeltaAccounts;

  /// No description provided for @statsCardBorrowTurnsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Borrows (period)'**
  String get statsCardBorrowTurnsPeriod;

  /// No description provided for @statsDeltaByBorrowDate.
  ///
  /// In en, this message translates to:
  /// **'By borrowDate'**
  String get statsDeltaByBorrowDate;

  /// No description provided for @statsCardActiveTickets.
  ///
  /// In en, this message translates to:
  /// **'Active loans'**
  String get statsCardActiveTickets;

  /// No description provided for @statsDeltaSystemWide.
  ///
  /// In en, this message translates to:
  /// **'System-wide'**
  String get statsDeltaSystemWide;

  /// No description provided for @statsCardInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get statsCardInStock;

  /// No description provided for @statsDeltaTotalAvailable.
  ///
  /// In en, this message translates to:
  /// **'Total available'**
  String get statsDeltaTotalAvailable;

  /// No description provided for @statsCardReturnedLatePeriod.
  ///
  /// In en, this message translates to:
  /// **'Returned / Late (period)'**
  String get statsCardReturnedLatePeriod;

  /// No description provided for @statsDeltaLateShort.
  ///
  /// In en, this message translates to:
  /// **'Late: {count}'**
  String statsDeltaLateShort(Object count);

  /// No description provided for @statsBorrowReturnPeriodSection.
  ///
  /// In en, this message translates to:
  /// **'Borrow & return in period'**
  String get statsBorrowReturnPeriodSection;

  /// No description provided for @statsKvBorrowingTicketsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Currently borrowing (records in period)'**
  String get statsKvBorrowingTicketsInPeriod;

  /// No description provided for @statsKvReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statsKvReturned;

  /// No description provided for @statsKvLateRecorded.
  ///
  /// In en, this message translates to:
  /// **'Late (recorded)'**
  String get statsKvLateRecorded;

  /// No description provided for @statsKvOnTimeRate.
  ///
  /// In en, this message translates to:
  /// **'On-time return rate*'**
  String get statsKvOnTimeRate;

  /// No description provided for @statsKvAvgBorrowDaysReturned.
  ///
  /// In en, this message translates to:
  /// **'Avg. borrow span (returned)'**
  String get statsKvAvgBorrowDaysReturned;

  /// No description provided for @statsKvAvgBorrowDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String statsKvAvgBorrowDaysValue(Object days);

  /// No description provided for @statsFootnoteOnTimeReturns.
  ///
  /// In en, this message translates to:
  /// **'*Among returned records with borrow/due/return dates in the period.'**
  String get statsFootnoteOnTimeReturns;

  /// No description provided for @statsDailyBorrowsSection.
  ///
  /// In en, this message translates to:
  /// **'Borrows by day (period)'**
  String get statsDailyBorrowsSection;

  /// No description provided for @statsTotalTurns.
  ///
  /// In en, this message translates to:
  /// **'Total {count} turns'**
  String statsTotalTurns(Object count);

  /// No description provided for @statsMonthlyBorrowsSection.
  ///
  /// In en, this message translates to:
  /// **'Borrows by month (last 12 months)'**
  String get statsMonthlyBorrowsSection;

  /// No description provided for @statsMonthlyTrendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trend comparison by borrowDate'**
  String get statsMonthlyTrendSubtitle;

  /// No description provided for @statsCategoriesSection.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statsCategoriesSection;

  /// No description provided for @statsCategoriesDonutsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Left: title stock — Right: borrows in period'**
  String get statsCategoriesDonutsSubtitle;

  /// No description provided for @statsDonutByInventory.
  ///
  /// In en, this message translates to:
  /// **'By inventory (titles)'**
  String get statsDonutByInventory;

  /// No description provided for @statsDonutBorrowedInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Borrowed (period)'**
  String get statsDonutBorrowedInPeriod;

  /// No description provided for @statsTopCategoriesBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Top borrowed categories'**
  String get statsTopCategoriesBorrowed;

  /// No description provided for @statsBooksSection.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get statsBooksSection;

  /// No description provided for @statsBooksSectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top / least in period — Out of stock — New titles'**
  String get statsBooksSectionsSubtitle;

  /// No description provided for @statsTopBorrowedThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Most borrowed (period)'**
  String get statsTopBorrowedThisPeriod;

  /// No description provided for @statsLeastBorrowedThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Least borrowed (period)'**
  String get statsLeastBorrowedThisPeriod;

  /// No description provided for @statsOutOfStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of stock (available ≤ 0)'**
  String get statsOutOfStockTitle;

  /// No description provided for @statsOutOfStockEmpty.
  ///
  /// In en, this message translates to:
  /// **'No titles are out of stock.'**
  String get statsOutOfStockEmpty;

  /// No description provided for @statsNewBooksInPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'New books in period (createdAt)'**
  String get statsNewBooksInPeriodTitle;

  /// No description provided for @statsNewBooksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new books in this date range.'**
  String get statsNewBooksEmpty;

  /// No description provided for @statsAuthorsByPeriodSection.
  ///
  /// In en, this message translates to:
  /// **'Authors (by period borrows)'**
  String get statsAuthorsByPeriodSection;

  /// No description provided for @statsUsersSection.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get statsUsersSection;

  /// No description provided for @statsTopUsersPeriod.
  ///
  /// In en, this message translates to:
  /// **'Most borrows in period (top 10)'**
  String get statsTopUsersPeriod;

  /// No description provided for @statsBorrowersActiveTickets.
  ///
  /// In en, this message translates to:
  /// **'Currently borrowing (active records)'**
  String get statsBorrowersActiveTickets;

  /// No description provided for @statsBorrowersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue-related (late / past due)'**
  String get statsBorrowersOverdue;

  /// No description provided for @statsMonthCompareTwo.
  ///
  /// In en, this message translates to:
  /// **'Last two months: {m1} ({c1}) → {m2} ({c2})  {arrow} {diff} turns'**
  String statsMonthCompareTwo(
    Object m1,
    Object c1,
    Object m2,
    Object c2,
    Object arrow,
    Object diff,
  );

  /// No description provided for @statsBookStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{avail} / {qty} left{authorSuffix}'**
  String statsBookStockSubtitle(Object avail, Object qty, Object authorSuffix);

  /// No description provided for @statsUserBorrowCount.
  ///
  /// In en, this message translates to:
  /// **'{count} borrows'**
  String statsUserBorrowCount(Object count);

  /// No description provided for @statsBorrowersNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get statsBorrowersNone;

  /// No description provided for @statsBorrowerOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'Late {count}'**
  String statsBorrowerOverdueCount(Object count);

  /// No description provided for @statsBorrowerActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Tickets {count}'**
  String statsBorrowerActiveCount(Object count);

  /// No description provided for @exportStatReportTitleFull.
  ///
  /// In en, this message translates to:
  /// **'Library statistics report (full)'**
  String get exportStatReportTitleFull;

  /// No description provided for @exportStatReportTitlePdf.
  ///
  /// In en, this message translates to:
  /// **'Library statistics report'**
  String get exportStatReportTitlePdf;

  /// No description provided for @exportStatDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range: {range}'**
  String exportStatDateRange(Object range);

  /// No description provided for @exportStatExportedAt.
  ///
  /// In en, this message translates to:
  /// **'Exported at: {dateTime}'**
  String exportStatExportedAt(Object dateTime);

  /// No description provided for @exportStatMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get exportStatMetric;

  /// No description provided for @exportStatValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get exportStatValue;

  /// No description provided for @exportStatBookTitlesCount.
  ///
  /// In en, this message translates to:
  /// **'Distinct titles'**
  String get exportStatBookTitlesCount;

  /// No description provided for @exportStatTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total users'**
  String get exportStatTotalUsers;

  /// No description provided for @exportStatTotalCopiesQty.
  ///
  /// In en, this message translates to:
  /// **'Total copies (quantity)'**
  String get exportStatTotalCopiesQty;

  /// No description provided for @exportStatTotalAvailableStock.
  ///
  /// In en, this message translates to:
  /// **'Total in stock (available)'**
  String get exportStatTotalAvailableStock;

  /// No description provided for @exportStatBorrowsInPeriodBorrowDate.
  ///
  /// In en, this message translates to:
  /// **'Borrows in period (borrowDate)'**
  String get exportStatBorrowsInPeriodBorrowDate;

  /// No description provided for @exportStatActiveTicketsSystemWide.
  ///
  /// In en, this message translates to:
  /// **'Active borrow records (system-wide)'**
  String get exportStatActiveTicketsSystemWide;

  /// No description provided for @exportStatPeriodBorrowingReturnedLate.
  ///
  /// In en, this message translates to:
  /// **'In period — borrowing / returned / late'**
  String get exportStatPeriodBorrowingReturnedLate;

  /// No description provided for @exportStatOnTimeReturnEstimate.
  ///
  /// In en, this message translates to:
  /// **'On-time return rate (estimate)'**
  String get exportStatOnTimeReturnEstimate;

  /// No description provided for @exportStatAvgBorrowDaysReturned.
  ///
  /// In en, this message translates to:
  /// **'Avg. borrow days (returned)'**
  String get exportStatAvgBorrowDaysReturned;

  /// No description provided for @exportStatSectionTopBorrowedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Most borrowed (period)'**
  String get exportStatSectionTopBorrowedPeriod;

  /// No description provided for @exportColRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get exportColRank;

  /// No description provided for @exportColBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book title'**
  String get exportColBookTitle;

  /// No description provided for @exportColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exportColCategory;

  /// No description provided for @exportColBorrowsShort.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get exportColBorrowsShort;

  /// No description provided for @exportColBorrowCountLong.
  ///
  /// In en, this message translates to:
  /// **'Borrows'**
  String get exportColBorrowCountLong;

  /// No description provided for @exportExcelColId.
  ///
  /// In en, this message translates to:
  /// **'id'**
  String get exportExcelColId;

  /// No description provided for @exportExcelColTitle.
  ///
  /// In en, this message translates to:
  /// **'title'**
  String get exportExcelColTitle;

  /// No description provided for @exportExcelColAuthor.
  ///
  /// In en, this message translates to:
  /// **'author'**
  String get exportExcelColAuthor;

  /// No description provided for @exportExcelColCategoryField.
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get exportExcelColCategoryField;

  /// No description provided for @exportExcelColQuantity.
  ///
  /// In en, this message translates to:
  /// **'quantity'**
  String get exportExcelColQuantity;

  /// No description provided for @exportExcelColAvailableQuantity.
  ///
  /// In en, this message translates to:
  /// **'availableQuantity'**
  String get exportExcelColAvailableQuantity;

  /// No description provided for @exportExcelColBorrowId.
  ///
  /// In en, this message translates to:
  /// **'id'**
  String get exportExcelColBorrowId;

  /// No description provided for @exportExcelColBookId.
  ///
  /// In en, this message translates to:
  /// **'bookId'**
  String get exportExcelColBookId;

  /// No description provided for @exportExcelColUserId.
  ///
  /// In en, this message translates to:
  /// **'userId'**
  String get exportExcelColUserId;

  /// No description provided for @exportExcelColStatus.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get exportExcelColStatus;

  /// No description provided for @exportExcelColBorrowDate.
  ///
  /// In en, this message translates to:
  /// **'borrowDate'**
  String get exportExcelColBorrowDate;

  /// No description provided for @exportExcelColDueDate.
  ///
  /// In en, this message translates to:
  /// **'dueDate'**
  String get exportExcelColDueDate;

  /// No description provided for @exportExcelColReturnDate.
  ///
  /// In en, this message translates to:
  /// **'returnDate'**
  String get exportExcelColReturnDate;

  /// No description provided for @exportExcelColBookTitleSnapshot.
  ///
  /// In en, this message translates to:
  /// **'bookTitleSnapshot'**
  String get exportExcelColBookTitleSnapshot;

  /// No description provided for @exportExcelColDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get exportExcelColDisplayName;

  /// No description provided for @exportExcelColBorrowsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Borrows (period)'**
  String get exportExcelColBorrowsInPeriod;

  /// No description provided for @exportExcelColAuthorName.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get exportExcelColAuthorName;

  /// No description provided for @exportExcelColAuthorBorrowsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Borrows in period'**
  String get exportExcelColAuthorBorrowsInPeriod;

  /// No description provided for @exportExcelEncodeError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the Excel file.'**
  String get exportExcelEncodeError;

  /// No description provided for @exportPdfTopBooksInRange.
  ///
  /// In en, this message translates to:
  /// **'Top borrowed books (in range)'**
  String get exportPdfTopBooksInRange;

  /// No description provided for @exportPdfNoTableData.
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get exportPdfNoTableData;

  /// No description provided for @exportPdfBorrowRecordsLimited.
  ///
  /// In en, this message translates to:
  /// **'Borrow records (showing {cap} of {total})'**
  String exportPdfBorrowRecordsLimited(Object cap, Object total);

  /// No description provided for @exportPdfNoBorrowRecordsInRange.
  ///
  /// In en, this message translates to:
  /// **'No borrow records in this range.'**
  String get exportPdfNoBorrowRecordsInRange;

  /// No description provided for @exportPdfColTicketId.
  ///
  /// In en, this message translates to:
  /// **'Record ID'**
  String get exportPdfColTicketId;

  /// No description provided for @exportPdfColBookId.
  ///
  /// In en, this message translates to:
  /// **'bookId'**
  String get exportPdfColBookId;

  /// No description provided for @exportPdfColUserId.
  ///
  /// In en, this message translates to:
  /// **'userId'**
  String get exportPdfColUserId;

  /// No description provided for @exportPdfColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get exportPdfColStatus;

  /// No description provided for @exportPdfColBorrowDate.
  ///
  /// In en, this message translates to:
  /// **'Borrow date'**
  String get exportPdfColBorrowDate;

  /// No description provided for @exportPdfColDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get exportPdfColDueDate;

  /// No description provided for @exportPdfPeriodBorrowReturnLate.
  ///
  /// In en, this message translates to:
  /// **'Period: borrowing / returned / late'**
  String get exportPdfPeriodBorrowReturnLate;

  /// No description provided for @manageAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get manageAuthors;

  /// No description provided for @manageGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get manageGenres;

  /// No description provided for @manageStationery.
  ///
  /// In en, this message translates to:
  /// **'Stationery'**
  String get manageStationery;

  /// No description provided for @manageLibraryConfig.
  ///
  /// In en, this message translates to:
  /// **'Loan rules & limits'**
  String get manageLibraryConfig;

  /// No description provided for @manageAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get manageAuditLog;

  /// No description provided for @webAdminSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get webAdminSettingsSection;

  /// No description provided for @libraryBusinessSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Library business settings'**
  String get libraryBusinessSettingsTitle;

  /// No description provided for @libraryBusinessSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default loan period hint and maximum concurrent borrows per user.'**
  String get libraryBusinessSettingsSubtitle;

  /// No description provided for @libraryConfigLoanDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested loan days (for new borrows)'**
  String get libraryConfigLoanDaysLabel;

  /// No description provided for @libraryConfigLoanDaysHelper.
  ///
  /// In en, this message translates to:
  /// **'Recommended range: {min}–{max} days (used as default due date).'**
  String libraryConfigLoanDaysHelper(Object min, Object max);

  /// No description provided for @libraryConfigMaxBorrowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max concurrent borrows per user'**
  String get libraryConfigMaxBorrowsLabel;

  /// No description provided for @libraryConfigMaxBorrowsHelper.
  ///
  /// In en, this message translates to:
  /// **'A user cannot borrow another book if they already have this many active loans.'**
  String get libraryConfigMaxBorrowsHelper;

  /// No description provided for @libraryConfigSave.
  ///
  /// In en, this message translates to:
  /// **'Save configuration'**
  String get libraryConfigSave;

  /// No description provided for @libraryConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get libraryConfigSaved;

  /// No description provided for @libraryConfigSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String libraryConfigSaveError(Object error);

  /// No description provided for @libraryConfigLoanDaysInvalid.
  ///
  /// In en, this message translates to:
  /// **'Loan days must be within the suggested range.'**
  String get libraryConfigLoanDaysInvalid;

  /// No description provided for @libraryConfigMaxBorrowsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Max concurrent borrows must be between 1 and 99.'**
  String get libraryConfigMaxBorrowsInvalid;

  /// No description provided for @adminOnlyLibraryConfig.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can change these settings.'**
  String get adminOnlyLibraryConfig;

  /// No description provided for @auditLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get auditLogTitle;

  /// No description provided for @auditLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No log entries yet.'**
  String get auditLogEmpty;

  /// No description provided for @auditLogAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can view the activity log.'**
  String get auditLogAdminOnly;

  /// No description provided for @auditLogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load log: {error}'**
  String auditLogLoadError(Object error);

  /// No description provided for @authorsManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get authorsManageTitle;

  /// No description provided for @staffOnlyAuthorManage.
  ///
  /// In en, this message translates to:
  /// **'Only staff can manage authors.'**
  String get staffOnlyAuthorManage;

  /// No description provided for @authorsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load authors: {error}'**
  String authorsLoadError(Object error);

  /// No description provided for @authorsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No authors yet.'**
  String get authorsEmpty;

  /// No description provided for @authorsAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first author'**
  String get authorsAddFirst;

  /// No description provided for @authorsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add author'**
  String get authorsAdd;

  /// No description provided for @authorsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New author'**
  String get authorsAddTitle;

  /// No description provided for @authorsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit author'**
  String get authorsEditTitle;

  /// No description provided for @authorsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authorsNameLabel;

  /// No description provided for @authorsDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get authorsDescLabel;

  /// No description provided for @authorsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get authorsNameRequired;

  /// No description provided for @authorsAdded.
  ///
  /// In en, this message translates to:
  /// **'Author added: {name}'**
  String authorsAdded(Object name);

  /// No description provided for @authorsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Author updated.'**
  String get authorsUpdated;

  /// No description provided for @authorsUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get authorsUntitled;

  /// No description provided for @authorsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete author?'**
  String get authorsDeleteTitle;

  /// No description provided for @authorsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? Books referencing this name are not deleted.'**
  String authorsDeleteBody(Object name);

  /// No description provided for @authorsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Author removed.'**
  String get authorsDeleted;

  /// No description provided for @authorsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String authorsDeleteError(Object error);

  /// No description provided for @genresManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genresManageTitle;

  /// No description provided for @staffOnlyGenreManage.
  ///
  /// In en, this message translates to:
  /// **'Only staff can manage genres.'**
  String get staffOnlyGenreManage;

  /// No description provided for @genresLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load genres: {error}'**
  String genresLoadError(Object error);

  /// No description provided for @genresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No genres yet.'**
  String get genresEmpty;

  /// No description provided for @genresAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first genre'**
  String get genresAddFirst;

  /// No description provided for @genresAdd.
  ///
  /// In en, this message translates to:
  /// **'Add genre'**
  String get genresAdd;

  /// No description provided for @genresAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New genre'**
  String get genresAddTitle;

  /// No description provided for @genresEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename genre'**
  String get genresEditTitle;

  /// No description provided for @genresNameHint.
  ///
  /// In en, this message translates to:
  /// **'Genre name'**
  String get genresNameHint;

  /// No description provided for @genresNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get genresNameRequired;

  /// No description provided for @genresAdded.
  ///
  /// In en, this message translates to:
  /// **'Genre added: {name}'**
  String genresAdded(Object name);

  /// No description provided for @genresUpdated.
  ///
  /// In en, this message translates to:
  /// **'Genre updated.'**
  String get genresUpdated;

  /// No description provided for @genresUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get genresUntitled;

  /// No description provided for @genresDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete genre?'**
  String get genresDeleteTitle;

  /// No description provided for @genresDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String genresDeleteBody(Object name);

  /// No description provided for @genresDeleted.
  ///
  /// In en, this message translates to:
  /// **'Genre removed.'**
  String get genresDeleted;

  /// No description provided for @genresDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String genresDeleteError(Object error);

  /// No description provided for @stationeryManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stationery'**
  String get stationeryManageTitle;

  /// No description provided for @staffOnlyStationeryManage.
  ///
  /// In en, this message translates to:
  /// **'Only staff can manage stationery.'**
  String get staffOnlyStationeryManage;

  /// No description provided for @stationeryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load items: {error}'**
  String stationeryLoadError(Object error);

  /// No description provided for @stationeryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stationery items yet.'**
  String get stationeryEmpty;

  /// No description provided for @stationeryAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first item'**
  String get stationeryAddFirst;

  /// No description provided for @stationeryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get stationeryAdd;

  /// No description provided for @stationeryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get stationeryAddTitle;

  /// No description provided for @stationeryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get stationeryEditTitle;

  /// No description provided for @stationeryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get stationeryNameLabel;

  /// No description provided for @stationeryQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get stationeryQuantityLabel;

  /// No description provided for @stationeryUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. box, pack)'**
  String get stationeryUnitLabel;

  /// No description provided for @stationeryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get stationeryNameRequired;

  /// No description provided for @stationeryQtyLine.
  ///
  /// In en, this message translates to:
  /// **'{qty} {unit}'**
  String stationeryQtyLine(Object qty, Object unit);

  /// No description provided for @stationeryAdded.
  ///
  /// In en, this message translates to:
  /// **'Item saved.'**
  String get stationeryAdded;

  /// No description provided for @stationeryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated.'**
  String get stationeryUpdated;

  /// No description provided for @stationeryUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get stationeryUntitled;

  /// No description provided for @stationeryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get stationeryDeleteTitle;

  /// No description provided for @stationeryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String stationeryDeleteBody(Object name);

  /// No description provided for @stationeryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item removed.'**
  String get stationeryDeleted;

  /// No description provided for @stationeryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String stationeryDeleteError(Object error);

  /// No description provided for @userManageStaffHintBody.
  ///
  /// In en, this message translates to:
  /// **'New accounts register in the mobile app. To grant Admin or Manager access: find the user here and change their role. Creating Firebase Auth users for staff must be done in Firebase Console or via backend if needed.'**
  String get userManageStaffHintBody;

  /// No description provided for @userManageChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get userManageChangeRole;

  /// No description provided for @userManagePickRole.
  ///
  /// In en, this message translates to:
  /// **'Assign role'**
  String get userManagePickRole;

  /// No description provided for @userManageRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role updated.'**
  String get userManageRoleChanged;

  /// No description provided for @userManageRoleError.
  ///
  /// In en, this message translates to:
  /// **'Could not update role: {error}'**
  String userManageRoleError(Object error);

  /// No description provided for @userManageCannotRemoveLastAdmin.
  ///
  /// In en, this message translates to:
  /// **'There must be at least one administrator.'**
  String get userManageCannotRemoveLastAdmin;

  /// No description provided for @userManageCannotLockSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot deactivate your own account here.'**
  String get userManageCannotLockSelf;

  /// No description provided for @borrowSameBookAlready.
  ///
  /// In en, this message translates to:
  /// **'This user already has an active loan for this book.'**
  String get borrowSameBookAlready;

  /// No description provided for @borrowMaxActiveReached.
  ///
  /// In en, this message translates to:
  /// **'This user already has the maximum concurrent borrows ({max}).'**
  String borrowMaxActiveReached(Object max);

  /// No description provided for @brErrMaxActiveBorrows.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum number of concurrent borrows.'**
  String get brErrMaxActiveBorrows;

  /// No description provided for @scanBookUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled book)'**
  String get scanBookUntitled;

  /// No description provided for @scanBookRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {avail}/{qty}'**
  String scanBookRemaining(Object avail, Object qty);

  /// No description provided for @webDeskUntitledBook.
  ///
  /// In en, this message translates to:
  /// **'(No title)'**
  String get webDeskUntitledBook;

  /// No description provided for @webDeskRemainingIsbn.
  ///
  /// In en, this message translates to:
  /// **'Remaining {avail} / {qty} • ISBN: {isbn}'**
  String webDeskRemainingIsbn(Object avail, Object qty, Object isbn);

  /// No description provided for @userFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get userFilterAll;

  /// No description provided for @userFilterAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get userFilterAdmin;

  /// No description provided for @userFilterManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get userFilterManager;

  /// No description provided for @userFilterStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get userFilterStudent;

  /// No description provided for @brErrBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get brErrBookNotFound;

  /// No description provided for @brErrInvalidBookData.
  ///
  /// In en, this message translates to:
  /// **'Invalid book data'**
  String get brErrInvalidBookData;

  /// No description provided for @brErrOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'No copies available'**
  String get brErrOutOfStock;

  /// No description provided for @brErrAlreadyBorrowing.
  ///
  /// In en, this message translates to:
  /// **'You are already borrowing this book'**
  String get brErrAlreadyBorrowing;

  /// No description provided for @brErrNoActiveBorrow.
  ///
  /// In en, this message translates to:
  /// **'No active borrow record found'**
  String get brErrNoActiveBorrow;

  /// No description provided for @notifBorrowSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow successful'**
  String get notifBorrowSuccessTitle;

  /// No description provided for @notifBorrowSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{title} — due {due}'**
  String notifBorrowSuccessBody(Object title, Object due);

  /// No description provided for @notifReturnLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Returned late'**
  String get notifReturnLateTitle;

  /// No description provided for @notifReturnOnTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get notifReturnOnTimeTitle;

  /// No description provided for @notifReturnLateBody.
  ///
  /// In en, this message translates to:
  /// **'{title} — {days} days late'**
  String notifReturnLateBody(Object title, Object days);

  /// No description provided for @notifReturnOnTimeBody.
  ///
  /// In en, this message translates to:
  /// **'{title} — thank you for returning on time'**
  String notifReturnOnTimeBody(Object title);

  /// No description provided for @notifReturnDeskBody.
  ///
  /// In en, this message translates to:
  /// **'{title} — return confirmed by staff'**
  String notifReturnDeskBody(Object title);

  /// No description provided for @forgotPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you used to register. If it exists in the system, we will send a password reset link.'**
  String get forgotPasswordIntro;

  /// No description provided for @notifLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications.\nIf you just deployed, create the composite index (userId + createdAt) from the link in the Firebase console.\n\n{error}'**
  String notifLoadFailed(Object error);

  /// No description provided for @notifEmptyStaff.
  ///
  /// In en, this message translates to:
  /// **'No notifications in the system yet.\nNotifications are created when books are borrowed or returned.'**
  String get notifEmptyStaff;

  /// No description provided for @notifEmptyStudent.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications yet.\nMessages appear when you borrow or return books.'**
  String get notifEmptyStudent;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @categoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories: {error}'**
  String categoryLoadFailed(Object error);

  /// No description provided for @categoryUntitled.
  ///
  /// In en, this message translates to:
  /// **'(Untitled)'**
  String get categoryUntitled;

  /// No description provided for @categoryUsedWhenAddingBooks.
  ///
  /// In en, this message translates to:
  /// **'Used when adding books (category field).'**
  String get categoryUsedWhenAddingBooks;

  /// No description provided for @categoryPermissionDeniedHint.
  ///
  /// In en, this message translates to:
  /// **'No write permission. In Firebase, open Firestore → users → your account and set field role to admin or manager (not only changing the role in this demo app).'**
  String get categoryPermissionDeniedHint;

  /// No description provided for @categoryErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String categoryErrorGeneric(Object error);

  /// No description provided for @webStaffAccountFallback.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get webStaffAccountFallback;

  /// No description provided for @myQrDefaultDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get myQrDefaultDisplayName;

  /// No description provided for @qrCreateEmptyPayload.
  ///
  /// In en, this message translates to:
  /// **'No content yet'**
  String get qrCreateEmptyPayload;

  /// No description provided for @qrCreateCatalogDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Library catalog'**
  String get qrCreateCatalogDefaultTitle;

  /// No description provided for @fineDemoTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'50,000 ₫'**
  String get fineDemoTotalAmount;

  /// No description provided for @fineDemoTotalExplanation.
  ///
  /// In en, this message translates to:
  /// **'5 days late × 10,000 ₫/day'**
  String get fineDemoTotalExplanation;

  /// No description provided for @fineDemoLineAmount.
  ///
  /// In en, this message translates to:
  /// **'20,000 ₫'**
  String get fineDemoLineAmount;

  /// No description provided for @fineDemoLineLateLabel.
  ///
  /// In en, this message translates to:
  /// **'2 days late'**
  String get fineDemoLineLateLabel;

  /// No description provided for @excelErrNoSheetRows.
  ///
  /// In en, this message translates to:
  /// **'The file has no sheet containing data rows.'**
  String get excelErrNoSheetRows;

  /// No description provided for @excelErrSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty sheet.'**
  String get excelErrSheetEmpty;

  /// No description provided for @excelErrReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read .xlsx file.\n• Primary reader: {primary}\n• Fallback reader: {fallback}\nHint: open in Microsoft Excel → File → Save As → Excel Workbook (.xlsx).'**
  String excelErrReadFailed(Object primary, Object fallback);

  /// No description provided for @excelErrReadFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Could not read .xlsx file: {error}. Try saving again as Excel (.xlsx) or re-export from Google Sheets.'**
  String excelErrReadFailedShort(Object error);

  /// No description provided for @excelErrHeaderRow.
  ///
  /// In en, this message translates to:
  /// **'Row 1 must include recognizable columns for book title (title / tieu de) and author (author / tac gia).'**
  String get excelErrHeaderRow;

  /// No description provided for @excelErrRowMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: missing book title'**
  String excelErrRowMissingTitle(Object row);

  /// No description provided for @excelErrRowMissingAuthor.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: missing author'**
  String excelErrRowMissingAuthor(Object row);

  /// No description provided for @excelErrRowInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: invalid quantity (minimum 1)'**
  String excelErrRowInvalidQuantity(Object row);

  /// No description provided for @excelErrNoValidRows.
  ///
  /// In en, this message translates to:
  /// **'No valid data rows (empty rows ignored).'**
  String get excelErrNoValidRows;

  /// No description provided for @excelErrEnsureCategory.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare categories or link genres/authors: {error}'**
  String excelErrEnsureCategory(Object error);

  /// No description provided for @excelSampleSheetName.
  ///
  /// In en, this message translates to:
  /// **'BookImport'**
  String get excelSampleSheetName;

  /// No description provided for @excelSampleColTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get excelSampleColTitle;

  /// No description provided for @excelSampleColAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get excelSampleColAuthor;

  /// No description provided for @excelSampleColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get excelSampleColCategory;

  /// No description provided for @excelSampleColGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get excelSampleColGenre;

  /// No description provided for @excelSampleColPublishedYear.
  ///
  /// In en, this message translates to:
  /// **'Published year'**
  String get excelSampleColPublishedYear;

  /// No description provided for @excelSampleColIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get excelSampleColIsbn;

  /// No description provided for @excelSampleColQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get excelSampleColQuantity;

  /// No description provided for @excelSampleColDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get excelSampleColDescription;

  /// No description provided for @excelTemplateFileName.
  ///
  /// In en, this message translates to:
  /// **'book_import_sample_5rows.xlsx'**
  String get excelTemplateFileName;

  /// No description provided for @pushChannelName.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get pushChannelName;

  /// No description provided for @pushChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Borrow, return and due date alerts'**
  String get pushChannelDescription;

  /// No description provided for @pushDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get pushDefaultTitle;

  /// No description provided for @pushFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get pushFallbackTitle;

  /// No description provided for @errorWidgetDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget build error (debug)'**
  String get errorWidgetDebugTitle;

  /// No description provided for @errorWidgetReleaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorWidgetReleaseTitle;

  /// No description provided for @errorWidgetDebugDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Details match the console — you can select and copy.'**
  String get errorWidgetDebugDetailHint;

  /// No description provided for @errorWidgetReleaseHint.
  ///
  /// In en, this message translates to:
  /// **'Please try again or contact an administrator.'**
  String get errorWidgetReleaseHint;

  /// No description provided for @errorNoStack.
  ///
  /// In en, this message translates to:
  /// **'(no stack trace)'**
  String get errorNoStack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

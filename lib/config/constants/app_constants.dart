class AppConstants {
  AppConstants._();

  // ============================================================
  // APP INFORMATION
  // ============================================================

  static const String appName = 'GYMORA FITNESS MANAGEMENT';
  static const String appShortName = 'GYMORA';
  static const String appTagline = 'STRONGER TOGETHER';
  static const String appVersion = '1.0.0';

  // ============================================================
  // ASSETS
  // ============================================================

  static const String baseImg = 'assets/images';
  static const String baseIcon = 'assets/icons';
  static const String baseAnimation = 'assets/animations';
  static const String baseVideo = 'assets/videos';

  // Images
  static const String logo = 'app_logo.png';
  static const String appLogo = 'app_logo.png';

  // Role Images
  static const String ownerImage = '$baseImg/owner.png';
  static const String trainerImage = '$baseImg/trainer.png';
  static const String clientImage = '$baseImg/client.png';

  // Icons
  static const String deleteIcon = '$baseIcon/delete.png';
  static const String scheduleIcon = '$baseIcon/schedule.png';
  static const String updateIcon = '$baseIcon/updated.png';

  // ============================================================
  // ROLE CONSTANTS
  // ============================================================

  static const String ownerRole = 'owner';
  static const String trainerRole = 'trainer';
  static const String clientRole = 'client';

  // Role display names
  static const String ownerLabel = 'Owner';
  static const String trainerLabel = 'Trainer';
  static const String clientLabel = 'Client';

  // ============================================================
  // API / NETWORK
  // ============================================================

  static const String baseUrl = '';

  // static const String socketBaseUrl = '';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ============================================================
  // GENERAL UI
  // ============================================================

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // ============================================================
  // SCREEN PADDING
  // ============================================================

  static const double screenPadding = 16.0;
  static const double screenPaddingSmall = 12.0;
  static const double screenPaddingLarge = 24.0;

  // ============================================================
  // SPACING
  // ============================================================

  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusXLarge = 18.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircular = 100.0;

  // Names used by screens
  static const double paddingSmall = smallPadding;
  static const double paddingMedium = mediumPadding;
  static const double paddingLarge = largePadding;
  static const double paddingXLarge = extraLargePadding;

  // Names used by screens
  static const double spacingXSmall = spacing4;
  static const double spacingSmall = spacing8;
  static const double spacingMedium = spacing16;
  static const double spacingLarge = spacing24;
  static const double spacingXLarge = spacing32;
  // Backward-compatible names
  static const double borderRadius = radiusMedium;
  static const double borderRadiusSmall = radiusSmall;
  static const double borderRadiusMedium = radiusMedium;
  static const double borderRadiusLarge = radiusLarge;
  static const double borderRadiusXLarge = radiusXLarge;

  // ============================================================
  // ICON SIZES
  // ============================================================

  static const double iconSizeXSmall = 14.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeXXLarge = 40.0;

  // ============================================================
  // AVATAR SIZES
  // ============================================================

  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 48.0;
  static const double avatarXLarge = 64.0;
  static const double avatarXXLarge = 80.0;

  // ============================================================
  // BUTTON SIZES
  // ============================================================

  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 46.0;
  static const double buttonHeightLarge = 52.0;
  static const double buttonHeightXLarge = 56.0;

  static const double buttonMinWidth = 120.0;

  // ============================================================
  // APP BAR
  // ============================================================

  static const double appBarHeight = 64.0;
  static const double appBarIconSize = 22.0;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  static const double bottomNavHeight = 68.0;
  static const double bottomNavIconSize = 22.0;

  // ============================================================
  // CARD
  // ============================================================

  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double cardElevation = 0.0;
  static const double cardBorderWidth = 1.0;

  // ============================================================
  // INPUT FIELDS
  // ============================================================

  static const double inputHeight = 52.0;
  static const double inputRadius = 12.0;
  static const double inputBorderWidth = 1.0;

  // ============================================================
  // DASHBOARD
  // ============================================================

  static const double dashboardHeaderHeight = 180.0;
  static const double dashboardCardRadius = 16.0;
  static const double dashboardGridSpacing = 12.0;

  // ============================================================
  // CHARTS
  // ============================================================

  static const double chartHeight = 180.0;
  static const double chartLineWidth = 2.5;
  static const double chartDotSize = 4.0;

  // ============================================================
  // ANIMATION
  // ============================================================

  static const Duration extraShortAnimation = Duration(milliseconds: 100);

  static const Duration shortAnimation = Duration(milliseconds: 200);

  static const Duration mediumAnimation = Duration(milliseconds: 300);

  static const Duration longAnimation = Duration(milliseconds: 500);

  static const Duration extraLongAnimation = Duration(milliseconds: 800);

  // ============================================================
  // SPLASH
  // ============================================================

  static const Duration splashDuration = Duration(milliseconds: 2500);

  // ============================================================
  // PAGINATION
  // ============================================================

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ============================================================
  // DATE / TIME
  // ============================================================

  static const String dateFormat = 'dd MMM yyyy';
  static const String shortDateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // ============================================================
  // WORKOUT
  // ============================================================

  static const String workoutBeginner = 'Beginner';
  static const String workoutIntermediate = 'Intermediate';
  static const String workoutAdvanced = 'Advanced';

  // ============================================================
  // MEMBERSHIP
  // ============================================================

  static const String basicPlan = 'Basic';
  static const String standardPlan = 'Standard';
  static const String premiumPlan = 'Premium';

  // ============================================================
  // COMMON STATUS
  // ============================================================

  static const String activeStatus = 'Active';
  static const String inactiveStatus = 'Inactive';
  static const String pendingStatus = 'Pending';
  static const String completedStatus = 'Completed';
  static const String cancelledStatus = 'Cancelled';

  // ============================================================
  // LOGGING
  // ============================================================

  static const bool enableLogging = true;
  static const bool enableConsoleLogging = true;
  static const bool enableColoredConsoleOutput = true;

  // Log Levels
  static const String logLevelDebug = 'DEBUG';
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';
  static const String logLevelFatal = 'FATAL';

  static const String defaultLogLevel = logLevelDebug;

  // Console Logging
  static const bool showTimestamp = true;
  static const bool showLogLevel = true;
  static const bool showSourceInfo = true;

  static const String timestampFormat = 'yyyy-MM-dd HH:mm:ss.SSS';

  // ============================================================
  // LOG CATEGORIES
  // ============================================================

  static const String logCategoryApi = 'API';
  static const String logCategoryAuth = 'AUTH';
  static const String logCategoryUI = 'UI';
  static const String logCategoryStorage = 'STORAGE';
  static const String logCategoryNetwork = 'NETWORK';
  static const String logCategoryGeneral = 'GENERAL';
}

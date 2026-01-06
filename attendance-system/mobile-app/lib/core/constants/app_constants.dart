/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Attendance';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.attendance.example.com',
  );

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // GPS Configuration
  static const double defaultAccuracyRadius = 100.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const double minimumAccuracy = 50.0; // meters

  // Token Configuration
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String companyConfigKey = 'company_config';

  // Biometric
  static const String biometricEnabledKey = 'biometric_enabled';

  // OTP Configuration
  static const int otpLength = 6;
  static const Duration otpResendInterval = Duration(seconds: 60);

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileExtensions = [
    'pdf',
    'doc',
    'docx',
    'png',
    'jpg',
    'jpeg',
  ];

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String arabicDateFormat = 'dd/MM/yyyy';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String attendanceBox = 'attendance_box';
  static const String cacheBox = 'cache_box';
}

/// API Endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/v1/auth/login';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String nafathInit = '/api/v1/auth/nafath/init';
  static const String nafathVerify = '/api/v1/auth/nafath/verify';
  static const String biometricRegister = '/api/v1/auth/biometric/register';
  static const String biometricLogin = '/api/v1/auth/biometric/login';

  // Attendance
  static const String checkIn = '/api/v1/attendance/check-in';
  static const String checkOut = '/api/v1/attendance/check-out';
  static const String todayStatus = '/api/v1/attendance/today';
  static const String history = '/api/v1/attendance/history';
  static const String reports = '/api/v1/attendance/reports';

  // Excuses
  static const String excuses = '/api/v1/excuses';
  static const String submitExcuse = '/api/v1/excuses/submit';

  // Vacation
  static const String vacations = '/api/v1/vacations';
  static const String applyVacation = '/api/v1/vacations/apply';
  static const String vacationBalance = '/api/v1/vacations/balance';

  // Clarification
  static const String clarifications = '/api/v1/clarifications';
  static const String respondClarification = '/api/v1/clarifications/respond';

  // Profile
  static const String profile = '/api/v1/profile';
  static const String updateProfile = '/api/v1/profile/update';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String markNotificationRead = '/api/v1/notifications/read';

  // Company Config
  static const String companyConfig = '/api/v1/company/config';
}

/// Asset Paths
class AssetPaths {
  AssetPaths._();

  // Images
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';

  // Icons
  static const String checkInIcon = 'assets/icons/check_in.svg';
  static const String checkOutIcon = 'assets/icons/check_out.svg';
  static const String locationIcon = 'assets/icons/location.svg';
  static const String fingerprintIcon = 'assets/icons/fingerprint.svg';
  static const String faceIdIcon = 'assets/icons/face_id.svg';
  static const String nafathIcon = 'assets/icons/nafath.svg';
}

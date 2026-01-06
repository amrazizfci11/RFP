import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid username or password',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Session expired. Please login again',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.otpInvalid() => const AuthFailure(
        message: 'Invalid OTP code',
        code: 'INVALID_OTP',
      );

  factory AuthFailure.otpExpired() => const AuthFailure(
        message: 'OTP code expired',
        code: 'OTP_EXPIRED',
      );

  factory AuthFailure.biometricNotAvailable() => const AuthFailure(
        message: 'Biometric authentication not available',
        code: 'BIOMETRIC_NOT_AVAILABLE',
      );

  factory AuthFailure.biometricNotEnrolled() => const AuthFailure(
        message: 'Biometric not set up on this device',
        code: 'BIOMETRIC_NOT_ENROLLED',
      );

  factory AuthFailure.nafathFailed() => const AuthFailure(
        message: 'Nafath authentication failed',
        code: 'NAFATH_FAILED',
      );
}

/// Location/GPS failures
class LocationFailure extends Failure {
  const LocationFailure({
    required super.message,
    super.code,
  });

  factory LocationFailure.permissionDenied() => const LocationFailure(
        message: 'Location permission denied',
        code: 'LOCATION_PERMISSION_DENIED',
      );

  factory LocationFailure.serviceDisabled() => const LocationFailure(
        message: 'Location services are disabled',
        code: 'LOCATION_SERVICE_DISABLED',
      );

  factory LocationFailure.outsideVicinity() => const LocationFailure(
        message: 'You are outside the allowed work location',
        code: 'OUTSIDE_VICINITY',
      );

  factory LocationFailure.lowAccuracy() => const LocationFailure(
        message: 'GPS accuracy is too low',
        code: 'LOW_GPS_ACCURACY',
      );

  factory LocationFailure.timeout() => const LocationFailure(
        message: 'Could not get location. Please try again',
        code: 'LOCATION_TIMEOUT',
      );
}

/// Attendance failures
class AttendanceFailure extends Failure {
  const AttendanceFailure({
    required super.message,
    super.code,
  });

  factory AttendanceFailure.alreadyCheckedIn() => const AttendanceFailure(
        message: 'You have already checked in today',
        code: 'ALREADY_CHECKED_IN',
      );

  factory AttendanceFailure.notCheckedIn() => const AttendanceFailure(
        message: 'You have not checked in yet',
        code: 'NOT_CHECKED_IN',
      );

  factory AttendanceFailure.alreadyCheckedOut() => const AttendanceFailure(
        message: 'You have already checked out today',
        code: 'ALREADY_CHECKED_OUT',
      );

  factory AttendanceFailure.outsideWorkingHours() => const AttendanceFailure(
        message: 'Outside of working hours',
        code: 'OUTSIDE_WORKING_HOURS',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// File handling failures
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });

  factory FileFailure.sizeTooLarge() => const FileFailure(
        message: 'File size exceeds the limit',
        code: 'FILE_SIZE_EXCEEDED',
      );

  factory FileFailure.invalidType() => const FileFailure(
        message: 'Invalid file type',
        code: 'INVALID_FILE_TYPE',
      );

  factory FileFailure.uploadFailed() => const FileFailure(
        message: 'Failed to upload file',
        code: 'UPLOAD_FAILED',
      );
}

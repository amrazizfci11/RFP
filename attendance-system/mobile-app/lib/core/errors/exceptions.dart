/// Base class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server-side exceptions
class ServerException extends AppException {
  final int? statusCode;
  final dynamic data;

  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
    this.data,
  });

  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ServerException(
          message: message ?? 'Bad request',
          code: 'BAD_REQUEST',
          statusCode: statusCode,
        );
      case 401:
        return ServerException(
          message: message ?? 'Unauthorized',
          code: 'UNAUTHORIZED',
          statusCode: statusCode,
        );
      case 403:
        return ServerException(
          message: message ?? 'Forbidden',
          code: 'FORBIDDEN',
          statusCode: statusCode,
        );
      case 404:
        return ServerException(
          message: message ?? 'Not found',
          code: 'NOT_FOUND',
          statusCode: statusCode,
        );
      case 422:
        return ServerException(
          message: message ?? 'Validation error',
          code: 'VALIDATION_ERROR',
          statusCode: statusCode,
        );
      case 429:
        return ServerException(
          message: message ?? 'Too many requests',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
        );
      case 500:
        return ServerException(
          message: message ?? 'Internal server error',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
      case 502:
        return ServerException(
          message: message ?? 'Bad gateway',
          code: 'BAD_GATEWAY',
          statusCode: statusCode,
        );
      case 503:
        return ServerException(
          message: message ?? 'Service unavailable',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: message ?? 'An error occurred',
          code: 'UNKNOWN_ERROR',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() =>
      'ServerException: $message (statusCode: $statusCode, code: $code)';
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache/Local storage exceptions
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid username or password',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthException.sessionExpired() => const AuthException(
        message: 'Session expired',
        code: 'SESSION_EXPIRED',
      );

  factory AuthException.unauthorized() => const AuthException(
        message: 'Unauthorized access',
        code: 'UNAUTHORIZED',
      );
}

/// Location exceptions
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
  });

  factory LocationException.permissionDenied() => const LocationException(
        message: 'Location permission denied',
        code: 'PERMISSION_DENIED',
      );

  factory LocationException.serviceDisabled() => const LocationException(
        message: 'Location service disabled',
        code: 'SERVICE_DISABLED',
      );
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

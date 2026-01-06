import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with Iqama/username and password
  Future<Either<Failure, AuthResult>> login({
    required String identifier,
    required String password,
  });

  /// Verify OTP code
  Future<Either<Failure, AuthResult>> verifyOtp({
    required String requestId,
    required String otp,
  });

  /// Resend OTP
  Future<Either<Failure, String>> resendOtp({
    required String requestId,
  });

  /// Login with biometric
  Future<Either<Failure, AuthResult>> loginWithBiometric();

  /// Register biometric for current user
  Future<Either<Failure, bool>> registerBiometric();

  /// Check if biometric is available on device
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Check if biometric is registered for current user
  Future<Either<Failure, bool>> isBiometricRegistered();

  /// Initialize Nafath authentication
  Future<Either<Failure, NafathSession>> initNafathAuth();

  /// Verify Nafath authentication
  Future<Either<Failure, AuthResult>> verifyNafathAuth({
    required String transactionId,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Refresh tokens
  Future<Either<Failure, AuthTokens>> refreshTokens();

  /// Update FCM token
  Future<Either<Failure, void>> updateFcmToken(String token);
}

/// Nafath session for authentication
class NafathSession {
  final String transactionId;
  final String random;
  final DateTime expiresAt;

  const NafathSession({
    required this.transactionId,
    required this.random,
    required this.expiresAt,
  });
}

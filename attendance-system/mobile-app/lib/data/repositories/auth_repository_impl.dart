import 'package:dartz/dartz.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(identifier, password);
      if (!result.requiresOtp) {
        await localDataSource.cacheUser(result.user);
        await localDataSource.cacheTokens(result.tokens);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyOtp(requestId, otp);
      await localDataSource.cacheUser(result.user);
      await localDataSource.cacheTokens(result.tokens);
      return Right(result);
    } on ServerException catch (e) {
      if (e.statusCode == 400) {
        return Left(AuthFailure.otpInvalid());
      }
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resendOtp({required String requestId}) async {
    try {
      final newRequestId = await remoteDataSource.resendOtp(requestId);
      return Right(newRequestId);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> loginWithBiometric() async {
    try {
      // Check if biometric is available
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return Left(AuthFailure.biometricNotAvailable());
      }

      // Authenticate with biometric
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        return Left(const AuthFailure(
          message: 'Biometric authentication failed',
          code: 'BIOMETRIC_FAILED',
        ));
      }

      // Get stored tokens and refresh
      final tokens = await localDataSource.getCachedTokens();
      if (tokens == null) {
        return Left(AuthFailure.sessionExpired());
      }

      final newTokens = await remoteDataSource.refreshTokens(tokens.refreshToken);
      await localDataSource.cacheTokens(newTokens);

      final user = await localDataSource.getCachedUser();
      if (user == null) {
        return Left(AuthFailure.sessionExpired());
      }

      return Right(AuthResult(user: user, tokens: newTokens));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return Left(AuthFailure.biometricNotAvailable());
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        return const Right(false);
      }

      await localDataSource.setBiometricEnabled(true);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return Right(canCheck && isDeviceSupported);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricRegistered() async {
    try {
      final isEnabled = await localDataSource.isBiometricEnabled();
      return Right(isEnabled);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, NafathSession>> initNafathAuth() async {
    try {
      final session = await remoteDataSource.initNafathAuth();
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyNafathAuth({
    required String transactionId,
  }) async {
    try {
      final result = await remoteDataSource.verifyNafathAuth(transactionId);
      await localDataSource.cacheUser(result.user);
      await localDataSource.cacheTokens(result.tokens);
      return Right(result);
    } on ServerException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 404) {
        return Left(AuthFailure.nafathFailed());
      }
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Clear local data even if remote logout fails
      await localDataSource.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokens() async {
    try {
      final tokens = await localDataSource.getCachedTokens();
      if (tokens == null) {
        return Left(AuthFailure.sessionExpired());
      }

      final newTokens = await remoteDataSource.refreshTokens(tokens.refreshToken);
      await localDataSource.cacheTokens(newTokens);
      return Right(newTokens);
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await localDataSource.clearAll();
        return Left(AuthFailure.sessionExpired());
      }
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await remoteDataSource.updateFcmToken(token);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Biometric login use case
class BiometricLoginUseCase {
  final AuthRepository _repository;

  BiometricLoginUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call() {
    return _repository.loginWithBiometric();
  }

  Future<Either<Failure, bool>> isAvailable() {
    return _repository.isBiometricAvailable();
  }

  Future<Either<Failure, bool>> isRegistered() {
    return _repository.isBiometricRegistered();
  }

  Future<Either<Failure, bool>> register() {
    return _repository.registerBiometric();
  }
}

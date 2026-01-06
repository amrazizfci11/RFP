import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Nafath login use case
class NafathLoginUseCase {
  final AuthRepository _repository;

  NafathLoginUseCase(this._repository);

  /// Initialize Nafath authentication
  Future<Either<Failure, NafathSession>> initiate() {
    return _repository.initNafathAuth();
  }

  /// Verify Nafath authentication
  Future<Either<Failure, AuthResult>> verify(NafathVerifyParams params) {
    return _repository.verifyNafathAuth(
      transactionId: params.transactionId,
    );
  }
}

/// Nafath verify parameters
class NafathVerifyParams extends Equatable {
  final String transactionId;

  const NafathVerifyParams({
    required this.transactionId,
  });

  @override
  List<Object?> get props => [transactionId];
}

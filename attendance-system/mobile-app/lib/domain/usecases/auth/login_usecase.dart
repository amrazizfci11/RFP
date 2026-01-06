import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(LoginParams params) {
    return _repository.login(
      identifier: params.identifier,
      password: params.password,
    );
  }
}

/// Login parameters
class LoginParams extends Equatable {
  final String identifier; // Iqama or username
  final String password;

  const LoginParams({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}

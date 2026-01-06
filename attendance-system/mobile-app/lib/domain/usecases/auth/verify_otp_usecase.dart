import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Verify OTP use case
class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      requestId: params.requestId,
      otp: params.otp,
    );
  }
}

/// Verify OTP parameters
class VerifyOtpParams extends Equatable {
  final String requestId;
  final String otp;

  const VerifyOtpParams({
    required this.requestId,
    required this.otp,
  });

  @override
  List<Object?> get props => [requestId, otp];
}

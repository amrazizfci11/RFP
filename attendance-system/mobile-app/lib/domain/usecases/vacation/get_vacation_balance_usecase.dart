import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/vacation.dart';
import '../../repositories/vacation_repository.dart';

/// Get vacation balance use case
class GetVacationBalanceUseCase {
  final VacationRepository _repository;

  GetVacationBalanceUseCase(this._repository);

  Future<Either<Failure, VacationBalance>> call() {
    return _repository.getBalance();
  }
}

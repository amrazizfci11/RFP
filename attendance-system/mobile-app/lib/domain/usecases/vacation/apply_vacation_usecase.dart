import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/vacation.dart';
import '../../repositories/vacation_repository.dart';

/// Apply vacation use case
class ApplyVacationUseCase {
  final VacationRepository _repository;

  ApplyVacationUseCase(this._repository);

  Future<Either<Failure, Vacation>> call(VacationRequest request) {
    return _repository.applyVacation(request: request);
  }
}

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/excuse.dart';
import '../../repositories/excuse_repository.dart';

/// Submit excuse use case
class SubmitExcuseUseCase {
  final ExcuseRepository _repository;

  SubmitExcuseUseCase(this._repository);

  Future<Either<Failure, Excuse>> call(ExcuseRequest request) {
    return _repository.submitExcuse(request: request);
  }
}

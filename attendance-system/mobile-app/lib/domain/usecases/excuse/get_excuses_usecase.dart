import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/excuse.dart';
import '../../repositories/excuse_repository.dart';

/// Get excuses use case
class GetExcusesUseCase {
  final ExcuseRepository _repository;

  GetExcusesUseCase(this._repository);

  Future<Either<Failure, List<Excuse>>> call(GetExcusesParams params) {
    return _repository.getExcuses(
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Get excuses parameters
class GetExcusesParams extends Equatable {
  final ExcuseStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int pageSize;

  const GetExcusesParams({
    this.status,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [status, startDate, endDate, page, pageSize];
}

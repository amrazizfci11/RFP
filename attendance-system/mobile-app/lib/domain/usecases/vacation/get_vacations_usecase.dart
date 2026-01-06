import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/vacation.dart';
import '../../repositories/vacation_repository.dart';

/// Get vacations use case
class GetVacationsUseCase {
  final VacationRepository _repository;

  GetVacationsUseCase(this._repository);

  Future<Either<Failure, List<Vacation>>> call(GetVacationsParams params) {
    return _repository.getVacations(
      status: params.status,
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Get vacations parameters
class GetVacationsParams extends Equatable {
  final VacationStatus? status;
  final VacationType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int pageSize;

  const GetVacationsParams({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [status, type, startDate, endDate, page, pageSize];
}

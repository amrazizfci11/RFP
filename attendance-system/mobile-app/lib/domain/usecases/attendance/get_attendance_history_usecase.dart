import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Get attendance history use case
class GetAttendanceHistoryUseCase {
  final AttendanceRepository _repository;

  GetAttendanceHistoryUseCase(this._repository);

  Future<Either<Failure, List<AttendanceRecord>>> call(HistoryParams params) {
    return _repository.getHistory(
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// History parameters
class HistoryParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int pageSize;

  const HistoryParams({
    this.startDate,
    this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [startDate, endDate, page, pageSize];
}

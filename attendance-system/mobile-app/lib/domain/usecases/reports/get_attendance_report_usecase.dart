import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/reports_repository.dart';

/// Get attendance report use case
class GetAttendanceReportUseCase {
  final ReportsRepository _repository;

  GetAttendanceReportUseCase(this._repository);

  Future<Either<Failure, AttendanceReport>> call(ReportParams params) {
    return _repository.getAttendanceReport(
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
      month: params.month,
      year: params.year,
    );
  }
}

/// Report parameters
class ReportParams extends Equatable {
  final ReportType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;

  const ReportParams({
    required this.type,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [type, startDate, endDate, month, year];
}

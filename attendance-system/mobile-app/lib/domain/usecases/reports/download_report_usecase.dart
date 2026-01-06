import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/reports_repository.dart';

/// Download report use case
class DownloadReportUseCase {
  final ReportsRepository _repository;

  DownloadReportUseCase(this._repository);

  Future<Either<Failure, String>> call(DownloadReportParams params) {
    return _repository.downloadReport(
      type: params.type,
      format: params.format,
      startDate: params.startDate,
      endDate: params.endDate,
      month: params.month,
      year: params.year,
    );
  }
}

/// Download report parameters
class DownloadReportParams extends Equatable {
  final ReportType type;
  final ReportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;

  const DownloadReportParams({
    required this.type,
    required this.format,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [type, format, startDate, endDate, month, year];
}

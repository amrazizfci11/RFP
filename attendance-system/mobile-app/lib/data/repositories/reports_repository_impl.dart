import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/remote/reports_remote_datasource.dart';

/// Implementation of ReportsRepository
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AttendanceReport>> getAttendanceReport({
    required ReportType type,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    try {
      final report = await remoteDataSource.getAttendanceReport(
        type: type,
        startDate: startDate,
        endDate: endDate,
        month: month,
        year: year,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadReport({
    required ReportType type,
    required ReportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    try {
      final filePath = await remoteDataSource.downloadReport(
        type: type,
        format: format,
        startDate: startDate,
        endDate: endDate,
        month: month,
        year: year,
      );
      return Right(filePath);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MonthlySummary>>> getMonthlySummaries({
    required int year,
  }) async {
    try {
      // Implementation would aggregate monthly data
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, YearlySummary>> getYearlySummary({
    required int year,
  }) async {
    try {
      // Implementation would aggregate yearly data
      return Right(YearlySummary(
        year: year,
        totalWorkingDays: 0,
        totalPresentDays: 0,
        totalAbsentDays: 0,
        totalLateDays: 0,
        totalVacationDays: 0,
        overallAttendancePercentage: 0,
        monthlyBreakdown: const [],
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

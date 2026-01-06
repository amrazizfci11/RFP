import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local/attendance_local_datasource.dart';
import '../datasources/remote/attendance_remote_datasource.dart';

/// Implementation of AttendanceRepository
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AttendanceRecord>> checkIn({
    required AttendanceAction action,
  }) async {
    try {
      final record = await remoteDataSource.checkIn(action);
      await localDataSource.cacheTodayAttendance(record);
      return Right(record);
    } on ServerException catch (e) {
      // Save for offline sync
      await localDataSource.saveOfflineAction(action, true);
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      await localDataSource.saveOfflineAction(action, true);
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecord>> checkOut({
    required AttendanceAction action,
  }) async {
    try {
      final record = await remoteDataSource.checkOut(action);
      await localDataSource.cacheTodayAttendance(record);
      return Right(record);
    } on ServerException catch (e) {
      await localDataSource.saveOfflineAction(action, false);
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      await localDataSource.saveOfflineAction(action, false);
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TodayAttendance>> getTodayStatus() async {
    try {
      final todayAttendance = await remoteDataSource.getTodayStatus();
      if (todayAttendance.record != null) {
        await localDataSource.cacheTodayAttendance(todayAttendance.record!);
      }
      return Right(todayAttendance);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      // Try to get cached data
      final cached = await localDataSource.getCachedTodayAttendance();
      if (cached != null) {
        // Return cached data with limited info
        return Right(TodayAttendance(
          record: cached,
          canCheckIn: false,
          canCheckOut: false,
          companyLocation: const CompanyLocation(
            latitude: 0,
            longitude: 0,
            radiusInMeters: 100,
            address: '',
          ),
          workSchedule: const WorkSchedule(
            checkInTime: TimeOfDay(hour: 8, minute: 0),
            checkOutTime: TimeOfDay(hour: 17, minute: 0),
            gracePeriod: Duration(minutes: 15),
            workingDays: [1, 2, 3, 4, 5],
          ),
          message: e.message,
        ));
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final records = await remoteDataSource.getHistory(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );
      if (page == 1) {
        await localDataSource.cacheAttendanceHistory(records);
      }
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      // Return cached data on network error
      if (page == 1) {
        final cached = await localDataSource.getCachedHistory();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceRecord?>> getByDate(DateTime date) async {
    try {
      final record = await remoteDataSource.getByDate(date);
      return Right(record);
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
  Future<Either<Failure, AttendanceSummary>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final summary = await remoteDataSource.getSummary(startDate, endDate);
      return Right(summary);
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
  Future<Either<Failure, bool>> validateLocation({
    required double latitude,
    required double longitude,
  }) async {
    // Location validation is done on the client side
    // using the company location from getTodayStatus
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getCachedHistory() async {
    try {
      final records = await localDataSource.getCachedHistory();
      return Right(records);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineActions() async {
    try {
      final actions = await localDataSource.getOfflineActions();

      for (final action in actions) {
        final attendanceAction = AttendanceAction(
          latitude: action['latitude'] as double,
          longitude: action['longitude'] as double,
          accuracy: action['accuracy'] as double,
          notes: action['notes'] as String?,
        );

        if (action['isCheckIn'] as bool) {
          await remoteDataSource.checkIn(attendanceAction);
        } else {
          await remoteDataSource.checkOut(attendanceAction);
        }
      }

      await localDataSource.clearOfflineActions();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

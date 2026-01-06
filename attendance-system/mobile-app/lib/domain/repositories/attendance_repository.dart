import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/attendance.dart';

/// Attendance repository interface
abstract class AttendanceRepository {
  /// Check in at current location
  Future<Either<Failure, AttendanceRecord>> checkIn({
    required AttendanceAction action,
  });

  /// Check out at current location
  Future<Either<Failure, AttendanceRecord>> checkOut({
    required AttendanceAction action,
  });

  /// Get today's attendance status
  Future<Either<Failure, TodayAttendance>> getTodayStatus();

  /// Get attendance history
  Future<Either<Failure, List<AttendanceRecord>>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Get attendance by date
  Future<Either<Failure, AttendanceRecord?>> getByDate(DateTime date);

  /// Get attendance summary for date range
  Future<Either<Failure, AttendanceSummary>> getSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Validate GPS location against company location
  Future<Either<Failure, bool>> validateLocation({
    required double latitude,
    required double longitude,
  });

  /// Get cached attendance records
  Future<Either<Failure, List<AttendanceRecord>>> getCachedHistory();

  /// Sync offline attendance actions
  Future<Either<Failure, void>> syncOfflineActions();
}

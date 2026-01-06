import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/attendance.dart';

/// Report type enum
enum ReportType {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// Report format enum
enum ReportFormat {
  pdf,
  excel,
}

/// Reports repository interface
abstract class ReportsRepository {
  /// Get attendance report data
  Future<Either<Failure, AttendanceReport>> getAttendanceReport({
    required ReportType type,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  });

  /// Download attendance report
  Future<Either<Failure, String>> downloadReport({
    required ReportType type,
    required ReportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  });

  /// Get monthly summary
  Future<Either<Failure, List<MonthlySummary>>> getMonthlySummaries({
    required int year,
  });

  /// Get yearly summary
  Future<Either<Failure, YearlySummary>> getYearlySummary({
    required int year,
  });
}

/// Attendance report data
class AttendanceReport {
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final AttendanceSummary summary;
  final List<AttendanceRecord> records;
  final List<DailyBreakdown>? dailyBreakdown;

  const AttendanceReport({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.records,
    this.dailyBreakdown,
  });
}

/// Daily breakdown for reports
class DailyBreakdown {
  final DateTime date;
  final AttendanceStatus status;
  final String? checkIn;
  final String? checkOut;
  final String? workingHours;
  final String? notes;

  const DailyBreakdown({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.workingHours,
    this.notes,
  });
}

/// Monthly summary
class MonthlySummary {
  final int month;
  final int year;
  final int workingDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final double attendancePercentage;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.attendancePercentage,
  });
}

/// Yearly summary
class YearlySummary {
  final int year;
  final int totalWorkingDays;
  final int totalPresentDays;
  final int totalAbsentDays;
  final int totalLateDays;
  final int totalVacationDays;
  final double overallAttendancePercentage;
  final List<MonthlySummary> monthlyBreakdown;

  const YearlySummary({
    required this.year,
    required this.totalWorkingDays,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.totalLateDays,
    required this.totalVacationDays,
    required this.overallAttendancePercentage,
    required this.monthlyBreakdown,
  });
}

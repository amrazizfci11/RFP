import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/repositories/reports_repository.dart';

/// Remote data source for reports
abstract class ReportsRemoteDataSource {
  Future<AttendanceReport> getAttendanceReport({
    required ReportType type,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  });
  Future<String> downloadReport({
    required ReportType type,
    required ReportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AttendanceReport> getAttendanceReport({
    required ReportType type,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.reports,
      queryParameters: {
        'type': type.name,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return _parseReport(data, type);
  }

  @override
  Future<String> downloadReport({
    required ReportType type,
    required ReportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'attendance_report_${DateTime.now().millisecondsSinceEpoch}.${format == ReportFormat.pdf ? 'pdf' : 'xlsx'}';
    final filePath = '${directory.path}/$fileName';

    await apiClient.downloadFile(
      '${ApiEndpoints.reports}/download',
      filePath,
    );

    return filePath;
  }

  AttendanceReport _parseReport(Map<String, dynamic> data, ReportType type) {
    final summaryData = data['summary'] as Map<String, dynamic>;
    final recordsData = data['records'] as List? ?? [];
    final breakdownData = data['daily_breakdown'] as List?;

    final summary = AttendanceSummary(
      totalWorkingDays: summaryData['total_working_days'] ?? 0,
      presentDays: summaryData['present_days'] ?? 0,
      absentDays: summaryData['absent_days'] ?? 0,
      lateDays: summaryData['late_days'] ?? 0,
      earlyLeaveDays: summaryData['early_leave_days'] ?? 0,
      vacationDays: summaryData['vacation_days'] ?? 0,
      excuseDays: summaryData['excuse_days'] ?? 0,
      totalWorkingHours:
          Duration(minutes: summaryData['total_working_minutes'] ?? 0),
      totalOvertime:
          Duration(minutes: summaryData['total_overtime_minutes'] ?? 0),
      attendancePercentage:
          (summaryData['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
    );

    final records = recordsData.map((r) {
      final record = r as Map<String, dynamic>;
      return AttendanceRecord(
        id: record['id'],
        employeeId: record['employee_id'],
        date: DateTime.parse(record['date']),
        checkInTime: record['check_in_time'] != null
            ? DateTime.parse(record['check_in_time'])
            : null,
        checkOutTime: record['check_out_time'] != null
            ? DateTime.parse(record['check_out_time'])
            : null,
        status: AttendanceStatus.values.firstWhere(
          (s) => s.name == record['status'],
          orElse: () => AttendanceStatus.absent,
        ),
        workingHours: record['working_minutes'] != null
            ? Duration(minutes: record['working_minutes'])
            : null,
      );
    }).toList();

    final breakdown = breakdownData?.map((d) {
      final day = d as Map<String, dynamic>;
      return DailyBreakdown(
        date: DateTime.parse(day['date']),
        status: AttendanceStatus.values.firstWhere(
          (s) => s.name == day['status'],
          orElse: () => AttendanceStatus.absent,
        ),
        checkIn: day['check_in'],
        checkOut: day['check_out'],
        workingHours: day['working_hours'],
        notes: day['notes'],
      );
    }).toList();

    return AttendanceReport(
      type: type,
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      summary: summary,
      records: records,
      dailyBreakdown: breakdown,
    );
  }
}

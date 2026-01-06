import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/attendance.dart';

/// Remote data source for attendance
abstract class AttendanceRemoteDataSource {
  Future<AttendanceRecord> checkIn(AttendanceAction action);
  Future<AttendanceRecord> checkOut(AttendanceAction action);
  Future<TodayAttendance> getTodayStatus();
  Future<List<AttendanceRecord>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });
  Future<AttendanceRecord?> getByDate(DateTime date);
  Future<AttendanceSummary> getSummary(DateTime startDate, DateTime endDate);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient apiClient;

  AttendanceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AttendanceRecord> checkIn(AttendanceAction action) async {
    final response = await apiClient.post(
      ApiEndpoints.checkIn,
      data: {
        'latitude': action.latitude,
        'longitude': action.longitude,
        'accuracy': action.accuracy,
        'notes': action.notes,
      },
    );

    return _parseAttendanceRecord(response.data as Map<String, dynamic>);
  }

  @override
  Future<AttendanceRecord> checkOut(AttendanceAction action) async {
    final response = await apiClient.post(
      ApiEndpoints.checkOut,
      data: {
        'latitude': action.latitude,
        'longitude': action.longitude,
        'accuracy': action.accuracy,
        'notes': action.notes,
      },
    );

    return _parseAttendanceRecord(response.data as Map<String, dynamic>);
  }

  @override
  Future<TodayAttendance> getTodayStatus() async {
    final response = await apiClient.get(ApiEndpoints.todayStatus);
    final data = response.data as Map<String, dynamic>;

    final recordData = data['record'] as Map<String, dynamic>?;
    final locationData = data['company_location'] as Map<String, dynamic>;
    final scheduleData = data['work_schedule'] as Map<String, dynamic>;

    return TodayAttendance(
      record: recordData != null ? _parseAttendanceRecord(recordData) : null,
      canCheckIn: data['can_check_in'] ?? false,
      canCheckOut: data['can_check_out'] ?? false,
      companyLocation: CompanyLocation(
        latitude: (locationData['latitude'] as num).toDouble(),
        longitude: (locationData['longitude'] as num).toDouble(),
        radiusInMeters: (locationData['radius'] as num).toDouble(),
        address: locationData['address'] ?? '',
        nationalAddress: locationData['national_address'],
      ),
      workSchedule: WorkSchedule(
        checkInTime: TimeOfDay(
          hour: scheduleData['check_in_hour'] ?? 8,
          minute: scheduleData['check_in_minute'] ?? 0,
        ),
        checkOutTime: TimeOfDay(
          hour: scheduleData['check_out_hour'] ?? 17,
          minute: scheduleData['check_out_minute'] ?? 0,
        ),
        gracePeriod: Duration(minutes: scheduleData['grace_period_minutes'] ?? 15),
        workingDays: List<int>.from(scheduleData['working_days'] ?? [1, 2, 3, 4, 5]),
      ),
      message: data['message'],
    );
  }

  @override
  Future<List<AttendanceRecord>> getHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.history,
      queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );

    final list = response.data['items'] as List;
    return list
        .map((e) => _parseAttendanceRecord(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceRecord?> getByDate(DateTime date) async {
    final response = await apiClient.get(
      '${ApiEndpoints.history}/${date.toIso8601String().split('T').first}',
    );

    if (response.data == null) return null;
    return _parseAttendanceRecord(response.data as Map<String, dynamic>);
  }

  @override
  Future<AttendanceSummary> getSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await apiClient.get(
      '${ApiEndpoints.reports}/summary',
      queryParameters: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    return AttendanceSummary(
      totalWorkingDays: data['total_working_days'] ?? 0,
      presentDays: data['present_days'] ?? 0,
      absentDays: data['absent_days'] ?? 0,
      lateDays: data['late_days'] ?? 0,
      earlyLeaveDays: data['early_leave_days'] ?? 0,
      vacationDays: data['vacation_days'] ?? 0,
      excuseDays: data['excuse_days'] ?? 0,
      totalWorkingHours: Duration(minutes: data['total_working_minutes'] ?? 0),
      totalOvertime: Duration(minutes: data['total_overtime_minutes'] ?? 0),
      attendancePercentage:
          (data['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  AttendanceRecord _parseAttendanceRecord(Map<String, dynamic> data) {
    return AttendanceRecord(
      id: data['id'],
      employeeId: data['employee_id'],
      date: DateTime.parse(data['date']),
      checkInTime: data['check_in_time'] != null
          ? DateTime.parse(data['check_in_time'])
          : null,
      checkOutTime: data['check_out_time'] != null
          ? DateTime.parse(data['check_out_time'])
          : null,
      checkInLatitude: data['check_in_latitude']?.toDouble(),
      checkInLongitude: data['check_in_longitude']?.toDouble(),
      checkOutLatitude: data['check_out_latitude']?.toDouble(),
      checkOutLongitude: data['check_out_longitude']?.toDouble(),
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      workingHours: data['working_minutes'] != null
          ? Duration(minutes: data['working_minutes'])
          : null,
      overtime: data['overtime_minutes'] != null
          ? Duration(minutes: data['overtime_minutes'])
          : null,
      notes: data['notes'],
      isLate: data['is_late'] ?? false,
      isEarlyLeave: data['is_early_leave'] ?? false,
      lateBy: data['late_by_minutes'] != null
          ? Duration(minutes: data['late_by_minutes'])
          : null,
      earlyBy: data['early_by_minutes'] != null
          ? Duration(minutes: data['early_by_minutes'])
          : null,
    );
  }
}

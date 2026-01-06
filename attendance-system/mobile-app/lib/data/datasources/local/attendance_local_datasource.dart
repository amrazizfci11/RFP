import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/attendance.dart';

/// Local data source for attendance
abstract class AttendanceLocalDataSource {
  Future<void> cacheTodayAttendance(AttendanceRecord record);
  Future<AttendanceRecord?> getCachedTodayAttendance();
  Future<void> cacheAttendanceHistory(List<AttendanceRecord> records);
  Future<List<AttendanceRecord>> getCachedHistory();
  Future<void> saveOfflineAction(AttendanceAction action, bool isCheckIn);
  Future<List<Map<String, dynamic>>> getOfflineActions();
  Future<void> clearOfflineActions();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  static const String _todayAttendanceKey = 'today_attendance';
  static const String _historyKey = 'attendance_history';
  static const String _offlineActionsKey = 'offline_actions';

  final SharedPreferences sharedPreferences;

  AttendanceLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheTodayAttendance(AttendanceRecord record) async {
    final json = jsonEncode(_recordToJson(record));
    await sharedPreferences.setString(_todayAttendanceKey, json);
  }

  @override
  Future<AttendanceRecord?> getCachedTodayAttendance() async {
    final json = sharedPreferences.getString(_todayAttendanceKey);
    if (json == null) return null;

    final data = jsonDecode(json) as Map<String, dynamic>;
    return _recordFromJson(data);
  }

  @override
  Future<void> cacheAttendanceHistory(List<AttendanceRecord> records) async {
    final json = jsonEncode(records.map(_recordToJson).toList());
    await sharedPreferences.setString(_historyKey, json);
  }

  @override
  Future<List<AttendanceRecord>> getCachedHistory() async {
    final json = sharedPreferences.getString(_historyKey);
    if (json == null) return [];

    final list = jsonDecode(json) as List;
    return list
        .map((e) => _recordFromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveOfflineAction(AttendanceAction action, bool isCheckIn) async {
    final actions = await getOfflineActions();
    actions.add({
      'latitude': action.latitude,
      'longitude': action.longitude,
      'accuracy': action.accuracy,
      'notes': action.notes,
      'isCheckIn': isCheckIn,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await sharedPreferences.setString(_offlineActionsKey, jsonEncode(actions));
  }

  @override
  Future<List<Map<String, dynamic>>> getOfflineActions() async {
    final json = sharedPreferences.getString(_offlineActionsKey);
    if (json == null) return [];

    final list = jsonDecode(json) as List;
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> clearOfflineActions() async {
    await sharedPreferences.remove(_offlineActionsKey);
  }

  Map<String, dynamic> _recordToJson(AttendanceRecord record) {
    return {
      'id': record.id,
      'employeeId': record.employeeId,
      'date': record.date.toIso8601String(),
      'checkInTime': record.checkInTime?.toIso8601String(),
      'checkOutTime': record.checkOutTime?.toIso8601String(),
      'checkInLatitude': record.checkInLatitude,
      'checkInLongitude': record.checkInLongitude,
      'checkOutLatitude': record.checkOutLatitude,
      'checkOutLongitude': record.checkOutLongitude,
      'status': record.status.name,
      'workingHours': record.workingHours?.inMinutes,
      'overtime': record.overtime?.inMinutes,
      'notes': record.notes,
      'isLate': record.isLate,
      'isEarlyLeave': record.isEarlyLeave,
      'lateBy': record.lateBy?.inMinutes,
      'earlyBy': record.earlyBy?.inMinutes,
    };
  }

  AttendanceRecord _recordFromJson(Map<String, dynamic> data) {
    return AttendanceRecord(
      id: data['id'],
      employeeId: data['employeeId'],
      date: DateTime.parse(data['date']),
      checkInTime: data['checkInTime'] != null
          ? DateTime.parse(data['checkInTime'])
          : null,
      checkOutTime: data['checkOutTime'] != null
          ? DateTime.parse(data['checkOutTime'])
          : null,
      checkInLatitude: data['checkInLatitude'],
      checkInLongitude: data['checkInLongitude'],
      checkOutLatitude: data['checkOutLatitude'],
      checkOutLongitude: data['checkOutLongitude'],
      status: AttendanceStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      workingHours: data['workingHours'] != null
          ? Duration(minutes: data['workingHours'])
          : null,
      overtime:
          data['overtime'] != null ? Duration(minutes: data['overtime']) : null,
      notes: data['notes'],
      isLate: data['isLate'] ?? false,
      isEarlyLeave: data['isEarlyLeave'] ?? false,
      lateBy:
          data['lateBy'] != null ? Duration(minutes: data['lateBy']) : null,
      earlyBy:
          data['earlyBy'] != null ? Duration(minutes: data['earlyBy']) : null,
    );
  }
}

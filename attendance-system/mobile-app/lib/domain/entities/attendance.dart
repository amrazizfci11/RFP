import 'package:equatable/equatable.dart';

/// Attendance status enum
enum AttendanceStatus {
  present,
  absent,
  late,
  earlyLeave,
  vacation,
  excuse,
  weekend,
  holiday,
}

/// Attendance record entity
class AttendanceRecord extends Equatable {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final AttendanceStatus status;
  final Duration? workingHours;
  final Duration? overtime;
  final String? notes;
  final bool isLate;
  final bool isEarlyLeave;
  final Duration? lateBy;
  final Duration? earlyBy;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    required this.status,
    this.workingHours,
    this.overtime,
    this.notes,
    this.isLate = false,
    this.isEarlyLeave = false,
    this.lateBy,
    this.earlyBy,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        date,
        checkInTime,
        checkOutTime,
        checkInLatitude,
        checkInLongitude,
        checkOutLatitude,
        checkOutLongitude,
        status,
        workingHours,
        overtime,
        notes,
        isLate,
        isEarlyLeave,
        lateBy,
        earlyBy,
      ];

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  String get formattedWorkingHours {
    if (workingHours == null) return '-';
    final hours = workingHours!.inHours;
    final minutes = workingHours!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

/// Today's attendance status
class TodayAttendance extends Equatable {
  final AttendanceRecord? record;
  final bool canCheckIn;
  final bool canCheckOut;
  final CompanyLocation companyLocation;
  final WorkSchedule workSchedule;
  final String? message;

  const TodayAttendance({
    this.record,
    required this.canCheckIn,
    required this.canCheckOut,
    required this.companyLocation,
    required this.workSchedule,
    this.message,
  });

  @override
  List<Object?> get props => [
        record,
        canCheckIn,
        canCheckOut,
        companyLocation,
        workSchedule,
        message,
      ];
}

/// Company location for GPS validation
class CompanyLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final String address;
  final String? nationalAddress;

  const CompanyLocation({
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.address,
    this.nationalAddress,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        radiusInMeters,
        address,
        nationalAddress,
      ];
}

/// Work schedule configuration
class WorkSchedule extends Equatable {
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;
  final Duration gracePeriod;
  final List<int> workingDays; // 1-7 (Monday-Sunday)

  const WorkSchedule({
    required this.checkInTime,
    required this.checkOutTime,
    required this.gracePeriod,
    required this.workingDays,
  });

  @override
  List<Object?> get props => [checkInTime, checkOutTime, gracePeriod, workingDays];

  bool isWorkingDay(DateTime date) {
    return workingDays.contains(date.weekday);
  }
}

/// Time of day representation
class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  List<Object?> get props => [hour, minute];

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

/// Check-in/Check-out request
class AttendanceAction extends Equatable {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? notes;

  const AttendanceAction({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.notes,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, notes];
}

/// Attendance summary for reports
class AttendanceSummary extends Equatable {
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int earlyLeaveDays;
  final int vacationDays;
  final int excuseDays;
  final Duration totalWorkingHours;
  final Duration totalOvertime;
  final double attendancePercentage;

  const AttendanceSummary({
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.earlyLeaveDays,
    required this.vacationDays,
    required this.excuseDays,
    required this.totalWorkingHours,
    required this.totalOvertime,
    required this.attendancePercentage,
  });

  @override
  List<Object?> get props => [
        totalWorkingDays,
        presentDays,
        absentDays,
        lateDays,
        earlyLeaveDays,
        vacationDays,
        excuseDays,
        totalWorkingHours,
        totalOvertime,
        attendancePercentage,
      ];
}

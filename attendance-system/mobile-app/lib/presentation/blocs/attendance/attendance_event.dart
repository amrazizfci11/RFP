part of 'attendance_bloc.dart';

/// Base attendance event
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's attendance status
class AttendanceLoadTodayRequested extends AttendanceEvent {
  const AttendanceLoadTodayRequested();
}

/// Check in
class AttendanceCheckInRequested extends AttendanceEvent {
  final String? notes;

  const AttendanceCheckInRequested({this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Check out
class AttendanceCheckOutRequested extends AttendanceEvent {
  final String? notes;

  const AttendanceCheckOutRequested({this.notes});

  @override
  List<Object?> get props => [notes];
}

/// Load attendance history
class AttendanceHistoryRequested extends AttendanceEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int pageSize;

  const AttendanceHistoryRequested({
    this.startDate,
    this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [startDate, endDate, page, pageSize];
}

/// Update current location
class AttendanceLocationUpdated extends AttendanceEvent {
  final double latitude;
  final double longitude;
  final double accuracy;

  const AttendanceLocationUpdated({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

/// Refresh attendance data
class AttendanceRefreshRequested extends AttendanceEvent {
  const AttendanceRefreshRequested();
}

part of 'attendance_bloc.dart';

/// Attendance action status
enum AttendanceActionStatus {
  idle,
  loading,
  checkingIn,
  checkedIn,
  checkingOut,
  checkedOut,
  error,
}

/// Attendance history status
enum AttendanceHistoryStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Attendance state
class AttendanceState extends Equatable {
  final AttendanceActionStatus status;
  final AttendanceHistoryStatus historyStatus;
  final TodayAttendance? todayAttendance;
  final List<AttendanceRecord> history;
  final bool hasMoreHistory;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? locationAccuracy;
  final bool isWithinVicinity;
  final bool canCheckIn;
  final bool canCheckOut;
  final String? error;

  const AttendanceState({
    this.status = AttendanceActionStatus.idle,
    this.historyStatus = AttendanceHistoryStatus.initial,
    this.todayAttendance,
    this.history = const [],
    this.hasMoreHistory = false,
    this.currentLatitude,
    this.currentLongitude,
    this.locationAccuracy,
    this.isWithinVicinity = false,
    this.canCheckIn = false,
    this.canCheckOut = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        historyStatus,
        todayAttendance,
        history,
        hasMoreHistory,
        currentLatitude,
        currentLongitude,
        locationAccuracy,
        isWithinVicinity,
        canCheckIn,
        canCheckOut,
        error,
      ];

  bool get isLoading => status == AttendanceActionStatus.loading;
  bool get isCheckingIn => status == AttendanceActionStatus.checkingIn;
  bool get isCheckingOut => status == AttendanceActionStatus.checkingOut;
  bool get hasCheckedIn => todayAttendance?.record?.hasCheckedIn ?? false;
  bool get hasCheckedOut => todayAttendance?.record?.hasCheckedOut ?? false;
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  AttendanceState copyWith({
    AttendanceActionStatus? status,
    AttendanceHistoryStatus? historyStatus,
    TodayAttendance? todayAttendance,
    List<AttendanceRecord>? history,
    bool? hasMoreHistory,
    double? currentLatitude,
    double? currentLongitude,
    double? locationAccuracy,
    bool? isWithinVicinity,
    bool? canCheckIn,
    bool? canCheckOut,
    String? error,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      historyStatus: historyStatus ?? this.historyStatus,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      history: history ?? this.history,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      isWithinVicinity: isWithinVicinity ?? this.isWithinVicinity,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      canCheckOut: canCheckOut ?? this.canCheckOut,
      error: error,
    );
  }
}

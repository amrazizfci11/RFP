import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/attendance.dart';
import '../../../domain/usecases/attendance/check_in_usecase.dart';
import '../../../domain/usecases/attendance/check_out_usecase.dart';
import '../../../domain/usecases/attendance/get_today_status_usecase.dart';
import '../../../domain/usecases/attendance/get_attendance_history_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

/// Attendance BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final GetTodayStatusUseCase getTodayStatusUseCase;
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  AttendanceBloc({
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.getTodayStatusUseCase,
    required this.getAttendanceHistoryUseCase,
  }) : super(const AttendanceState()) {
    on<AttendanceLoadTodayRequested>(_onLoadTodayRequested);
    on<AttendanceCheckInRequested>(_onCheckInRequested);
    on<AttendanceCheckOutRequested>(_onCheckOutRequested);
    on<AttendanceHistoryRequested>(_onHistoryRequested);
    on<AttendanceLocationUpdated>(_onLocationUpdated);
    on<AttendanceRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadTodayRequested(
    AttendanceLoadTodayRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceActionStatus.loading));

    final result = await getTodayStatusUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceActionStatus.error,
        error: failure.message,
      )),
      (todayAttendance) => emit(state.copyWith(
        status: AttendanceActionStatus.idle,
        todayAttendance: todayAttendance,
        canCheckIn: todayAttendance.canCheckIn,
        canCheckOut: todayAttendance.canCheckOut,
      )),
    );
  }

  Future<void> _onCheckInRequested(
    AttendanceCheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (!state.isWithinVicinity) {
      emit(state.copyWith(
        status: AttendanceActionStatus.error,
        error: 'You are outside the allowed work location',
      ));
      return;
    }

    emit(state.copyWith(status: AttendanceActionStatus.checkingIn));

    final action = AttendanceAction(
      latitude: state.currentLatitude!,
      longitude: state.currentLongitude!,
      accuracy: state.locationAccuracy ?? 0,
      notes: event.notes,
    );

    final result = await checkInUseCase(action);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceActionStatus.error,
        error: failure.message,
      )),
      (record) => emit(state.copyWith(
        status: AttendanceActionStatus.checkedIn,
        todayAttendance: state.todayAttendance?.copyWith(
          record: record,
          canCheckIn: false,
          canCheckOut: true,
        ),
        canCheckIn: false,
        canCheckOut: true,
      )),
    );
  }

  Future<void> _onCheckOutRequested(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (!state.isWithinVicinity) {
      emit(state.copyWith(
        status: AttendanceActionStatus.error,
        error: 'You are outside the allowed work location',
      ));
      return;
    }

    emit(state.copyWith(status: AttendanceActionStatus.checkingOut));

    final action = AttendanceAction(
      latitude: state.currentLatitude!,
      longitude: state.currentLongitude!,
      accuracy: state.locationAccuracy ?? 0,
      notes: event.notes,
    );

    final result = await checkOutUseCase(action);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AttendanceActionStatus.error,
        error: failure.message,
      )),
      (record) => emit(state.copyWith(
        status: AttendanceActionStatus.checkedOut,
        todayAttendance: state.todayAttendance?.copyWith(
          record: record,
          canCheckIn: false,
          canCheckOut: false,
        ),
        canCheckIn: false,
        canCheckOut: false,
      )),
    );
  }

  Future<void> _onHistoryRequested(
    AttendanceHistoryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(historyStatus: AttendanceHistoryStatus.loading));

    final params = HistoryParams(
      startDate: event.startDate,
      endDate: event.endDate,
      page: event.page,
      pageSize: event.pageSize,
    );

    final result = await getAttendanceHistoryUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        historyStatus: AttendanceHistoryStatus.error,
        error: failure.message,
      )),
      (records) => emit(state.copyWith(
        historyStatus: AttendanceHistoryStatus.loaded,
        history: event.page == 1 ? records : [...state.history, ...records],
        hasMoreHistory: records.length == event.pageSize,
      )),
    );
  }

  void _onLocationUpdated(
    AttendanceLocationUpdated event,
    Emitter<AttendanceState> emit,
  ) {
    final isWithinVicinity = _checkVicinity(
      event.latitude,
      event.longitude,
      state.todayAttendance?.companyLocation,
    );

    emit(state.copyWith(
      currentLatitude: event.latitude,
      currentLongitude: event.longitude,
      locationAccuracy: event.accuracy,
      isWithinVicinity: isWithinVicinity,
    ));
  }

  bool _checkVicinity(
    double lat,
    double lng,
    CompanyLocation? companyLocation,
  ) {
    if (companyLocation == null) return false;

    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      companyLocation.latitude,
      companyLocation.longitude,
    );

    return distance <= companyLocation.radiusInMeters;
  }

  Future<void> _onRefreshRequested(
    AttendanceRefreshRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    add(const AttendanceLoadTodayRequested());
  }
}

extension TodayAttendanceExtension on TodayAttendance {
  TodayAttendance copyWith({
    AttendanceRecord? record,
    bool? canCheckIn,
    bool? canCheckOut,
    CompanyLocation? companyLocation,
    WorkSchedule? workSchedule,
    String? message,
  }) {
    return TodayAttendance(
      record: record ?? this.record,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      canCheckOut: canCheckOut ?? this.canCheckOut,
      companyLocation: companyLocation ?? this.companyLocation,
      workSchedule: workSchedule ?? this.workSchedule,
      message: message ?? this.message,
    );
  }
}

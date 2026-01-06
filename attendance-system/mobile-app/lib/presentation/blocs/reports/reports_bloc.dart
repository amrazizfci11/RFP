import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/attendance.dart';
import '../../../domain/repositories/reports_repository.dart';
import '../../../domain/usecases/reports/get_attendance_report_usecase.dart';
import '../../../domain/usecases/reports/download_report_usecase.dart';

part 'reports_event.dart';
part 'reports_state.dart';

/// Reports BLoC
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetAttendanceReportUseCase getAttendanceReportUseCase;
  final DownloadReportUseCase downloadReportUseCase;

  ReportsBloc({
    required this.getAttendanceReportUseCase,
    required this.downloadReportUseCase,
  }) : super(const ReportsState()) {
    on<ReportsLoadRequested>(_onLoadRequested);
    on<ReportsDownloadRequested>(_onDownloadRequested);
    on<ReportsTypeChanged>(_onTypeChanged);
    on<ReportsDateRangeChanged>(_onDateRangeChanged);
  }

  Future<void> _onLoadRequested(
    ReportsLoadRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(status: ReportsStatus.loading));

    final params = ReportParams(
      type: state.reportType,
      startDate: state.startDate,
      endDate: state.endDate,
      month: state.month,
      year: state.year,
    );

    final result = await getAttendanceReportUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ReportsStatus.error,
        error: failure.message,
      )),
      (report) => emit(state.copyWith(
        status: ReportsStatus.loaded,
        report: report,
      )),
    );
  }

  Future<void> _onDownloadRequested(
    ReportsDownloadRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(downloadStatus: DownloadStatus.downloading));

    final params = DownloadReportParams(
      type: state.reportType,
      format: event.format,
      startDate: state.startDate,
      endDate: state.endDate,
      month: state.month,
      year: state.year,
    );

    final result = await downloadReportUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        downloadStatus: DownloadStatus.error,
        error: failure.message,
      )),
      (filePath) => emit(state.copyWith(
        downloadStatus: DownloadStatus.completed,
        downloadedFilePath: filePath,
      )),
    );
  }

  void _onTypeChanged(
    ReportsTypeChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(reportType: event.type));
    add(const ReportsLoadRequested());
  }

  void _onDateRangeChanged(
    ReportsDateRangeChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      month: event.month,
      year: event.year,
    ));
    add(const ReportsLoadRequested());
  }
}

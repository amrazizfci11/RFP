part of 'reports_bloc.dart';

enum ReportsStatus { initial, loading, loaded, error }

enum DownloadStatus { initial, downloading, completed, error }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final DownloadStatus downloadStatus;
  final AttendanceReport? report;
  final ReportType reportType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;
  final String? downloadedFilePath;
  final String? error;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.downloadStatus = DownloadStatus.initial,
    this.report,
    this.reportType = ReportType.monthly,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
    this.downloadedFilePath,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        downloadStatus,
        report,
        reportType,
        startDate,
        endDate,
        month,
        year,
        downloadedFilePath,
        error,
      ];

  ReportsState copyWith({
    ReportsStatus? status,
    DownloadStatus? downloadStatus,
    AttendanceReport? report,
    ReportType? reportType,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
    String? downloadedFilePath,
    String? error,
  }) {
    return ReportsState(
      status: status ?? this.status,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      report: report ?? this.report,
      reportType: reportType ?? this.reportType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      month: month ?? this.month,
      year: year ?? this.year,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      error: error,
    );
  }
}

part of 'reports_bloc.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class ReportsLoadRequested extends ReportsEvent {
  const ReportsLoadRequested();
}

class ReportsDownloadRequested extends ReportsEvent {
  final ReportFormat format;

  const ReportsDownloadRequested({required this.format});

  @override
  List<Object?> get props => [format];
}

class ReportsTypeChanged extends ReportsEvent {
  final ReportType type;

  const ReportsTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class ReportsDateRangeChanged extends ReportsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;

  const ReportsDateRangeChanged({
    this.startDate,
    this.endDate,
    this.month,
    this.year,
  });

  @override
  List<Object?> get props => [startDate, endDate, month, year];
}

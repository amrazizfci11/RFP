part of 'excuse_bloc.dart';

abstract class ExcuseEvent extends Equatable {
  const ExcuseEvent();

  @override
  List<Object?> get props => [];
}

class ExcuseListRequested extends ExcuseEvent {
  const ExcuseListRequested();
}

class ExcuseSubmitRequested extends ExcuseEvent {
  final ExcuseRequest request;

  const ExcuseSubmitRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class ExcuseLoadMoreRequested extends ExcuseEvent {
  const ExcuseLoadMoreRequested();
}

class ExcuseFilterChanged extends ExcuseEvent {
  final ExcuseStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExcuseFilterChanged({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

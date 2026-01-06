part of 'vacation_bloc.dart';

abstract class VacationEvent extends Equatable {
  const VacationEvent();

  @override
  List<Object?> get props => [];
}

class VacationListRequested extends VacationEvent {
  const VacationListRequested();
}

class VacationApplyRequested extends VacationEvent {
  final VacationRequest request;

  const VacationApplyRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class VacationBalanceRequested extends VacationEvent {
  const VacationBalanceRequested();
}

class VacationLoadMoreRequested extends VacationEvent {
  const VacationLoadMoreRequested();
}

class VacationFilterChanged extends VacationEvent {
  final VacationStatus? status;
  final VacationType? type;

  const VacationFilterChanged({this.status, this.type});

  @override
  List<Object?> get props => [status, type];
}

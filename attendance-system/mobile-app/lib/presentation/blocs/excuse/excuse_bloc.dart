import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/excuse.dart';
import '../../../domain/usecases/excuse/submit_excuse_usecase.dart';
import '../../../domain/usecases/excuse/get_excuses_usecase.dart';

part 'excuse_event.dart';
part 'excuse_state.dart';

/// Excuse BLoC
class ExcuseBloc extends Bloc<ExcuseEvent, ExcuseState> {
  final SubmitExcuseUseCase submitExcuseUseCase;
  final GetExcusesUseCase getExcusesUseCase;

  ExcuseBloc({
    required this.submitExcuseUseCase,
    required this.getExcusesUseCase,
  }) : super(const ExcuseState()) {
    on<ExcuseListRequested>(_onListRequested);
    on<ExcuseSubmitRequested>(_onSubmitRequested);
    on<ExcuseLoadMoreRequested>(_onLoadMoreRequested);
    on<ExcuseFilterChanged>(_onFilterChanged);
  }

  Future<void> _onListRequested(
    ExcuseListRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(state.copyWith(status: ExcuseStatus.loading));

    final params = GetExcusesParams(
      status: state.filterStatus,
      startDate: state.filterStartDate,
      endDate: state.filterEndDate,
      page: 1,
    );

    final result = await getExcusesUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ExcuseStatus.error,
        error: failure.message,
      )),
      (excuses) => emit(state.copyWith(
        status: ExcuseStatus.loaded,
        excuses: excuses,
        currentPage: 1,
        hasMore: excuses.length == 20,
      )),
    );
  }

  Future<void> _onSubmitRequested(
    ExcuseSubmitRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    emit(state.copyWith(submitStatus: ExcuseSubmitStatus.submitting));

    final result = await submitExcuseUseCase(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        submitStatus: ExcuseSubmitStatus.error,
        error: failure.message,
      )),
      (excuse) => emit(state.copyWith(
        submitStatus: ExcuseSubmitStatus.success,
        excuses: [excuse, ...state.excuses],
      )),
    );
  }

  Future<void> _onLoadMoreRequested(
    ExcuseLoadMoreRequested event,
    Emitter<ExcuseState> emit,
  ) async {
    if (!state.hasMore || state.status == ExcuseStatus.loadingMore) return;

    emit(state.copyWith(status: ExcuseStatus.loadingMore));

    final params = GetExcusesParams(
      status: state.filterStatus,
      startDate: state.filterStartDate,
      endDate: state.filterEndDate,
      page: state.currentPage + 1,
    );

    final result = await getExcusesUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ExcuseStatus.error,
        error: failure.message,
      )),
      (excuses) => emit(state.copyWith(
        status: ExcuseStatus.loaded,
        excuses: [...state.excuses, ...excuses],
        currentPage: state.currentPage + 1,
        hasMore: excuses.length == 20,
      )),
    );
  }

  void _onFilterChanged(
    ExcuseFilterChanged event,
    Emitter<ExcuseState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.status,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
    add(const ExcuseListRequested());
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/vacation.dart';
import '../../../domain/usecases/vacation/apply_vacation_usecase.dart';
import '../../../domain/usecases/vacation/get_vacations_usecase.dart';
import '../../../domain/usecases/vacation/get_vacation_balance_usecase.dart';

part 'vacation_event.dart';
part 'vacation_state.dart';

/// Vacation BLoC
class VacationBloc extends Bloc<VacationEvent, VacationState> {
  final ApplyVacationUseCase applyVacationUseCase;
  final GetVacationsUseCase getVacationsUseCase;
  final GetVacationBalanceUseCase getVacationBalanceUseCase;

  VacationBloc({
    required this.applyVacationUseCase,
    required this.getVacationsUseCase,
    required this.getVacationBalanceUseCase,
  }) : super(const VacationState()) {
    on<VacationListRequested>(_onListRequested);
    on<VacationApplyRequested>(_onApplyRequested);
    on<VacationBalanceRequested>(_onBalanceRequested);
    on<VacationLoadMoreRequested>(_onLoadMoreRequested);
    on<VacationFilterChanged>(_onFilterChanged);
  }

  Future<void> _onListRequested(
    VacationListRequested event,
    Emitter<VacationState> emit,
  ) async {
    emit(state.copyWith(status: VacationListStatus.loading));

    final params = GetVacationsParams(
      status: state.filterStatus,
      type: state.filterType,
      page: 1,
    );

    final result = await getVacationsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: VacationListStatus.error,
        error: failure.message,
      )),
      (vacations) => emit(state.copyWith(
        status: VacationListStatus.loaded,
        vacations: vacations,
        currentPage: 1,
        hasMore: vacations.length == 20,
      )),
    );
  }

  Future<void> _onApplyRequested(
    VacationApplyRequested event,
    Emitter<VacationState> emit,
  ) async {
    emit(state.copyWith(applyStatus: VacationApplyStatus.submitting));

    final result = await applyVacationUseCase(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        applyStatus: VacationApplyStatus.error,
        error: failure.message,
      )),
      (vacation) => emit(state.copyWith(
        applyStatus: VacationApplyStatus.success,
        vacations: [vacation, ...state.vacations],
      )),
    );
  }

  Future<void> _onBalanceRequested(
    VacationBalanceRequested event,
    Emitter<VacationState> emit,
  ) async {
    emit(state.copyWith(balanceStatus: VacationBalanceStatus.loading));

    final result = await getVacationBalanceUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        balanceStatus: VacationBalanceStatus.error,
        error: failure.message,
      )),
      (balance) => emit(state.copyWith(
        balanceStatus: VacationBalanceStatus.loaded,
        balance: balance,
      )),
    );
  }

  Future<void> _onLoadMoreRequested(
    VacationLoadMoreRequested event,
    Emitter<VacationState> emit,
  ) async {
    if (!state.hasMore || state.status == VacationListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: VacationListStatus.loadingMore));

    final params = GetVacationsParams(
      status: state.filterStatus,
      type: state.filterType,
      page: state.currentPage + 1,
    );

    final result = await getVacationsUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: VacationListStatus.error,
        error: failure.message,
      )),
      (vacations) => emit(state.copyWith(
        status: VacationListStatus.loaded,
        vacations: [...state.vacations, ...vacations],
        currentPage: state.currentPage + 1,
        hasMore: vacations.length == 20,
      )),
    );
  }

  void _onFilterChanged(
    VacationFilterChanged event,
    Emitter<VacationState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.status,
      filterType: event.type,
    ));
    add(const VacationListRequested());
  }
}

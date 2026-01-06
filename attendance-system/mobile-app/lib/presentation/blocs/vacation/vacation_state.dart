part of 'vacation_bloc.dart';

enum VacationListStatus { initial, loading, loaded, loadingMore, error }

enum VacationApplyStatus { initial, submitting, success, error }

enum VacationBalanceStatus { initial, loading, loaded, error }

class VacationState extends Equatable {
  final VacationListStatus status;
  final VacationApplyStatus applyStatus;
  final VacationBalanceStatus balanceStatus;
  final List<Vacation> vacations;
  final VacationBalance? balance;
  final int currentPage;
  final bool hasMore;
  final VacationStatus? filterStatus;
  final VacationType? filterType;
  final String? error;

  const VacationState({
    this.status = VacationListStatus.initial,
    this.applyStatus = VacationApplyStatus.initial,
    this.balanceStatus = VacationBalanceStatus.initial,
    this.vacations = const [],
    this.balance,
    this.currentPage = 1,
    this.hasMore = false,
    this.filterStatus,
    this.filterType,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        applyStatus,
        balanceStatus,
        vacations,
        balance,
        currentPage,
        hasMore,
        filterStatus,
        filterType,
        error,
      ];

  VacationState copyWith({
    VacationListStatus? status,
    VacationApplyStatus? applyStatus,
    VacationBalanceStatus? balanceStatus,
    List<Vacation>? vacations,
    VacationBalance? balance,
    int? currentPage,
    bool? hasMore,
    VacationStatus? filterStatus,
    VacationType? filterType,
    String? error,
  }) {
    return VacationState(
      status: status ?? this.status,
      applyStatus: applyStatus ?? this.applyStatus,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      vacations: vacations ?? this.vacations,
      balance: balance ?? this.balance,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterStatus: filterStatus ?? this.filterStatus,
      filterType: filterType ?? this.filterType,
      error: error,
    );
  }
}

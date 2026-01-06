part of 'excuse_bloc.dart';

enum ExcuseStatus { initial, loading, loaded, loadingMore, error }

enum ExcuseSubmitStatus { initial, submitting, success, error }

class ExcuseState extends Equatable {
  final ExcuseStatus status;
  final ExcuseSubmitStatus submitStatus;
  final List<Excuse> excuses;
  final int currentPage;
  final bool hasMore;
  final ExcuseStatus? filterStatus;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? error;

  const ExcuseState({
    this.status = ExcuseStatus.initial,
    this.submitStatus = ExcuseSubmitStatus.initial,
    this.excuses = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.filterStatus,
    this.filterStartDate,
    this.filterEndDate,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        submitStatus,
        excuses,
        currentPage,
        hasMore,
        filterStatus,
        filterStartDate,
        filterEndDate,
        error,
      ];

  ExcuseState copyWith({
    ExcuseStatus? status,
    ExcuseSubmitStatus? submitStatus,
    List<Excuse>? excuses,
    int? currentPage,
    bool? hasMore,
    ExcuseStatus? filterStatus,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? error,
  }) {
    return ExcuseState(
      status: status ?? this.status,
      submitStatus: submitStatus ?? this.submitStatus,
      excuses: excuses ?? this.excuses,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterStatus: filterStatus ?? this.filterStatus,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      error: error,
    );
  }
}

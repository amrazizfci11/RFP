import 'package:equatable/equatable.dart';

/// Vacation status enum
enum VacationStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

/// Vacation type enum
enum VacationType {
  annual,
  sick,
  unpaid,
  maternity,
  paternity,
  bereavement,
  marriage,
  hajj,
  other,
}

/// Vacation entity
class Vacation extends Equatable {
  final String id;
  final String employeeId;
  final VacationType type;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
  final VacationStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final String? delegateTo;
  final DateTime createdAt;

  const Vacation({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.delegateTo,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        type,
        startDate,
        endDate,
        days,
        reason,
        status,
        reviewedBy,
        reviewedAt,
        reviewNotes,
        delegateTo,
        createdAt,
      ];

  bool get isPending => status == VacationStatus.pending;
  bool get isApproved => status == VacationStatus.approved;
  bool get isRejected => status == VacationStatus.rejected;
  bool get isCancelled => status == VacationStatus.cancelled;
  bool get isOngoing {
    final now = DateTime.now();
    return isApproved &&
        now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }
}

/// Vacation balance
class VacationBalance extends Equatable {
  final int annualTotal;
  final int annualUsed;
  final int annualRemaining;
  final int sickTotal;
  final int sickUsed;
  final int sickRemaining;
  final int unpaidUsed;
  final Map<VacationType, int>? otherBalances;

  const VacationBalance({
    required this.annualTotal,
    required this.annualUsed,
    required this.annualRemaining,
    required this.sickTotal,
    required this.sickUsed,
    required this.sickRemaining,
    required this.unpaidUsed,
    this.otherBalances,
  });

  @override
  List<Object?> get props => [
        annualTotal,
        annualUsed,
        annualRemaining,
        sickTotal,
        sickUsed,
        sickRemaining,
        unpaidUsed,
        otherBalances,
      ];

  int get totalUsed => annualUsed + sickUsed + unpaidUsed;
}

/// Apply vacation request
class VacationRequest extends Equatable {
  final VacationType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? delegateTo;

  const VacationRequest({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.delegateTo,
  });

  @override
  List<Object?> get props => [type, startDate, endDate, reason, delegateTo];

  int get days {
    return endDate.difference(startDate).inDays + 1;
  }
}

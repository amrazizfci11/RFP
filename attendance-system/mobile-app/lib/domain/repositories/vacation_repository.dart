import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/vacation.dart';

/// Vacation repository interface
abstract class VacationRepository {
  /// Apply for vacation
  Future<Either<Failure, Vacation>> applyVacation({
    required VacationRequest request,
  });

  /// Get all vacations for current user
  Future<Either<Failure, List<Vacation>>> getVacations({
    VacationStatus? status,
    VacationType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Get vacation by ID
  Future<Either<Failure, Vacation>> getVacationById(String id);

  /// Cancel pending vacation
  Future<Either<Failure, void>> cancelVacation(String id);

  /// Get vacation balance
  Future<Either<Failure, VacationBalance>> getBalance();

  /// Check date availability for vacation
  Future<Either<Failure, bool>> checkDateAvailability({
    required DateTime startDate,
    required DateTime endDate,
    VacationType? type,
  });

  /// Get upcoming vacations
  Future<Either<Failure, List<Vacation>>> getUpcomingVacations();
}

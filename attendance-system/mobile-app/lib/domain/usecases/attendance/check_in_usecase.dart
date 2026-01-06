import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Check-in use case
class CheckInUseCase {
  final AttendanceRepository _repository;

  CheckInUseCase(this._repository);

  Future<Either<Failure, AttendanceRecord>> call(AttendanceAction action) {
    return _repository.checkIn(action: action);
  }
}

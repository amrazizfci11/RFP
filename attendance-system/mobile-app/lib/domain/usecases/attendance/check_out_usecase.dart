import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Check-out use case
class CheckOutUseCase {
  final AttendanceRepository _repository;

  CheckOutUseCase(this._repository);

  Future<Either<Failure, AttendanceRecord>> call(AttendanceAction action) {
    return _repository.checkOut(action: action);
  }
}

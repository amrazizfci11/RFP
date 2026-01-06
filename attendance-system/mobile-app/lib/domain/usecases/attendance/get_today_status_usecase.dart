import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

/// Get today's attendance status use case
class GetTodayStatusUseCase {
  final AttendanceRepository _repository;

  GetTodayStatusUseCase(this._repository);

  Future<Either<Failure, TodayAttendance>> call() {
    return _repository.getTodayStatus();
  }
}

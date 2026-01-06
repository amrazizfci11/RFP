import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/excuse.dart';

/// Excuse repository interface
abstract class ExcuseRepository {
  /// Submit a new excuse
  Future<Either<Failure, Excuse>> submitExcuse({
    required ExcuseRequest request,
  });

  /// Get all excuses for current user
  Future<Either<Failure, List<Excuse>>> getExcuses({
    ExcuseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Get excuse by ID
  Future<Either<Failure, Excuse>> getExcuseById(String id);

  /// Cancel pending excuse
  Future<Either<Failure, void>> cancelExcuse(String id);

  /// Upload attachment for excuse
  Future<Either<Failure, ExcuseAttachment>> uploadAttachment({
    required String filePath,
    void Function(int, int)? onProgress,
  });

  /// Delete attachment
  Future<Either<Failure, void>> deleteAttachment(String attachmentId);
}

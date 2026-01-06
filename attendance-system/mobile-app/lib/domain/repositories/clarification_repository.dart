import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/clarification.dart';

/// Clarification repository interface
abstract class ClarificationRepository {
  /// Get all clarification requests for current user
  Future<Either<Failure, List<Clarification>>> getClarifications({
    ClarificationStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get clarification by ID
  Future<Either<Failure, Clarification>> getClarificationById(String id);

  /// Respond to clarification request
  Future<Either<Failure, Clarification>> respondToClarification({
    required ClarificationResponse response,
  });

  /// Get pending clarifications count
  Future<Either<Failure, int>> getPendingCount();

  /// Upload attachment for clarification response
  Future<Either<Failure, ClarificationAttachment>> uploadAttachment({
    required String filePath,
    void Function(int, int)? onProgress,
  });
}

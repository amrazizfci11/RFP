import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/excuse.dart';
import '../../domain/repositories/excuse_repository.dart';
import '../datasources/remote/excuse_remote_datasource.dart';

/// Implementation of ExcuseRepository
class ExcuseRepositoryImpl implements ExcuseRepository {
  final ExcuseRemoteDataSource remoteDataSource;

  ExcuseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Excuse>> submitExcuse({
    required ExcuseRequest request,
  }) async {
    try {
      final excuse = await remoteDataSource.submitExcuse(request);
      return Right(excuse);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Excuse>>> getExcuses({
    ExcuseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final excuses = await remoteDataSource.getExcuses(
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );
      return Right(excuses);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Excuse>> getExcuseById(String id) async {
    try {
      final excuse = await remoteDataSource.getExcuseById(id);
      return Right(excuse);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelExcuse(String id) async {
    try {
      await remoteDataSource.cancelExcuse(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExcuseAttachment>> uploadAttachment({
    required String filePath,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final attachment = await remoteDataSource.uploadAttachment(filePath);
      return Right(attachment);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(String attachmentId) async {
    try {
      // API call to delete attachment would go here
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

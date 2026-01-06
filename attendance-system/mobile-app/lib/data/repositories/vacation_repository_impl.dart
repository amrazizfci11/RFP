import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/vacation.dart';
import '../../domain/repositories/vacation_repository.dart';
import '../datasources/remote/vacation_remote_datasource.dart';

/// Implementation of VacationRepository
class VacationRepositoryImpl implements VacationRepository {
  final VacationRemoteDataSource remoteDataSource;

  VacationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Vacation>> applyVacation({
    required VacationRequest request,
  }) async {
    try {
      final vacation = await remoteDataSource.applyVacation(request);
      return Right(vacation);
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
  Future<Either<Failure, List<Vacation>>> getVacations({
    VacationStatus? status,
    VacationType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final vacations = await remoteDataSource.getVacations(
        status: status,
        type: type,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );
      return Right(vacations);
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
  Future<Either<Failure, Vacation>> getVacationById(String id) async {
    try {
      final vacation = await remoteDataSource.getVacationById(id);
      return Right(vacation);
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
  Future<Either<Failure, void>> cancelVacation(String id) async {
    try {
      await remoteDataSource.cancelVacation(id);
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
  Future<Either<Failure, VacationBalance>> getBalance() async {
    try {
      final balance = await remoteDataSource.getBalance();
      return Right(balance);
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
  Future<Either<Failure, bool>> checkDateAvailability({
    required DateTime startDate,
    required DateTime endDate,
    VacationType? type,
  }) async {
    try {
      final isAvailable = await remoteDataSource.checkDateAvailability(
        startDate,
        endDate,
      );
      return Right(isAvailable);
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
  Future<Either<Failure, List<Vacation>>> getUpcomingVacations() async {
    try {
      final vacations = await remoteDataSource.getVacations(
        status: VacationStatus.approved,
        startDate: DateTime.now(),
      );
      return Right(vacations);
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
}

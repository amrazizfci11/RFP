import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/attendance_local_datasource.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/attendance_remote_datasource.dart';
import '../../data/datasources/remote/excuse_remote_datasource.dart';
import '../../data/datasources/remote/vacation_remote_datasource.dart';
import '../../data/datasources/remote/reports_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/excuse_repository_impl.dart';
import '../../data/repositories/vacation_repository_impl.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/excuse_repository.dart';
import '../../domain/repositories/vacation_repository.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../domain/usecases/auth/biometric_login_usecase.dart';
import '../../domain/usecases/auth/nafath_login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/attendance/check_in_usecase.dart';
import '../../domain/usecases/attendance/check_out_usecase.dart';
import '../../domain/usecases/attendance/get_today_status_usecase.dart';
import '../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../domain/usecases/excuse/submit_excuse_usecase.dart';
import '../../domain/usecases/excuse/get_excuses_usecase.dart';
import '../../domain/usecases/vacation/apply_vacation_usecase.dart';
import '../../domain/usecases/vacation/get_vacations_usecase.dart';
import '../../domain/usecases/vacation/get_vacation_balance_usecase.dart';
import '../../domain/usecases/reports/get_attendance_report_usecase.dart';
import '../../domain/usecases/reports/download_report_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/attendance/attendance_bloc.dart';
import '../../presentation/blocs/excuse/excuse_bloc.dart';
import '../../presentation/blocs/vacation/vacation_bloc.dart';
import '../../presentation/blocs/reports/reports_bloc.dart';
import '../../presentation/blocs/settings/settings_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  getIt.registerLazySingleton<Dio>(() => Dio());

  // Core
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>(), getIt<FlutterSecureStorage>()),
  );

  // Data Sources - Local
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Data Sources - Remote
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ExcuseRemoteDataSource>(
    () => ExcuseRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<VacationRemoteDataSource>(
    () => VacationRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: getIt<AttendanceRemoteDataSource>(),
      localDataSource: getIt<AttendanceLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ExcuseRepository>(
    () => ExcuseRepositoryImpl(
      remoteDataSource: getIt<ExcuseRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<VacationRepository>(
    () => VacationRepositoryImpl(
      remoteDataSource: getIt<VacationRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      remoteDataSource: getIt<ReportsRemoteDataSource>(),
    ),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => BiometricLoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => NafathLoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // Use Cases - Attendance
  getIt.registerLazySingleton(() => CheckInUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(() => CheckOutUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(() => GetTodayStatusUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(() => GetAttendanceHistoryUseCase(getIt<AttendanceRepository>()));

  // Use Cases - Excuse
  getIt.registerLazySingleton(() => SubmitExcuseUseCase(getIt<ExcuseRepository>()));
  getIt.registerLazySingleton(() => GetExcusesUseCase(getIt<ExcuseRepository>()));

  // Use Cases - Vacation
  getIt.registerLazySingleton(() => ApplyVacationUseCase(getIt<VacationRepository>()));
  getIt.registerLazySingleton(() => GetVacationsUseCase(getIt<VacationRepository>()));
  getIt.registerLazySingleton(() => GetVacationBalanceUseCase(getIt<VacationRepository>()));

  // Use Cases - Reports
  getIt.registerLazySingleton(() => GetAttendanceReportUseCase(getIt<ReportsRepository>()));
  getIt.registerLazySingleton(() => DownloadReportUseCase(getIt<ReportsRepository>()));

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
      biometricLoginUseCase: getIt<BiometricLoginUseCase>(),
      nafathLoginUseCase: getIt<NafathLoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      authLocalDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerFactory(
    () => AttendanceBloc(
      checkInUseCase: getIt<CheckInUseCase>(),
      checkOutUseCase: getIt<CheckOutUseCase>(),
      getTodayStatusUseCase: getIt<GetTodayStatusUseCase>(),
      getAttendanceHistoryUseCase: getIt<GetAttendanceHistoryUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => ExcuseBloc(
      submitExcuseUseCase: getIt<SubmitExcuseUseCase>(),
      getExcusesUseCase: getIt<GetExcusesUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => VacationBloc(
      applyVacationUseCase: getIt<ApplyVacationUseCase>(),
      getVacationsUseCase: getIt<GetVacationsUseCase>(),
      getVacationBalanceUseCase: getIt<GetVacationBalanceUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => ReportsBloc(
      getAttendanceReportUseCase: getIt<GetAttendanceReportUseCase>(),
      downloadReportUseCase: getIt<DownloadReportUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => SettingsBloc(
      settingsLocalDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );
}

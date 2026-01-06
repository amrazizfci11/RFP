import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/auth_local_datasource.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../domain/usecases/auth/biometric_login_usecase.dart';
import '../../../domain/usecases/auth/nafath_login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final BiometricLoginUseCase biometricLoginUseCase;
  final NafathLoginUseCase nafathLoginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthLocalDataSource authLocalDataSource;

  AuthBloc({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.biometricLoginUseCase,
    required this.nafathLoginUseCase,
    required this.logoutUseCase,
    required this.authLocalDataSource,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerificationRequested>(_onOtpVerificationRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
    on<AuthNafathInitiated>(_onNafathInitiated);
    on<AuthNafathVerificationRequested>(_onNafathVerificationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthBiometricRegistrationRequested>(_onBiometricRegistrationRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final user = await authLocalDataSource.getCachedUser();
    final isLoggedIn = await authLocalDataSource.isLoggedIn();

    if (user != null && isLoggedIn) {
      final isBiometricEnabled = await authLocalDataSource.isBiometricEnabled();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isBiometricEnabled: isBiometricEnabled,
      ));
    } else {
      // Check if biometric is available for quick login
      final biometricResult = await biometricLoginUseCase.isAvailable();
      final isBiometricAvailable = biometricResult.fold((_) => false, (v) => v);

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        isBiometricAvailable: isBiometricAvailable,
      ));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await loginUseCase(LoginParams(
      identifier: event.identifier,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      )),
      (authResult) {
        if (authResult.requiresOtp) {
          emit(state.copyWith(
            status: AuthStatus.otpRequired,
            otpRequestId: authResult.otpRequestId,
            tempUser: authResult.user,
          ));
        } else {
          authLocalDataSource.cacheUser(authResult.user);
          authLocalDataSource.cacheTokens(authResult.tokens);
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: authResult.user,
          ));
        }
      },
    );
  }

  Future<void> _onOtpVerificationRequested(
    AuthOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await verifyOtpUseCase(VerifyOtpParams(
      requestId: state.otpRequestId!,
      otp: event.otp,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.otpRequired,
        error: failure.message,
      )),
      (authResult) {
        authLocalDataSource.cacheUser(authResult.user);
        authLocalDataSource.cacheTokens(authResult.tokens);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: authResult.user,
          otpRequestId: null,
          tempUser: null,
        ));
      },
    );
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    // This would trigger a resend OTP API call
    emit(state.copyWith(otpResent: true));
  }

  Future<void> _onBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await biometricLoginUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (authResult) {
        authLocalDataSource.cacheUser(authResult.user);
        authLocalDataSource.cacheTokens(authResult.tokens);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: authResult.user,
        ));
      },
    );
  }

  Future<void> _onNafathInitiated(
    AuthNafathInitiated event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await nafathLoginUseCase.initiate();

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      )),
      (session) => emit(state.copyWith(
        status: AuthStatus.nafathPending,
        nafathSession: session,
      )),
    );
  }

  Future<void> _onNafathVerificationRequested(
    AuthNafathVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await nafathLoginUseCase.verify(NafathVerifyParams(
      transactionId: state.nafathSession!.transactionId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
        nafathSession: null,
      )),
      (authResult) {
        authLocalDataSource.cacheUser(authResult.user);
        authLocalDataSource.cacheTokens(authResult.tokens);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: authResult.user,
          nafathSession: null,
        ));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    await logoutUseCase();
    await authLocalDataSource.clearAll();

    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onBiometricRegistrationRequested(
    AuthBiometricRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await biometricLoginUseCase.register();

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (success) {
        if (success) {
          authLocalDataSource.setBiometricEnabled(true);
          emit(state.copyWith(isBiometricEnabled: true));
        }
      },
    );
  }
}

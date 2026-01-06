part of 'auth_bloc.dart';

/// Authentication status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpRequired,
  nafathPending,
  error,
}

/// Authentication state
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final User? tempUser;
  final String? otpRequestId;
  final NafathSession? nafathSession;
  final String? error;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final bool otpResent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.tempUser,
    this.otpRequestId,
    this.nafathSession,
    this.error,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.otpResent = false,
  });

  @override
  List<Object?> get props => [
        status,
        user,
        tempUser,
        otpRequestId,
        nafathSession,
        error,
        isBiometricAvailable,
        isBiometricEnabled,
        otpResent,
      ];

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => error != null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    User? tempUser,
    String? otpRequestId,
    NafathSession? nafathSession,
    String? error,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    bool? otpResent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      tempUser: tempUser ?? this.tempUser,
      otpRequestId: otpRequestId ?? this.otpRequestId,
      nafathSession: nafathSession ?? this.nafathSession,
      error: error,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      otpResent: otpResent ?? this.otpResent,
    );
  }
}

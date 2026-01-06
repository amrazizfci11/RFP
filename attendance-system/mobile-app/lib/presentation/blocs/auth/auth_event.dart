part of 'auth_bloc.dart';

/// Base auth event
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with credentials
class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}

/// Verify OTP code
class AuthOtpVerificationRequested extends AuthEvent {
  final String otp;

  const AuthOtpVerificationRequested({required this.otp});

  @override
  List<Object?> get props => [otp];
}

/// Resend OTP code
class AuthOtpResendRequested extends AuthEvent {
  const AuthOtpResendRequested();
}

/// Login with biometric
class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

/// Initiate Nafath authentication
class AuthNafathInitiated extends AuthEvent {
  const AuthNafathInitiated();
}

/// Verify Nafath authentication
class AuthNafathVerificationRequested extends AuthEvent {
  const AuthNafathVerificationRequested();
}

/// Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Register biometric for future logins
class AuthBiometricRegistrationRequested extends AuthEvent {
  const AuthBiometricRegistrationRequested();
}

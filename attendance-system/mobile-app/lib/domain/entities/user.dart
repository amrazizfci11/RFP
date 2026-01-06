import 'package:equatable/equatable.dart';

/// User entity representing an employee
class User extends Equatable {
  final String id;
  final String iqama;
  final String name;
  final String nameAr;
  final String email;
  final String mobile;
  final String? jobTitle;
  final String? department;
  final String? profileImageUrl;
  final String companyId;
  final String companyName;
  final bool isActive;
  final bool isBiometricEnabled;
  final DateTime? dateOfBirth;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.iqama,
    required this.name,
    required this.nameAr,
    required this.email,
    required this.mobile,
    this.jobTitle,
    this.department,
    this.profileImageUrl,
    required this.companyId,
    required this.companyName,
    required this.isActive,
    required this.isBiometricEnabled,
    this.dateOfBirth,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        iqama,
        name,
        nameAr,
        email,
        mobile,
        jobTitle,
        department,
        profileImageUrl,
        companyId,
        companyName,
        isActive,
        isBiometricEnabled,
        dateOfBirth,
        createdAt,
      ];

  User copyWith({
    String? id,
    String? iqama,
    String? name,
    String? nameAr,
    String? email,
    String? mobile,
    String? jobTitle,
    String? department,
    String? profileImageUrl,
    String? companyId,
    String? companyName,
    bool? isActive,
    bool? isBiometricEnabled,
    DateTime? dateOfBirth,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      iqama: iqama ?? this.iqama,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      isActive: isActive ?? this.isActive,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Authentication tokens
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

/// Login result containing user and tokens
class AuthResult extends Equatable {
  final User user;
  final AuthTokens tokens;
  final bool requiresOtp;
  final String? otpRequestId;

  const AuthResult({
    required this.user,
    required this.tokens,
    this.requiresOtp = false,
    this.otpRequestId,
  });

  @override
  List<Object?> get props => [user, tokens, requiresOtp, otpRequestId];
}

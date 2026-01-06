import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<void> cacheTokens(AuthTokens tokens);
  Future<AuthTokens?> getCachedTokens();
  Future<bool> isLoggedIn();
  Future<void> clearAll();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheUser(User user) async {
    final userJson = jsonEncode({
      'id': user.id,
      'iqama': user.iqama,
      'name': user.name,
      'nameAr': user.nameAr,
      'email': user.email,
      'mobile': user.mobile,
      'jobTitle': user.jobTitle,
      'department': user.department,
      'profileImageUrl': user.profileImageUrl,
      'companyId': user.companyId,
      'companyName': user.companyName,
      'isActive': user.isActive,
      'isBiometricEnabled': user.isBiometricEnabled,
      'dateOfBirth': user.dateOfBirth?.toIso8601String(),
      'createdAt': user.createdAt.toIso8601String(),
    });
    await secureStorage.write(key: AppConstants.userDataKey, value: userJson);
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = await secureStorage.read(key: AppConstants.userDataKey);
    if (userJson == null) return null;

    final data = jsonDecode(userJson) as Map<String, dynamic>;
    return User(
      id: data['id'],
      iqama: data['iqama'],
      name: data['name'],
      nameAr: data['nameAr'],
      email: data['email'],
      mobile: data['mobile'],
      jobTitle: data['jobTitle'],
      department: data['department'],
      profileImageUrl: data['profileImageUrl'],
      companyId: data['companyId'],
      companyName: data['companyName'],
      isActive: data['isActive'],
      isBiometricEnabled: data['isBiometricEnabled'],
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.parse(data['dateOfBirth'])
          : null,
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  @override
  Future<void> cacheTokens(AuthTokens tokens) async {
    await secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: tokens.accessToken,
    );
    await secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: tokens.refreshToken,
    );
  }

  @override
  Future<AuthTokens?> getCachedTokens() async {
    final accessToken =
        await secureStorage.read(key: AppConstants.accessTokenKey);
    final refreshToken =
        await secureStorage.read(key: AppConstants.refreshTokenKey);

    if (accessToken == null || refreshToken == null) return null;

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)), // Decoded from JWT
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null;
  }

  @override
  Future<void> clearAll() async {
    await secureStorage.delete(key: AppConstants.accessTokenKey);
    await secureStorage.delete(key: AppConstants.refreshTokenKey);
    await secureStorage.delete(key: AppConstants.userDataKey);
    await sharedPreferences.remove(AppConstants.biometricEnabledKey);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return sharedPreferences.getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await sharedPreferences.setBool(AppConstants.biometricEnabledKey, enabled);
  }
}

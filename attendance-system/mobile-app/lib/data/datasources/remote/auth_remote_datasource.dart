import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<AuthResult> login(String identifier, String password);
  Future<AuthResult> verifyOtp(String requestId, String otp);
  Future<String> resendOtp(String requestId);
  Future<AuthResult> loginWithBiometric(String biometricToken);
  Future<String> registerBiometric(String userId);
  Future<NafathSession> initNafathAuth();
  Future<AuthResult> verifyNafathAuth(String transactionId);
  Future<void> logout();
  Future<AuthTokens> refreshTokens(String refreshToken);
  Future<void> updateFcmToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResult> login(String identifier, String password) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return _parseAuthResult(data);
  }

  @override
  Future<AuthResult> verifyOtp(String requestId, String otp) async {
    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'request_id': requestId,
        'otp': otp,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return _parseAuthResult(data);
  }

  @override
  Future<String> resendOtp(String requestId) async {
    final response = await apiClient.post(
      '${ApiEndpoints.verifyOtp}/resend',
      data: {'request_id': requestId},
    );

    return response.data['request_id'] as String;
  }

  @override
  Future<AuthResult> loginWithBiometric(String biometricToken) async {
    final response = await apiClient.post(
      ApiEndpoints.biometricLogin,
      data: {'biometric_token': biometricToken},
    );

    final data = response.data as Map<String, dynamic>;
    return _parseAuthResult(data);
  }

  @override
  Future<String> registerBiometric(String userId) async {
    final response = await apiClient.post(
      ApiEndpoints.biometricRegister,
      data: {'user_id': userId},
    );

    return response.data['biometric_token'] as String;
  }

  @override
  Future<NafathSession> initNafathAuth() async {
    final response = await apiClient.post(ApiEndpoints.nafathInit);

    final data = response.data as Map<String, dynamic>;
    return NafathSession(
      transactionId: data['transaction_id'],
      random: data['random'],
      expiresAt: DateTime.parse(data['expires_at']),
    );
  }

  @override
  Future<AuthResult> verifyNafathAuth(String transactionId) async {
    final response = await apiClient.post(
      ApiEndpoints.nafathVerify,
      data: {'transaction_id': transactionId},
    );

    final data = response.data as Map<String, dynamic>;
    return _parseAuthResult(data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiEndpoints.logout);
  }

  @override
  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    return AuthTokens(
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      expiresAt: DateTime.parse(data['expires_at']),
    );
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await apiClient.post(
      '${ApiEndpoints.profile}/fcm-token',
      data: {'token': token},
    );
  }

  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final userData = data['user'] as Map<String, dynamic>;
    final user = User(
      id: userData['id'],
      iqama: userData['iqama'],
      name: userData['name'],
      nameAr: userData['name_ar'],
      email: userData['email'],
      mobile: userData['mobile'],
      jobTitle: userData['job_title'],
      department: userData['department'],
      profileImageUrl: userData['profile_image_url'],
      companyId: userData['company_id'],
      companyName: userData['company_name'],
      isActive: userData['is_active'] ?? true,
      isBiometricEnabled: userData['is_biometric_enabled'] ?? false,
      dateOfBirth: userData['date_of_birth'] != null
          ? DateTime.parse(userData['date_of_birth'])
          : null,
      createdAt: DateTime.parse(userData['created_at']),
    );

    final tokens = data['tokens'] != null
        ? AuthTokens(
            accessToken: data['tokens']['access_token'],
            refreshToken: data['tokens']['refresh_token'],
            expiresAt: DateTime.parse(data['tokens']['expires_at']),
          )
        : AuthTokens(
            accessToken: '',
            refreshToken: '',
            expiresAt: DateTime.now(),
          );

    return AuthResult(
      user: user,
      tokens: tokens,
      requiresOtp: data['requires_otp'] ?? false,
      otpRequestId: data['otp_request_id'],
    );
  }
}

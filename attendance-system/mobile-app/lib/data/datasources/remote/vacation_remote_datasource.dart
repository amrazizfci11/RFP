import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/vacation.dart';

/// Remote data source for vacations
abstract class VacationRemoteDataSource {
  Future<Vacation> applyVacation(VacationRequest request);
  Future<List<Vacation>> getVacations({
    VacationStatus? status,
    VacationType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });
  Future<Vacation> getVacationById(String id);
  Future<void> cancelVacation(String id);
  Future<VacationBalance> getBalance();
  Future<bool> checkDateAvailability(DateTime startDate, DateTime endDate);
}

class VacationRemoteDataSourceImpl implements VacationRemoteDataSource {
  final ApiClient apiClient;

  VacationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Vacation> applyVacation(VacationRequest request) async {
    final response = await apiClient.post(
      ApiEndpoints.applyVacation,
      data: {
        'type': request.type.name,
        'start_date': request.startDate.toIso8601String(),
        'end_date': request.endDate.toIso8601String(),
        'reason': request.reason,
        'delegate_to': request.delegateTo,
      },
    );

    return _parseVacation(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Vacation>> getVacations({
    VacationStatus? status,
    VacationType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.vacations,
      queryParameters: {
        if (status != null) 'status': status.name,
        if (type != null) 'type': type.name,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );

    final list = response.data['items'] as List;
    return list.map((e) => _parseVacation(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Vacation> getVacationById(String id) async {
    final response = await apiClient.get('${ApiEndpoints.vacations}/$id');
    return _parseVacation(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelVacation(String id) async {
    await apiClient.post('${ApiEndpoints.vacations}/$id/cancel');
  }

  @override
  Future<VacationBalance> getBalance() async {
    final response = await apiClient.get(ApiEndpoints.vacationBalance);
    final data = response.data as Map<String, dynamic>;

    return VacationBalance(
      annualTotal: data['annual_total'] ?? 0,
      annualUsed: data['annual_used'] ?? 0,
      annualRemaining: data['annual_remaining'] ?? 0,
      sickTotal: data['sick_total'] ?? 0,
      sickUsed: data['sick_used'] ?? 0,
      sickRemaining: data['sick_remaining'] ?? 0,
      unpaidUsed: data['unpaid_used'] ?? 0,
    );
  }

  @override
  Future<bool> checkDateAvailability(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await apiClient.get(
      '${ApiEndpoints.vacations}/check-availability',
      queryParameters: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    return response.data['available'] ?? false;
  }

  Vacation _parseVacation(Map<String, dynamic> data) {
    return Vacation(
      id: data['id'],
      employeeId: data['employee_id'],
      type: VacationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => VacationType.annual,
      ),
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      days: data['days'] ?? 0,
      reason: data['reason'] ?? '',
      status: VacationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => VacationStatus.pending,
      ),
      reviewedBy: data['reviewed_by'],
      reviewedAt: data['reviewed_at'] != null
          ? DateTime.parse(data['reviewed_at'])
          : null,
      reviewNotes: data['review_notes'],
      delegateTo: data['delegate_to'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

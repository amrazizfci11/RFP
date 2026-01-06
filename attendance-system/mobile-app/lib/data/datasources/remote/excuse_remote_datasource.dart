import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/excuse.dart';

/// Remote data source for excuses
abstract class ExcuseRemoteDataSource {
  Future<Excuse> submitExcuse(ExcuseRequest request);
  Future<List<Excuse>> getExcuses({
    ExcuseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });
  Future<Excuse> getExcuseById(String id);
  Future<void> cancelExcuse(String id);
  Future<ExcuseAttachment> uploadAttachment(String filePath);
}

class ExcuseRemoteDataSourceImpl implements ExcuseRemoteDataSource {
  final ApiClient apiClient;

  ExcuseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Excuse> submitExcuse(ExcuseRequest request) async {
    // Upload attachments first
    final attachmentIds = <String>[];
    for (final filePath in request.filePaths) {
      final attachment = await uploadAttachment(filePath);
      attachmentIds.add(attachment.id);
    }

    final response = await apiClient.post(
      ApiEndpoints.submitExcuse,
      data: {
        'date': request.date.toIso8601String(),
        'type': request.type.name,
        'reason': request.reason,
        'attachment_ids': attachmentIds,
      },
    );

    return _parseExcuse(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Excuse>> getExcuses({
    ExcuseStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get(
      ApiEndpoints.excuses,
      queryParameters: {
        if (status != null) 'status': status.name,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      },
    );

    final list = response.data['items'] as List;
    return list.map((e) => _parseExcuse(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Excuse> getExcuseById(String id) async {
    final response = await apiClient.get('${ApiEndpoints.excuses}/$id');
    return _parseExcuse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelExcuse(String id) async {
    await apiClient.delete('${ApiEndpoints.excuses}/$id');
  }

  @override
  Future<ExcuseAttachment> uploadAttachment(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await apiClient.uploadFile(
      '${ApiEndpoints.excuses}/attachments',
      formData: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return ExcuseAttachment(
      id: data['id'],
      fileName: data['file_name'],
      fileUrl: data['file_url'],
      fileType: data['file_type'],
      fileSize: data['file_size'],
    );
  }

  Excuse _parseExcuse(Map<String, dynamic> data) {
    final attachments = (data['attachments'] as List?)
            ?.map((a) => ExcuseAttachment(
                  id: a['id'],
                  fileName: a['file_name'],
                  fileUrl: a['file_url'],
                  fileType: a['file_type'],
                  fileSize: a['file_size'],
                ))
            .toList() ??
        [];

    return Excuse(
      id: data['id'],
      employeeId: data['employee_id'],
      date: DateTime.parse(data['date']),
      type: ExcuseType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ExcuseType.other,
      ),
      reason: data['reason'],
      attachments: attachments,
      status: ExcuseStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ExcuseStatus.pending,
      ),
      reviewedBy: data['reviewed_by'],
      reviewedAt: data['reviewed_at'] != null
          ? DateTime.parse(data['reviewed_at'])
          : null,
      reviewNotes: data['review_notes'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}

import 'package:equatable/equatable.dart';

/// Clarification status enum
enum ClarificationStatus {
  pending,
  responded,
  closed,
}

/// Clarification request entity (sent by admin to employee)
class Clarification extends Equatable {
  final String id;
  final String employeeId;
  final String requestedBy;
  final String requestedByName;
  final DateTime startDate;
  final DateTime endDate;
  final String question;
  final ClarificationStatus status;
  final String? response;
  final List<ClarificationAttachment> responseAttachments;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime? dueDate;

  const Clarification({
    required this.id,
    required this.employeeId,
    required this.requestedBy,
    required this.requestedByName,
    required this.startDate,
    required this.endDate,
    required this.question,
    required this.status,
    this.response,
    required this.responseAttachments,
    this.respondedAt,
    required this.createdAt,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        requestedBy,
        requestedByName,
        startDate,
        endDate,
        question,
        status,
        response,
        responseAttachments,
        respondedAt,
        createdAt,
        dueDate,
      ];

  bool get isPending => status == ClarificationStatus.pending;
  bool get isResponded => status == ClarificationStatus.responded;
  bool get isClosed => status == ClarificationStatus.closed;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && isPending;
}

/// Clarification attachment
class ClarificationAttachment extends Equatable {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  const ClarificationAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
  });

  @override
  List<Object?> get props => [id, fileName, fileUrl, fileType, fileSize];
}

/// Clarification response request
class ClarificationResponse extends Equatable {
  final String clarificationId;
  final String response;
  final List<String> filePaths;

  const ClarificationResponse({
    required this.clarificationId,
    required this.response,
    required this.filePaths,
  });

  @override
  List<Object?> get props => [clarificationId, response, filePaths];
}

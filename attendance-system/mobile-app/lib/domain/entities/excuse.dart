import 'package:equatable/equatable.dart';

/// Excuse status enum
enum ExcuseStatus {
  pending,
  approved,
  rejected,
}

/// Excuse type enum
enum ExcuseType {
  sick,
  personal,
  emergency,
  other,
}

/// Excuse entity
class Excuse extends Equatable {
  final String id;
  final String employeeId;
  final DateTime date;
  final ExcuseType type;
  final String reason;
  final List<ExcuseAttachment> attachments;
  final ExcuseStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final DateTime createdAt;

  const Excuse({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.type,
    required this.reason,
    required this.attachments,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        date,
        type,
        reason,
        attachments,
        status,
        reviewedBy,
        reviewedAt,
        reviewNotes,
        createdAt,
      ];

  bool get isPending => status == ExcuseStatus.pending;
  bool get isApproved => status == ExcuseStatus.approved;
  bool get isRejected => status == ExcuseStatus.rejected;
}

/// Excuse attachment
class ExcuseAttachment extends Equatable {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;

  const ExcuseAttachment({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
  });

  @override
  List<Object?> get props => [id, fileName, fileUrl, fileType, fileSize];

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Submit excuse request
class ExcuseRequest extends Equatable {
  final DateTime date;
  final ExcuseType type;
  final String reason;
  final List<String> filePaths;

  const ExcuseRequest({
    required this.date,
    required this.type,
    required this.reason,
    required this.filePaths,
  });

  @override
  List<Object?> get props => [date, type, reason, filePaths];
}

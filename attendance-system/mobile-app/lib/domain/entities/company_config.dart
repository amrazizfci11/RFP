import 'package:equatable/equatable.dart';

/// Company configuration for white-label support
class CompanyConfig extends Equatable {
  final String companyId;
  final String companyName;
  final String companyNameAr;
  final String? logo;
  final String? slogan;
  final String? sloganAr;
  final int primaryColor;
  final int secondaryColor;
  final String? address;
  final String? nationalAddress;
  final double? latitude;
  final double? longitude;
  final double attendanceRadius;
  final WorkingHours workingHours;
  final List<int> workingDays;
  final int gracePeriodMinutes;
  final bool requireGps;
  final bool allowBiometric;
  final bool allowNafath;
  final bool isActive;

  const CompanyConfig({
    required this.companyId,
    required this.companyName,
    required this.companyNameAr,
    this.logo,
    this.slogan,
    this.sloganAr,
    required this.primaryColor,
    required this.secondaryColor,
    this.address,
    this.nationalAddress,
    this.latitude,
    this.longitude,
    required this.attendanceRadius,
    required this.workingHours,
    required this.workingDays,
    required this.gracePeriodMinutes,
    required this.requireGps,
    required this.allowBiometric,
    required this.allowNafath,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        companyId,
        companyName,
        companyNameAr,
        logo,
        slogan,
        sloganAr,
        primaryColor,
        secondaryColor,
        address,
        nationalAddress,
        latitude,
        longitude,
        attendanceRadius,
        workingHours,
        workingDays,
        gracePeriodMinutes,
        requireGps,
        allowBiometric,
        allowNafath,
        isActive,
      ];

  bool get hasLocation => latitude != null && longitude != null;
}

/// Working hours configuration
class WorkingHours extends Equatable {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const WorkingHours({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  @override
  List<Object?> get props => [startHour, startMinute, endHour, endMinute];

  String get formattedStart =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get formattedEnd =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  Duration get duration {
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    return Duration(minutes: endMinutes - startMinutes);
  }
}

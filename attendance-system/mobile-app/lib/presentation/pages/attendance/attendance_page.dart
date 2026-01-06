import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/attendance.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_overlay.dart';

/// Main attendance page with check-in/check-out functionality
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  StreamSubscription<Position>? _locationSubscription;
  bool _isLocationLoading = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'attendance.location_permission_denied'.tr();
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'attendance.location_permission_forever'.tr();
          _isLocationLoading = false;
        });
        return;
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'attendance.location_service_disabled'.tr();
          _isLocationLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        context.read<AttendanceBloc>().add(AttendanceLocationUpdated(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
            ));

        setState(() => _isLocationLoading = false);

        // Start listening to location updates
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (mounted) {
            context.read<AttendanceBloc>().add(AttendanceLocationUpdated(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  accuracy: position.accuracy,
                ));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString();
          _isLocationLoading = false;
        });
      }
    }
  }

  void _onCheckIn() {
    context.read<AttendanceBloc>().add(const AttendanceCheckInRequested());
  }

  void _onCheckOut() {
    context.read<AttendanceBloc>().add(const AttendanceCheckOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceActionStatus.checkedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('attendance.checked_in_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == AttendanceActionStatus.checkedOut) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('attendance.checked_out_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == AttendanceActionStatus.error &&
            state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: state.isCheckingIn || state.isCheckingOut,
          child: Scaffold(
            appBar: AppBar(
              title: Text('attendance.title'.tr()),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context
                        .read<AttendanceBloc>()
                        .add(const AttendanceRefreshRequested());
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AttendanceBloc>()
                    .add(const AttendanceRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User greeting
                    _GreetingCard(userName: user?.name ?? ''),

                    const SizedBox(height: 16),

                    // Today's status card
                    _TodayStatusCard(
                      todayAttendance: state.todayAttendance,
                      isLoading: state.isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Location status
                    _LocationStatusCard(
                      isWithinVicinity: state.isWithinVicinity,
                      isLoading: _isLocationLoading,
                      error: _locationError,
                      accuracy: state.locationAccuracy,
                      companyLocation: state.todayAttendance?.companyLocation,
                    ),

                    const SizedBox(height: 24),

                    // Check-in/Check-out button
                    _AttendanceActionButton(
                      canCheckIn: state.canCheckIn,
                      canCheckOut: state.canCheckOut,
                      isWithinVicinity: state.isWithinVicinity,
                      hasCheckedIn: state.hasCheckedIn,
                      hasCheckedOut: state.hasCheckedOut,
                      onCheckIn: _onCheckIn,
                      onCheckOut: _onCheckOut,
                    ),

                    const SizedBox(height: 24),

                    // Work schedule info
                    if (state.todayAttendance?.workSchedule != null)
                      _WorkScheduleCard(
                        workSchedule: state.todayAttendance!.workSchedule,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String userName;

  const _GreetingCard({required this.userName});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'attendance.good_morning';
    if (hour < 17) return 'attendance.good_afternoon';
    return 'attendance.good_evening';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('EEEE', 'ar').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat('dd MMM yyyy', 'ar').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  final TodayAttendance? todayAttendance;
  final bool isLoading;

  const _TodayStatusCard({
    this.todayAttendance,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final record = todayAttendance?.record;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'attendance.today_status'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.login,
                    label: 'attendance.check_in'.tr(),
                    value: record?.checkInTime != null
                        ? DateFormat('hh:mm a').format(record!.checkInTime!)
                        : '--:--',
                    isActive: record?.checkInTime != null,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.grey300,
                ),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.logout,
                    label: 'attendance.check_out'.tr(),
                    value: record?.checkOutTime != null
                        ? DateFormat('hh:mm a').format(record!.checkOutTime!)
                        : '--:--',
                    isActive: record?.checkOutTime != null,
                  ),
                ),
              ],
            ),
            if (record != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'attendance.working_hours'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    record.formattedWorkingHours,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isActive;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: isActive ? AppColors.success : AppColors.grey400,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isActive ? null : AppColors.grey400,
              ),
        ),
      ],
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  final bool isWithinVicinity;
  final bool isLoading;
  final String? error;
  final double? accuracy;
  final CompanyLocation? companyLocation;

  const _LocationStatusCard({
    required this.isWithinVicinity,
    required this.isLoading,
    this.error,
    this.accuracy,
    this.companyLocation,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isLoading) {
      statusColor = AppColors.grey500;
      statusIcon = Icons.location_searching;
      statusText = 'attendance.getting_location'.tr();
    } else if (error != null) {
      statusColor = AppColors.error;
      statusIcon = Icons.location_off;
      statusText = error!;
    } else if (isWithinVicinity) {
      statusColor = AppColors.success;
      statusIcon = Icons.location_on;
      statusText = 'attendance.within_vicinity'.tr();
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.location_off;
      statusText = 'attendance.outside_vicinity'.tr();
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                        ),
                  ),
                  if (accuracy != null)
                    Text(
                      'attendance.accuracy'.tr(args: ['${accuracy!.toInt()}']),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  final bool canCheckIn;
  final bool canCheckOut;
  final bool isWithinVicinity;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _AttendanceActionButton({
    required this.canCheckIn,
    required this.canCheckOut,
    required this.isWithinVicinity,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    if (hasCheckedIn && hasCheckedOut) {
      return Card(
        color: AppColors.success.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'attendance.completed'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final bool isCheckIn = canCheckIn && !hasCheckedIn;
    final bool isEnabled = isWithinVicinity && (canCheckIn || canCheckOut);

    return SizedBox(
      height: 160,
      child: ElevatedButton(
        onPressed: isEnabled
            ? (isCheckIn ? onCheckIn : onCheckOut)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCheckIn ? AppColors.success : AppColors.warning,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCheckIn ? Icons.login : Icons.logout,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              isCheckIn
                  ? 'attendance.check_in_button'.tr()
                  : 'attendance.check_out_button'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (!isWithinVicinity)
              Text(
                'attendance.move_closer'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkScheduleCard extends StatelessWidget {
  final WorkSchedule workSchedule;

  const _WorkScheduleCard({required this.workSchedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'attendance.work_schedule'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScheduleItem(
                  label: 'attendance.start_time'.tr(),
                  value: workSchedule.checkInTime.format(),
                ),
                _ScheduleItem(
                  label: 'attendance.end_time'.tr(),
                  value: workSchedule.checkOutTime.format(),
                ),
                _ScheduleItem(
                  label: 'attendance.grace_period'.tr(),
                  value: '${workSchedule.gracePeriod.inMinutes} min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String label;
  final String value;

  const _ScheduleItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/attendance/attendance_bloc.dart';
import '../attendance/attendance_page.dart';
import '../excuse/excuse_list_page.dart';
import '../vacation/vacation_list_page.dart';
import '../reports/reports_page.dart';
import '../profile/profile_page.dart';

/// Home page with bottom navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AttendancePage(),
    ExcuseListPage(),
    VacationListPage(),
    ReportsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load today's attendance status
    context.read<AttendanceBloc>().add(const AttendanceLoadTodayRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.fingerprint_outlined),
              activeIcon: const Icon(Icons.fingerprint),
              label: 'nav.attendance'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event_busy_outlined),
              activeIcon: const Icon(Icons.event_busy),
              label: 'nav.excuse'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.beach_access_outlined),
              activeIcon: const Icon(Icons.beach_access),
              label: 'nav.vacation'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assessment_outlined),
              activeIcon: const Icon(Icons.assessment),
              label: 'nav.reports'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: 'nav.profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

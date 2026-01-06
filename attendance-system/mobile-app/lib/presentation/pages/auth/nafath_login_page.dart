import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_overlay.dart';
import '../home/home_page.dart';

/// Nafath authentication page
class NafathLoginPage extends StatefulWidget {
  const NafathLoginPage({super.key});

  @override
  State<NafathLoginPage> createState() => _NafathLoginPageState();
}

class _NafathLoginPageState extends State<NafathLoginPage> {
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 60; // 3 minutes at 3-second intervals

  @override
  void initState() {
    super.initState();
    // Initiate Nafath authentication
    context.read<AuthBloc>().add(const AuthNafathInitiated());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingAttempts = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollingAttempts++;
      if (_pollingAttempts >= _maxPollingAttempts) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('nafath.timeout'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      context.read<AuthBloc>().add(const AuthNafathVerificationRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.nafathPending) {
          _startPolling();
        } else if (state.status == AuthStatus.authenticated) {
          _pollingTimer?.cancel();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else if (state.hasError) {
          _pollingTimer?.cancel();
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
          isLoading: state.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: Text('nafath.title'.tr()),
              backgroundColor: const Color(0xFF006B3F),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Nafath logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006B3F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        size: 56,
                        color: Color(0xFF006B3F),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'nafath.verify_title'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Instructions
                    Text(
                      'nafath.instructions'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Random number display
                    if (state.nafathSession != null) ...[
                      Text(
                        'nafath.random_number'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF006B3F).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          state.nafathSession!.random,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: const Color(0xFF006B3F),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Waiting indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF006B3F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'nafath.waiting'.tr(),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF006B3F),
                                    ),
                          ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Instructions steps
                    _InstructionStep(
                      number: '1',
                      text: 'nafath.step1'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _InstructionStep(
                      number: '2',
                      text: 'nafath.step2'.tr(),
                    ),
                    const SizedBox(height: 12),
                    _InstructionStep(
                      number: '3',
                      text: 'nafath.step3'.tr(),
                    ),

                    const SizedBox(height: 24),

                    // Cancel button
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('nafath.cancel'.tr()),
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

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF006B3F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF006B3F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

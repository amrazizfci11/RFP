import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_overlay.dart';
import '../home/home_page.dart';

/// OTP verification page
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = AppConstants.otpResendInterval.inSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = AppConstants.otpResendInterval.inSeconds;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onVerify() {
    if (_otpController.text.length == AppConstants.otpLength) {
      context.read<AuthBloc>().add(
            AuthOtpVerificationRequested(otp: _otpController.text),
          );
    }
  }

  void _onResend() {
    if (_canResend) {
      context.read<AuthBloc>().add(const AuthOtpResendRequested());
      _startTimer();
    }
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final maskedMobile = state.tempUser?.mobile.replaceRange(
          3,
          state.tempUser!.mobile.length - 2,
          '*' * (state.tempUser!.mobile.length - 5),
        );

        return LoadingOverlay(
          isLoading: state.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: Text('otp.title'.tr()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Icon
                    Icon(
                      Icons.sms_outlined,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'otp.verify_title'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle with masked mobile
                    Text(
                      'otp.verify_subtitle'.tr(args: [maskedMobile ?? '']),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // OTP input
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        controller: _otpController,
                        length: AppConstants.otpLength,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: 56,
                          fieldWidth: 48,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: AppColors.grey300,
                          selectedColor: Theme.of(context).primaryColor,
                        ),
                        enableActiveFill: true,
                        onCompleted: (_) => _onVerify(),
                        onChanged: (_) {},
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Verify button
                    ElevatedButton(
                      onPressed: _otpController.text.length ==
                              AppConstants.otpLength
                          ? _onVerify
                          : null,
                      child: Text('otp.verify_button'.tr()),
                    ),

                    const SizedBox(height: 24),

                    // Resend section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'otp.didnt_receive'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        if (_canResend)
                          TextButton(
                            onPressed: _onResend,
                            child: Text('otp.resend'.tr()),
                          )
                        else
                          Text(
                            'otp.resend_in'.tr(args: [_formattedTime]),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
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

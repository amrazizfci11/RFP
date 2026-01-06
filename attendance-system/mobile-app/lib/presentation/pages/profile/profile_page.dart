import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../auth/login_page.dart';

/// Profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.title'.tr()),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? '',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.jobTitle ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.grey600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.companyName ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Personal info
              Card(
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.badge_outlined,
                      label: 'profile.iqama'.tr(),
                      value: user?.iqama ?? '',
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'profile.email'.tr(),
                      value: user?.email ?? '',
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'profile.mobile'.tr(),
                      value: user?.mobile ?? '',
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.business_outlined,
                      label: 'profile.department'.tr(),
                      value: user?.department ?? '-',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Settings section
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'profile.settings'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),

                    // Theme
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return ListTile(
                          leading: const Icon(Icons.brightness_6_outlined),
                          title: Text('profile.theme'.tr()),
                          trailing: DropdownButton<ThemeMode>(
                            value: settingsState.themeMode,
                            underline: const SizedBox(),
                            onChanged: (mode) {
                              if (mode != null) {
                                context
                                    .read<SettingsBloc>()
                                    .add(SettingsThemeModeChanged(mode));
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Text('profile.theme_system'.tr()),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('profile.theme_light'.tr()),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('profile.theme_dark'.tr()),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Language
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text('profile.language'.tr()),
                      trailing: DropdownButton<String>(
                        value: context.locale.languageCode,
                        underline: const SizedBox(),
                        onChanged: (locale) {
                          if (locale != null) {
                            context.setLocale(Locale(locale));
                            context
                                .read<SettingsBloc>()
                                .add(SettingsLocaleChanged(locale));
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text('العربية'),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Notifications
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return SwitchListTile(
                          secondary: const Icon(Icons.notifications_outlined),
                          title: Text('profile.notifications'.tr()),
                          value: settingsState.notificationsEnabled,
                          onChanged: (enabled) {
                            context
                                .read<SettingsBloc>()
                                .add(SettingsNotificationsToggled(enabled));
                          },
                        );
                      },
                    ),
                    const Divider(height: 1),

                    // Biometric
                    if (authState.isBiometricAvailable)
                      SwitchListTile(
                        secondary: const Icon(Icons.fingerprint),
                        title: Text('profile.biometric'.tr()),
                        subtitle: Text('profile.biometric_desc'.tr()),
                        value: authState.isBiometricEnabled,
                        onChanged: (enabled) {
                          if (enabled) {
                            context.read<AuthBloc>().add(
                                  const AuthBiometricRegistrationRequested(),
                                );
                          }
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Logout button
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout),
                label: Text('profile.logout'.tr()),
              ),

              const SizedBox(height: 32),

              // App version
              Center(
                child: Text(
                  'profile.version'.tr(args: ['1.0.0']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('profile.logout_title'.tr()),
        content: Text('profile.logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('profile.logout'.tr()),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

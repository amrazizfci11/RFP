part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final String locale;
  final bool notificationsEnabled;
  final Color primaryColor;
  final Color secondaryColor;
  final String? companyLogo;
  final String? companyName;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = 'ar',
    this.notificationsEnabled = true,
    this.primaryColor = const Color(0xFF1E88E5),
    this.secondaryColor = const Color(0xFF26A69A),
    this.companyLogo,
    this.companyName,
  });

  @override
  List<Object?> get props => [
        themeMode,
        locale,
        notificationsEnabled,
        primaryColor,
        secondaryColor,
        companyLogo,
        companyName,
      ];

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? locale,
    bool? notificationsEnabled,
    Color? primaryColor,
    Color? secondaryColor,
    String? companyLogo,
    String? companyName,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      companyLogo: companyLogo ?? this.companyLogo,
      companyName: companyName ?? this.companyName,
    );
  }
}

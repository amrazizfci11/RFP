part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class SettingsThemeModeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  const SettingsThemeModeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SettingsLocaleChanged extends SettingsEvent {
  final String locale;

  const SettingsLocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

class SettingsCompanyConfigLoaded extends SettingsEvent {
  final Color primaryColor;
  final Color secondaryColor;
  final String? companyLogo;
  final String? companyName;

  const SettingsCompanyConfigLoaded({
    required this.primaryColor,
    required this.secondaryColor,
    this.companyLogo,
    this.companyName,
  });

  @override
  List<Object?> get props => [primaryColor, secondaryColor, companyLogo, companyName];
}

class SettingsNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsNotificationsToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

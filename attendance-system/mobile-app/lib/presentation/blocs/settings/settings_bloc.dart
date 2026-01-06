import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/settings_local_datasource.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Settings BLoC for app configuration and theming
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsLocalDataSource settingsLocalDataSource;

  SettingsBloc({
    required this.settingsLocalDataSource,
  }) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsThemeModeChanged>(_onThemeModeChanged);
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsCompanyConfigLoaded>(_onCompanyConfigLoaded);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final themeMode = await settingsLocalDataSource.getThemeMode();
    final locale = await settingsLocalDataSource.getLocale();
    final notificationsEnabled =
        await settingsLocalDataSource.areNotificationsEnabled();
    final primaryColor = await settingsLocalDataSource.getPrimaryColor();
    final secondaryColor = await settingsLocalDataSource.getSecondaryColor();
    final companyLogo = await settingsLocalDataSource.getCompanyLogo();
    final companyName = await settingsLocalDataSource.getCompanyName();

    emit(state.copyWith(
      themeMode: themeMode,
      locale: locale,
      notificationsEnabled: notificationsEnabled,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      companyLogo: companyLogo,
      companyName: companyName,
    ));
  }

  Future<void> _onThemeModeChanged(
    SettingsThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsLocalDataSource.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsLocalDataSource.setLocale(event.locale);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onCompanyConfigLoaded(
    SettingsCompanyConfigLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsLocalDataSource.setPrimaryColor(event.primaryColor);
    await settingsLocalDataSource.setSecondaryColor(event.secondaryColor);
    if (event.companyLogo != null) {
      await settingsLocalDataSource.setCompanyLogo(event.companyLogo!);
    }
    if (event.companyName != null) {
      await settingsLocalDataSource.setCompanyName(event.companyName!);
    }

    emit(state.copyWith(
      primaryColor: event.primaryColor,
      secondaryColor: event.secondaryColor,
      companyLogo: event.companyLogo,
      companyName: event.companyName,
    ));
  }

  Future<void> _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    await settingsLocalDataSource.setNotificationsEnabled(event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }
}

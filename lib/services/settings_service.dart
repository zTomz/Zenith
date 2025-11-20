import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._();

  SettingsService._();

  late Box _box;
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  Future<void> init() async {
    try {
      _box = await Hive.openBox('settings');
    } catch (e) {
      // In case of corruption or type mismatch (e.g. dev changes), reset the box.
      try {
        await Hive.deleteBoxFromDisk('settings');
      } catch (_) {
        // Ignore deletion errors (e.g. file not found)
      }
      _box = await Hive.openBox('settings');
    }
    final savedTheme = _box.get('themeMode', defaultValue: 'system');
    themeMode.value = _parseThemeMode(savedTheme);
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _box.put('themeMode', modeStr);
  }
}

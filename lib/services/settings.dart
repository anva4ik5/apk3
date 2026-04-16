import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _notifyMessages = 'notify_messages';
  static const _notifyMentions = 'notify_mentions';
  static const _notifyChannels = 'notify_channels';
  static const _soundEnabled = 'notification_sound';
  static const _vibrationEnabled = 'notification_vibration';
  static const _darkMode = 'dark_mode';
  static const _fontSize = 'font_size';
  static const _biometric = 'biometric_enabled';
  static const _twoStep = 'two_step_enabled';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<bool> getNotifyMessages() async => (await _prefs()).getBool(_notifyMessages) ?? true;
  static Future<bool> getNotifyMentions() async => (await _prefs()).getBool(_notifyMentions) ?? true;
  static Future<bool> getNotifyChannels() async => (await _prefs()).getBool(_notifyChannels) ?? false;
  static Future<bool> getSoundEnabled() async => (await _prefs()).getBool(_soundEnabled) ?? true;
  static Future<bool> getVibrationEnabled() async => (await _prefs()).getBool(_vibrationEnabled) ?? true;
  static Future<bool> getDarkMode() async => (await _prefs()).getBool(_darkMode) ?? true;
  static Future<double> getFontSize() async => (await _prefs()).getDouble(_fontSize) ?? 14.5;

  static Future<void> setNotifyMessages(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_notifyMessages, value);
  }

  static Future<void> setNotifyMentions(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_notifyMentions, value);
  }

  static Future<void> setNotifyChannels(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_notifyChannels, value);
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_soundEnabled, value);
  }

  static Future<void> setVibrationEnabled(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_vibrationEnabled, value);
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_darkMode, value);
  }

  static Future<void> setFontSize(double value) async {
    final prefs = await _prefs();
    await prefs.setDouble(_fontSize, value);
  }

  static Future<bool> getBiometric() async => (await _prefs()).getBool(_biometric) ?? false;
  static Future<bool> getTwoStep() async => (await _prefs()).getBool(_twoStep) ?? false;

  static Future<void> setBiometric(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_biometric, value);
  }

  static Future<void> setTwoStep(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_twoStep, value);
  }
}

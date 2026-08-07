import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderNotificationPreferences extends Equatable {
  const ReminderNotificationPreferences({
    this.enabled = true,
    this.hour = 9,
    this.minute = 0,
  });

  static const defaults = ReminderNotificationPreferences();

  final bool enabled;
  final int hour;
  final int minute;

  ReminderNotificationPreferences copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return ReminderNotificationPreferences(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  List<Object?> get props => [enabled, hour, minute];
}

class ReminderNotificationPreferenceStore {
  ReminderNotificationPreferenceStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences,
      _memoryOnly = false;

  ReminderNotificationPreferenceStore.memory({
    ReminderNotificationPreferences? initial,
  }) : _preferences = null,
       _memoryOnly = true,
       _memoryValue = initial ?? ReminderNotificationPreferences.defaults;

  static const _enabledKey = 'reminder_notifications_enabled';
  static const _hourKey = 'reminder_notifications_hour';
  static const _minuteKey = 'reminder_notifications_minute';

  final SharedPreferencesAsync? _preferences;
  final bool _memoryOnly;
  ReminderNotificationPreferences _memoryValue =
      ReminderNotificationPreferences.defaults;
  SharedPreferencesAsync? _lazyPreferences;

  SharedPreferencesAsync get _prefs =>
      _preferences ?? (_lazyPreferences ??= SharedPreferencesAsync());

  Future<ReminderNotificationPreferences> read() async {
    if (_memoryOnly) return _memoryValue;

    final enabled = await _prefs.getBool(_enabledKey);
    final hour = await _prefs.getInt(_hourKey);
    final minute = await _prefs.getInt(_minuteKey);
    return ReminderNotificationPreferences(
      enabled: enabled ?? ReminderNotificationPreferences.defaults.enabled,
      hour: hour ?? ReminderNotificationPreferences.defaults.hour,
      minute: minute ?? ReminderNotificationPreferences.defaults.minute,
    );
  }

  Future<void> write(ReminderNotificationPreferences value) async {
    if (_memoryOnly) {
      _memoryValue = value;
      return;
    }
    await _prefs.setBool(_enabledKey, value.enabled);
    await _prefs.setInt(_hourKey, value.hour);
    await _prefs.setInt(_minuteKey, value.minute);
  }
}

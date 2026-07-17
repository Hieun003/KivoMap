import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  AppPreferencesService._();
  static final AppPreferencesService _instance = AppPreferencesService._();
  factory AppPreferencesService() => _instance;

  static const String _audioEnabledKey = 'kivo.audio_enabled.v1';
  final RxBool audioEnabled = true.obs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final preferences = await SharedPreferences.getInstance();
    audioEnabled.value = preferences.getBool(_audioEnabledKey) ?? true;
    _isInitialized = true;
  }

  Future<void> setAudioEnabled(bool enabled) async {
    await initialize();
    audioEnabled.value = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_audioEnabledKey, enabled);
  }
}

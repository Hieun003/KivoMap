import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import 'app_preferences_service.dart';

class TtsService {
  TtsService._();

  static final TtsService _instance = TtsService._();
  static TtsService get instance => _instance;

  final FlutterTts _tts = FlutterTts();
  final AppPreferencesService _preferences = AppPreferencesService();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> _init() async {
    if (_isInitialized) return;

    // iOS: cần setSharedInstance để audio không bị chặn bởi silent mode
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.35);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);

    _isInitialized = true;
  }

  Future<void> speak(String text, {double pitch = 1.0}) async {
    await _preferences.initialize();
    if (!_preferences.audioEnabled.value) return;
    await _init();
    if (_isSpeaking) await _tts.stop();
    await _tts.setPitch(pitch);
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }
}

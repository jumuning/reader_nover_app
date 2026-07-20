import 'package:flutter_tts/flutter_tts.dart';

import 'system_tts_engine.dart';
import 'tts_contracts.dart';

export 'tts_contracts.dart';

/// System text-to-speech facade used by the reader.
class TtsService {
  TtsService({FlutterTts? flutterTts, TtsPlaybackEngine? engine})
      : _engine = engine ?? SystemTtsEngine(flutterTts: flutterTts);

  final TtsPlaybackEngine _engine;
  double _rate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String? _voiceName;

  TtsStatusCallback? _onStart;
  TtsStatusCallback? _onComplete;
  TtsErrorCallback? _onError;
  TtsProgressCallback? _onProgress;

  TtsStatusCallback? get onStart => _onStart;
  set onStart(TtsStatusCallback? callback) {
    _onStart = callback;
    _engine.onStart = callback;
  }

  TtsStatusCallback? get onComplete => _onComplete;
  set onComplete(TtsStatusCallback? callback) {
    _onComplete = callback;
    _engine.onComplete = callback;
  }

  TtsErrorCallback? get onError => _onError;
  set onError(TtsErrorCallback? callback) {
    _onError = callback;
    _engine.onError = callback;
  }

  TtsProgressCallback? get onProgress => _onProgress;
  set onProgress(TtsProgressCallback? callback) {
    _onProgress = callback;
    _engine.onProgress = callback;
  }

  Future<void> init() => _engine.init();

  Future<void> setRate(double value) async {
    _rate = value.clamp(0.1, 1.0);
    await _engine.setRate(_rate);
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.5, 2.0);
    await _engine.setPitch(_pitch);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _engine.setVolume(_volume);
  }

  Future<void> setVoiceByName(String? voiceName) async {
    final normalized = voiceName?.trim();
    if (normalized == null || normalized.isEmpty) return;
    _voiceName = normalized;
    await _engine.setVoiceByName(normalized);
  }

  Future<List<TtsVoiceOption>> loadVoices() => _engine.loadVoices();

  Future<void> speak({required String text, String? voiceName}) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;
    await _engine.speak(
      TtsEngineSpeakRequest(
        text: normalizedText,
        voiceName:
            voiceName?.trim().isNotEmpty == true ? voiceName : _voiceName,
        rate: _rate,
        pitch: _pitch,
        volume: _volume,
      ),
    );
  }

  Future<void> preload({required String text}) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return;
    await _engine.preload(
      TtsEngineSpeakRequest(
        text: normalizedText,
        voiceName: _voiceName,
        rate: _rate,
        pitch: _pitch,
        volume: _volume,
      ),
    );
  }

  Future<void> pause() => _engine.pause();
  Future<void> stop() => _engine.stop();
  Future<void> dispose() => _engine.dispose();
}

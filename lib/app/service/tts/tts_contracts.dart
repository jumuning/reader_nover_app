typedef TtsStatusCallback = void Function();
typedef TtsErrorCallback = void Function(String message);
typedef TtsProgressCallback = void Function(TtsSpeechProgress progress);

class TtsVoiceOption {
  const TtsVoiceOption({
    required this.name,
    this.locale,
    this.identifier,
    this.quality,
    this.gender,
    this.displayName,
    this.description,
    this.networkRequired = false,
    this.features = const <String>[],
  });

  final String name;
  final String? locale;
  final String? identifier;
  final String? quality;
  final String? gender;
  final String? displayName;
  final String? description;
  final bool networkRequired;
  final List<String> features;

  bool get isChinese => (locale ?? '').toLowerCase().startsWith('zh');

  Map<String, String> toPlatformVoicePayload() {
    return <String, String>{
      'name': name,
      if (locale != null && locale!.isNotEmpty) 'locale': locale!,
      if (identifier != null && identifier!.isNotEmpty)
        'identifier': identifier!,
    };
  }
}

class TtsSpeechProgress {
  const TtsSpeechProgress({
    required this.text,
    required this.start,
    required this.end,
    required this.word,
  });

  final String text;
  final int start;
  final int end;
  final String word;
}

class TtsEngineSpeakRequest {
  const TtsEngineSpeakRequest({
    required this.text,
    required this.voiceName,
    required this.rate,
    required this.pitch,
    required this.volume,
  });

  final String text;
  final String? voiceName;
  final double rate;
  final double pitch;
  final double volume;
}

abstract class TtsPlaybackEngine {
  TtsStatusCallback? onStart;
  TtsStatusCallback? onComplete;
  TtsErrorCallback? onError;
  TtsProgressCallback? onProgress;

  Future<void> init();
  Future<List<TtsVoiceOption>> loadVoices();
  Future<void> setRate(double value);
  Future<void> setPitch(double value);
  Future<void> setVolume(double value);
  Future<void> setVoiceByName(String? voiceName);
  Future<void> speak(TtsEngineSpeakRequest request);
  Future<void> preload(TtsEngineSpeakRequest request);
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

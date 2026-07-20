import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_audio_session.dart';
import 'tts_contracts.dart';

class SystemTtsEngine implements TtsPlaybackEngine {
  SystemTtsEngine({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  bool _initialized = false;
  String? _currentVoiceName;

  @override
  TtsStatusCallback? onStart;

  @override
  TtsStatusCallback? onComplete;

  @override
  TtsErrorCallback? onError;

  @override
  TtsProgressCallback? onProgress;

  @override
  Future<void> init() async {
    if (_initialized) return;

    _flutterTts.setStartHandler(() {
      onStart?.call();
    });
    _flutterTts.setCompletionHandler(() {
      onComplete?.call();
    });
    _flutterTts.setCancelHandler(() {});
    _flutterTts.setErrorHandler((message) {
      onError?.call(message);
    });
    _flutterTts.setProgressHandler((text, start, end, word) {
      onProgress?.call(
        TtsSpeechProgress(
          text: text,
          start: start,
          end: end,
          word: word,
        ),
      );
    });

    await _configurePlatformTts();
    await _flutterTts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> _configurePlatformTts() async {
    await TtsAudioSession.configureForSpeechPlayback();

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        await _ignoreUnsupportedPlatformCall(() async {
          await _flutterTts.setSharedInstance(true);
        });
        await _ignoreUnsupportedPlatformCall(() async {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            const <IosTextToSpeechAudioCategoryOptions>[
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.allowAirPlay,
            ],
            IosTextToSpeechAudioMode.spokenAudio,
          );
        });
        break;
      case TargetPlatform.android:
        await _ignoreUnsupportedPlatformCall(() async {
          await _flutterTts.setQueueMode(0);
        });
        break;
      default:
        break;
    }
  }

  Future<void> _ignoreUnsupportedPlatformCall(
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on MissingPluginException {
      // 当前平台或插件版本未实现该 TTS 能力时，跳过平台增强配置。
    } on UnimplementedError {
      // 同上。
    }
  }

  @override
  Future<void> setRate(double value) async {
    await _flutterTts.setSpeechRate(value.clamp(0.1, 1.0));
  }

  @override
  Future<void> setPitch(double value) async {
    await _flutterTts.setPitch(value.clamp(0.5, 2.0));
  }

  @override
  Future<void> setVolume(double value) async {
    await _flutterTts.setVolume(value.clamp(0.0, 1.0));
  }

  @override
  Future<void> setVoiceByName(String? voiceName) async {
    final normalized = voiceName?.trim();
    if (normalized == null || normalized.isEmpty) return;
    if (_currentVoiceName == normalized) return;

    final voices = await loadVoices();
    TtsVoiceOption? match;
    for (final voice in voices) {
      if (voice.name == normalized) {
        match = voice;
        break;
      }
    }
    if (match == null) return;

    await _flutterTts.setVoice(match.toPlatformVoicePayload());
    _currentVoiceName = normalized;
  }

  @override
  Future<List<TtsVoiceOption>> loadVoices() async {
    final dynamic result = await _flutterTts.getVoices;
    if (result is! List) return const <TtsVoiceOption>[];

    final dedup = <String, TtsVoiceOption>{};
    for (final item in result) {
      if (item is! Map) continue;
      final name = item['name']?.toString().trim() ?? '';
      if (name.isEmpty) continue;
      final locale = item['locale']?.toString().trim();
      final identifier = item['identifier']?.toString().trim();
      final quality = item['quality']?.toString().trim();
      final gender = item['gender']?.toString().trim();
      final networkRequired = item['network_required']?.toString() == '1';
      final features = item['features']
              ?.toString()
              .split('\t')
              .map((feature) => feature.trim())
              .where((feature) => feature.isNotEmpty)
              .toList() ??
          const <String>[];
      final voice = TtsVoiceOption(
        name: name,
        locale: locale,
        identifier: identifier,
        quality: quality,
        gender: gender,
        networkRequired: networkRequired,
        features: features,
      );
      final key = '$name|${locale ?? ''}';
      final existing = dedup[key];
      if (existing == null || _compareVoicePriority(voice, existing) < 0) {
        dedup[key] = voice;
      }
    }

    final options = dedup.values.toList();
    options.sort(_compareVoiceSort);
    return options;
  }

  @override
  Future<void> speak(TtsEngineSpeakRequest request) async {
    final text = request.text.trim();
    if (text.isEmpty) return;
    await setVoiceByName(request.voiceName);
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  Future<void> preload(TtsEngineSpeakRequest request) async {}

  @override
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  int _compareVoicePriority(TtsVoiceOption left, TtsVoiceOption right) {
    final qualityDiff =
        _qualityRank(right.quality) - _qualityRank(left.quality);
    if (qualityDiff != 0) return qualityDiff;

    final networkDiff =
        (left.networkRequired ? 1 : 0) - (right.networkRequired ? 1 : 0);
    if (networkDiff != 0) return networkDiff;

    final identifierScore = (right.identifier?.isNotEmpty == true ? 1 : 0) -
        (left.identifier?.isNotEmpty == true ? 1 : 0);
    return identifierScore;
  }

  int _compareVoiceSort(TtsVoiceOption left, TtsVoiceOption right) {
    if (left.isChinese != right.isChinese) {
      return left.isChinese ? -1 : 1;
    }

    final networkDiff =
        (left.networkRequired ? 1 : 0) - (right.networkRequired ? 1 : 0);
    if (networkDiff != 0) return networkDiff;

    final qualityDiff =
        _qualityRank(right.quality) - _qualityRank(left.quality);
    if (qualityDiff != 0) return qualityDiff;

    final localeDiff = (left.locale ?? '').compareTo(right.locale ?? '');
    if (localeDiff != 0) return localeDiff;
    return left.name.compareTo(right.name);
  }

  int _qualityRank(String? quality) {
    switch (quality?.trim().toLowerCase()) {
      case 'premium':
      case 'very high':
        return 4;
      case 'enhanced':
      case 'high':
        return 3;
      case 'default':
      case 'normal':
        return 2;
      case 'low':
        return 1;
      case 'very low':
        return 0;
      default:
        return -1;
    }
  }
}

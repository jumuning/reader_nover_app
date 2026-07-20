import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TtsAudioSession {
  const TtsAudioSession._();

  static bool _configured = false;

  static Future<void> configureForSpeechPlayback() async {
    if (_configured || kIsWeb) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return;
    }

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _configured = true;
    } on MissingPluginException {
      // 平台插件不可用时跳过，避免影响 TTS 初始化。
    } on UnimplementedError {
      // 当前平台或插件版本未实现该能力时跳过。
    }
  }
}

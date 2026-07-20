import 'package:flutter/foundation.dart';

import '../state.dart';

class BookReadUiRefreshController {
  static const String contentUpdateId = 'book-read-content';
  static const String shellUpdateId = 'book-read-shell';
  static const String chromeUpdateId = 'book-read-chrome';
  static const String overlayUpdateId = 'book-read-overlay';
  static const String ttsFloatingUpdateId = 'book-read-tts-floating';

  BookReadUiRefreshController({
    required BookReadState state,
    required void Function(List<Object> ids) updater,
  })  : _state = state,
        _updater = updater,
        pageTurnStateListenable = ValueNotifier(
          BookReadPageTurnStateSnapshot.fromState(state),
        ),
        textHighlightStateListenable = ValueNotifier(
          BookReadTextHighlightStateSnapshot.fromState(state),
        );

  final BookReadState _state;
  final void Function(List<Object> ids) _updater;
  final ValueNotifier<BookReadPageTurnStateSnapshot> pageTurnStateListenable;
  final ValueNotifier<BookReadTextHighlightStateSnapshot>
      textHighlightStateListenable;

  void content() => _updater(const <Object>[contentUpdateId]);

  void chrome() => _updater(const <Object>[chromeUpdateId]);

  void overlay() => _updater(const <Object>[overlayUpdateId]);

  void ttsFloating() => _updater(const <Object>[ttsFloatingUpdateId]);

  void animation() {
    final current = pageTurnStateListenable.value;
    if (current.isAnimating == _state.isAnimating &&
        current.isNext == _state.isNext &&
        current.targetPage == _state.targetPage) {
      return;
    }
    pageTurnStateListenable.value =
        BookReadPageTurnStateSnapshot.fromState(_state);
  }

  void playbackHighlight() {
    final next = BookReadTextHighlightStateSnapshot.fromState(_state);
    if (textHighlightStateListenable.value == next) {
      return;
    }
    textHighlightStateListenable.value = next;
  }

  void chromeAndTtsFloating() =>
      _updater(const <Object>[chromeUpdateId, ttsFloatingUpdateId]);

  void chromeAndOverlay() =>
      _updater(const <Object>[chromeUpdateId, overlayUpdateId]);

  void contentAndChrome() =>
      _updater(const <Object>[contentUpdateId, chromeUpdateId]);

  void contentChromeAndOverlay() => _updater(
        const <Object>[contentUpdateId, chromeUpdateId, overlayUpdateId],
      );

  void contentAndTtsFloating() {
    playbackHighlight();
    _updater(const <Object>[contentUpdateId, ttsFloatingUpdateId]);
  }

  void ttsFloatingAndHighlight() {
    playbackHighlight();
    _updater(const <Object>[ttsFloatingUpdateId]);
  }

  void all() {
    animation();
    playbackHighlight();
    _updater(
      const <Object>[
        shellUpdateId,
        contentUpdateId,
        chromeUpdateId,
        overlayUpdateId,
        ttsFloatingUpdateId,
      ],
    );
  }

  void dispose() {
    pageTurnStateListenable.dispose();
    textHighlightStateListenable.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/rust/api/rule_engine.dart';
import 'package:reader_nover/util/analyze_url_utils.dart';

import 'source_http.dart';
import 'source_variable_store.dart';

typedef SourceLoginExecutionRunner = Future<Map<String, String>> Function({
  required db.BookSource source,
  required Map<String, String> sourceHeaders,
});

class SourceLoginExecuteResult {
  const SourceLoginExecuteResult({
    required this.executed,
    required this.success,
  });

  const SourceLoginExecuteResult.skipped()
      : executed = false,
        success = false;

  const SourceLoginExecuteResult.done()
      : executed = true,
        success = true;

  final bool executed;
  final bool success;
}

class SourceLoginExecutor {
  const SourceLoginExecutor._();

  static SourceLoginExecutionRunner _runner = _runLoginScript;

  @visibleForTesting
  static void setTestRunner(SourceLoginExecutionRunner? runner) {
    _runner = runner ?? _runLoginScript;
  }

  static Future<SourceLoginExecuteResult> execute(db.BookSource source) async {
    final loginUrl = source.loginUrl?.trim() ?? '';
    if (loginUrl.isEmpty || !_hasLoginFunction(loginUrl)) {
      return const SourceLoginExecuteResult.skipped();
    }

    final sourceHeaders = await SourceHttp.buildSourceHeaders(source);
    final variables = await _runner(
      source: source,
      sourceHeaders: sourceHeaders,
    );

    await AnalyzeUrlUtils.syncUpdatedVarsToCookieJar(variables);
    await SourceVariableStore.syncFromCookieJar(
      source.bookSourceUrl,
      source.bookSourceUrl,
    );
    await SourceHttp.persistRuleVariables(source, variables);
    return const SourceLoginExecuteResult.done();
  }

  static Future<Map<String, String>> _runLoginScript({
    required db.BookSource source,
    required Map<String, String> sourceHeaders,
  }) async {
    final loginUrl = source.loginUrl?.trim() ?? '';
    final engine = await SourceHttp.newRuleEngine(
      source,
      sourceHeaders: sourceHeaders,
    );
    await engine.setSourceVar(
      key: '__reader_source_login_url',
      value: loginUrl,
    );

    await SourceHttp.runWithWebViewBridge<void>(
      source: source,
      engine: engine,
      sourceHeaders: sourceHeaders,
      parse: () async {
        await _callSourceLogin(engine);
      },
    );

    return SourceHttp.snapshotRuleVariables(engine);
  }

  static bool _hasLoginFunction(String loginUrl) {
    return RegExp(r'\bfunction\s+login\s*\(', caseSensitive: false)
        .hasMatch(loginUrl);
  }

  static Future<void> _callSourceLogin(RuleEngine engine) async {
    await engine.parseExploreKinds(
      exploreUrl: '@js:source.login(); "__reader_source_login_done";',
    );
  }
}

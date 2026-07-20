import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/rust/entities/rules.dart';
import 'package:reader_nover/util/log_utils.dart';

import 'source_http.dart';

/// 封面 / 正文图片解密（对齐 Legado `ImageUtils.decode` 的最小实现）。
///
/// - 无脚本：直接返回下载字节
/// - 有脚本：把 `src` + base64(`result`) 注入 JS，期望返回 base64 / hex / dataURL
class SourceImageDecoder {
  SourceImageDecoder._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.bytes,
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
    ),
  );

  /// 加载并可选解密封面。
  static Future<Uint8List?> loadCoverBytes({
    required db.BookSource source,
    required String imageUrl,
    CancelToken? cancelToken,
  }) async {
    return _loadAndDecode(
      source: source,
      imageUrl: imageUrl,
      decodeJs: source.coverDecodeJs,
      cancelToken: cancelToken,
    );
  }

  /// 加载并可选解密正文图片（ContentRule.imageDecode）。
  static Future<Uint8List?> loadContentImageBytes({
    required db.BookSource source,
    required String imageUrl,
    String? imageDecodeJs,
    CancelToken? cancelToken,
  }) async {
    return _loadAndDecode(
      source: source,
      imageUrl: imageUrl,
      decodeJs: imageDecodeJs,
      cancelToken: cancelToken,
    );
  }

  static Future<Uint8List?> _loadAndDecode({
    required db.BookSource source,
    required String imageUrl,
    required String? decodeJs,
    CancelToken? cancelToken,
  }) async {
    final url = imageUrl.trim();
    if (url.isEmpty) return null;

    try {
      final headers = await SourceHttp.buildSourceHeaders(source);
      final response = await _dio.get<List<int>>(
        url,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      final raw = response.data;
      if (raw == null || raw.isEmpty) return null;
      final bytes = Uint8List.fromList(raw);

      final script = decodeJs?.trim() ?? '';
      if (script.isEmpty) return bytes;

      final decoded = await _runDecodeJs(
        source: source,
        script: script,
        src: url,
        bytes: bytes,
      );
      return decoded ?? bytes;
    } catch (e, st) {
      LogUtils.e('图片加载/解密失败: $url', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<Uint8List?> _runDecodeJs({
    required db.BookSource source,
    required String script,
    required String src,
    required Uint8List bytes,
  }) async {
    final engine = await SourceHttp.newRuleEngine(source);
    final inputB64 = base64Encode(bytes);
    await engine.setSourceVar(key: 'src', value: src);
    await engine.setSourceVar(key: '__reader_image_src', value: src);
    await engine.setSourceVar(key: '__reader_image_b64', value: inputB64);

    final body = _unwrapJs(script);
    try {
      // Preferred path: binary result injected as JS byte array (Legado style).
      final outB64 = await engine.evalBytesJs(
        script: body,
        inputBase64: inputB64,
        baseUrl: source.bookSourceUrl,
        src: src,
      );
      final decoded = _decodeToBytes(outB64);
      if (decoded != null && decoded.isNotEmpty) {
        return decoded;
      }
    } catch (e) {
      LogUtils.d('evalBytesJs 失败，回退字符串路径: $e');
    }

    // Fallback: string-based eval via extractBookInfo rule.
    await engine.setSourceVar(key: 'result', value: inputB64);
    final rule = body.toLowerCase().startsWith('@js:') ||
            body.toLowerCase().startsWith('<js>')
        ? body
        : '@js:$body';
    final info = await SourceHttp.runWithWebViewBridge(
      source: source,
      engine: engine,
      parse: () => engine.extractBookInfo(
        html: '',
        rule: BookInfoRule(name: rule),
        baseUrl: src,
      ),
    );
    final vars = await SourceHttp.snapshotRuleVariables(engine);
    final out = (info?.name.trim().isNotEmpty == true)
        ? info!.name.trim()
        : (vars['result']?.trim().isNotEmpty == true
            ? vars['result']!.trim()
            : vars['__reader_image_out']?.trim());
    if (out == null || out.isEmpty) return null;
    return _decodeToBytes(out);
  }

  static String _unwrapJs(String script) {
    final text = script.trim();
    final lower = text.toLowerCase();
    if (lower.startsWith('@js:')) return text.substring(4).trim();
    if (lower.startsWith('<js>')) {
      final end = lower.lastIndexOf('</js>');
      if (end > 4) return text.substring(4, end).trim();
      return text.substring(4).trim();
    }
    return text;
  }

  static Uint8List? _decodeToBytes(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;

    // data:image/...;base64,xxxx
    final dataUrl = RegExp(r'^data:.*?;base64,(.+)$', caseSensitive: false)
        .firstMatch(text);
    if (dataUrl != null) {
      text = dataUrl.group(1)!.trim();
    }

    // hex
    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(text) && text.length % 2 == 0) {
      try {
        final out = Uint8List(text.length ~/ 2);
        for (var i = 0; i < out.length; i++) {
          out[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
        }
        return out;
      } catch (_) {}
    }

    try {
      return Uint8List.fromList(base64Decode(text));
    } catch (_) {
      return null;
    }
  }
}

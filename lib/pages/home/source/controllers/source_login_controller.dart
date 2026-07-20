import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:reader_nover/app/service/source/source_login_executor.dart';
import 'package:reader_nover/app/service/source/source_login_service.dart';
import 'package:reader_nover/app/service/source/source_variable_store.dart';

import '../../../../app/database/drift/app_database.dart';
import '../webview/login_webview_page.dart';

class SourceLoginController {
  const SourceLoginController();

  bool hasOpenableSourceLoginEntry(BookSource source) {
    return _buildLoginEntries(source).isNotEmpty;
  }

  Future<bool> openSourceLogin(BookSource source) async {
    final entries = _buildLoginEntries(source);
    if (entries.isEmpty) {
      Get.snackbar(
        '书源登录',
        '未解析到可用登录地址',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return false;
    }

    _SourceLoginEntry? selected;
    if (entries.length == 1) {
      selected = entries.first;
    } else {
      selected = await Get.bottomSheet<_SourceLoginEntry>(
        SafeArea(
          child: Material(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '选择登录入口',
                    style: Get.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                ...entries.map(
                  (entry) => ListTile(
                    title: Text(entry.title),
                    subtitle: Text(
                      entry.type == _SourceLoginEntryType.form
                          ? '填写登录信息'
                          : entry.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Icon(
                      entry.type == _SourceLoginEntryType.form
                          ? Icons.assignment_ind
                          : Icons.login,
                    ),
                    onTap: () => Get.back(result: entry),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      );
    }
    if (selected == null) return false;

    if (selected.type == _SourceLoginEntryType.form) {
      final saved = await _openLoginUiForm(source, selected.loginUi!);
      if (saved != true) return false;

      final SourceLoginExecuteResult result;
      try {
        result = await SourceLoginExecutor.execute(source);
      } catch (_) {
        Get.snackbar(
          '书源登录',
          '登录脚本执行失败',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return false;
      }
      Get.snackbar(
        '书源登录',
        result.executed ? '登录脚本已执行' : '登录信息已保存',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return true;
    }

    final result = await Get.to<SourceLoginWebViewResult>(
      () => SourceLoginWebViewPage(
        title: selected!.title,
        url: selected.url,
        sourceKey: source.bookSourceUrl,
      ),
    );
    if (result?.success != true) return false;

    final variable = await SourceVariableStore.get(
      source.bookSourceUrl,
      sourceUrl: selected.url,
      preferCookieJar: true,
    );
    final cookieDesc = variable.isEmpty ? '未检测到 Cookie' : 'Cookie 已写入';
    Get.snackbar(
      '书源登录',
      cookieDesc,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
    return true;
  }

  List<_SourceLoginEntry> _buildLoginEntries(BookSource source) {
    final loginUi = SourceLoginService.parseLoginUi(source.loginUi);
    final formEntries = loginUi == null
        ? const <_SourceLoginEntry>[]
        : [
            _SourceLoginEntry.form(
              title: '表单登录',
              loginUi: loginUi,
            ),
          ];

    final loginScript = source.loginUrl?.trim() ?? '';
    if (loginScript.isEmpty) return formEntries;

    final constants = _parseJsStringConstants(
      '${source.jsLib ?? ''}\n$loginScript',
    );
    final entries = <_SourceLoginEntry>[...formEntries];
    final dedup = <String>{};

    final fnReg = RegExp(
      r'function\s+([A-Za-z_]\w*)\s*\([^)]*\)\s*\{([\s\S]*?)\}',
      multiLine: true,
    );
    for (final fn in fnReg.allMatches(loginScript)) {
      final fnName = fn.group(1) ?? '';
      final body = fn.group(2) ?? '';
      final action = _extractStartBrowserAction(body, constants);
      if (action == null) continue;
      final key = '${action.url}|${action.title}';
      if (!dedup.add(key)) continue;
      entries.add(
        _SourceLoginEntry.web(
          title: action.title.isNotEmpty ? action.title : fnName,
          url: action.url,
        ),
      );
    }

    if (entries.length > formEntries.length) return entries;

    final action = _extractStartBrowserAction(loginScript, constants);
    if (action != null) {
      entries.add(
        _SourceLoginEntry.web(
          title: action.title.isNotEmpty ? action.title : '登录入口',
          url: action.url,
        ),
      );
    }
    if (entries.length > formEntries.length) return entries;

    final rawHttpReg = RegExp(r'''https?://[^\s'"\\]+''');
    for (final match in rawHttpReg.allMatches(loginScript)) {
      final url = match.group(0) ?? '';
      if (url.isEmpty || !dedup.add(url)) continue;
      entries.add(_SourceLoginEntry.web(title: '登录入口', url: url));
    }
    return entries;
  }

  Future<bool?> _openLoginUiForm(
    BookSource source,
    SourceLoginUiSchema loginUi,
  ) async {
    final existing = SourceLoginService.parseLoginInfoMap(
      await SourceLoginService.getLoginInfo(source.bookSourceUrl),
    );
    final controllers = <SourceLoginUiField, TextEditingController>{};
    for (final field in loginUi.fields) {
      controllers[field] = TextEditingController(
        text: existing[field.key] ?? field.defaultValue,
      );
    }

    try {
      return await Get.dialog<bool>(
        _SourceLoginUiDialog(
          sourceName: source.bookSourceName,
          fields: loginUi.fields,
          controllers: controllers,
          onSubmit: () async {
            final values = <String, String>{};
            for (final field in loginUi.fields) {
              values[field.key] = controllers[field]?.text.trim() ?? '';
            }
            await SourceLoginService.saveLoginUiInfo(
              source.bookSourceUrl,
              values,
            );
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  _ParsedLoginAction? _extractStartBrowserAction(
    String script,
    Map<String, String> constants,
  ) {
    final reg = RegExp(
      r'''startBrowserAwait\s*\(\s*([^,]+?)\s*(?:,\s*(['"])(.*?)\2)?\s*\)''',
      caseSensitive: false,
      multiLine: true,
    );
    final match = reg.firstMatch(script);
    if (match == null) return null;
    final expr = (match.group(1) ?? '').trim();
    final title = (match.group(3) ?? '').trim();
    final url = _resolveJsUrlExpr(expr, constants);
    if (!_isHttpUrl(url)) return null;
    return _ParsedLoginAction(title: title, url: url);
  }

  Map<String, String> _parseJsStringConstants(String script) {
    final map = <String, String>{};
    final reg = RegExp(
      r'''(?:const|let|var)\s+([A-Za-z_]\w*)\s*=\s*(['"])(.*?)\2\s*;?''',
      multiLine: true,
    );
    for (final match in reg.allMatches(script)) {
      final name = match.group(1);
      final value = match.group(3);
      if (name == null || value == null) continue;
      map[name] = value;
    }
    return map;
  }

  String _resolveJsUrlExpr(String expr, Map<String, String> constants) {
    var value = expr.trim();
    if (value.endsWith(';')) {
      value = value.substring(0, value.length - 1).trim();
    }
    if (value.startsWith('(') && value.endsWith(')') && value.length > 2) {
      value = value.substring(1, value.length - 1).trim();
    }

    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    if (value.startsWith('`') && value.endsWith('`') && value.length > 2) {
      var template = value.substring(1, value.length - 1);
      template = template.replaceAllMapped(
        RegExp(r'\$\{\s*([A-Za-z_]\w*)\s*\}'),
        (match) => constants[match.group(1)] ?? '',
      );
      return template;
    }

    if (value.contains('+')) {
      final parts = value.split('+');
      final output = StringBuffer();
      for (final part in parts) {
        output.write(_resolveJsUrlExpr(part, constants));
      }
      return output.toString().trim();
    }

    final idReg = RegExp(r'^[A-Za-z_]\w*$');
    if (idReg.hasMatch(value)) {
      return constants[value] ?? '';
    }
    return value;
  }

  bool _isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}

enum _SourceLoginEntryType {
  form,
  web,
}

class _SourceLoginEntry {
  const _SourceLoginEntry._({
    required this.title,
    required this.type,
    required this.url,
    required this.loginUi,
  });

  const _SourceLoginEntry.form({
    required String title,
    required SourceLoginUiSchema loginUi,
  }) : this._(
          title: title,
          type: _SourceLoginEntryType.form,
          url: '',
          loginUi: loginUi,
        );

  const _SourceLoginEntry.web({
    required String title,
    required String url,
  }) : this._(
          title: title,
          type: _SourceLoginEntryType.web,
          url: url,
          loginUi: null,
        );

  final String title;
  final _SourceLoginEntryType type;
  final String url;
  final SourceLoginUiSchema? loginUi;
}

class _ParsedLoginAction {
  const _ParsedLoginAction({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;
}

class _SourceLoginUiDialog extends StatefulWidget {
  const _SourceLoginUiDialog({
    required this.sourceName,
    required this.fields,
    required this.controllers,
    required this.onSubmit,
  });

  final String sourceName;
  final List<SourceLoginUiField> fields;
  final Map<SourceLoginUiField, TextEditingController> controllers;
  final Future<void> Function() onSubmit;

  @override
  State<_SourceLoginUiDialog> createState() => _SourceLoginUiDialogState();
}

class _SourceLoginUiDialogState extends State<_SourceLoginUiDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _submitting = true;
    });
    try {
      await widget.onSubmit();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sourceName.isEmpty ? '表单登录' : widget.sourceName),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in widget.fields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: widget.controllers[field],
                      obscureText: field.obscureText,
                      keyboardType: _keyboardTypeFor(field.type),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText:
                            field.required ? '${field.label} *' : field.label,
                        hintText: field.hint.isEmpty ? null : field.hint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (field.required &&
                            (value == null || value.trim().isEmpty)) {
                          return '请输入${field.label}';
                        }
                        return null;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('提交'),
        ),
      ],
    );
  }

  TextInputType _keyboardTypeFor(String type) {
    switch (type.toLowerCase()) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'tel':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}

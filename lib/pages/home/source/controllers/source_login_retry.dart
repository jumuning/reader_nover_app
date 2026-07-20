import 'package:reader_nover/app/service/source/source_login_service.dart';

/// 统一「登录后只重试一次」骨架，避免各页面复制粘贴。
Future<T> runWithSourceLoginRetry<T>({
  required Future<T> Function() action,
  required Future<bool> Function(SourceLoginRequiredException error) openLogin,
  void Function()? beforeRetry,
}) async {
  try {
    return await action();
  } on SourceLoginRequiredException catch (error) {
    final ok = await openLogin(error);
    if (!ok) rethrow;
    beforeRetry?.call();
    return action();
  }
}

bool isSourceLoginRequiredServiceErrorCode(String code) {
  return code.endsWith('.login_required') || code.contains('login_required');
}

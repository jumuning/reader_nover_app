class AppPattern {
  // 静态常量定义
  static final jsPattern = RegExp(
    r'<js>([\w\W]*?)</js>|@js:([\w\W]*)',
    caseSensitive: false,
  );

  static final expPattern = RegExp(r'\{\{([\w\W]*?)\}\}');

  // 匹配格式化后的图片格式
  static final imgPattern =
      RegExp(r'<img[^>]*src="([^"]*(?:"[^>]+\\})?)"[^>]*>');

  // dataURL图片类型
  static final dataUriRegex = RegExp(r'^data:.*?;base64,(.*)');

  static final nameRegex = RegExp(r'\s+作\s*者.*|\s+\S+\s+著');
  static final authorRegex = RegExp(r'^\s*作\s*者[:：\s]+|\s+著');
  static final fileNameRegex = RegExp(r'[\\/:*?"<>|.]');
  static final splitGroupRegex = RegExp(r'[,;，；]');
  static final titleNumPattern = RegExp(r'(第)(.+?)(章)');

  // 书源调试信息中的各种符号
  static final debugMessageSymbolRegex = RegExp(r'[⇒◇┌└≡]');

  // 本地书籍支持类型
  static final bookFileRegex = RegExp(
    r'.*\.(txt|epub|umd|pdf|mobi|azw3|azw)',
    caseSensitive: false,
  );

  // 压缩文件支持类型
  static final archiveFileRegex =
      RegExp(r'.*\.(zip|rar|7z)$', caseSensitive: false);

  //所有标点
  static final bdRegex = RegExp(r'(\p{P})+');

  //换行
  static final rnRegex = RegExp(r'[\r\n]');

  //不发音段落判断
  static final notReadAloudRegex = RegExp(r'^(\s|\p{C}|\p{P}|\p{Z}|\p{S})+$');

  static final xmlContentTypeRegex = RegExp(r'(application|text)/\w*\+?xml.*');

  static final semicolonRegex = RegExp(r';');

  static final equalsRegex = RegExp(r'=');

  static final spaceRegex = RegExp(r'\s+');

  static final regexCharRegex = RegExp(r'[{}()\[\].+*?^$\\|]');

  static final lfRegex = RegExp(r'\n');

  static final httpReg = RegExp(r'^((https?|ftp):\/\/)?([a-zA-Z0-9_-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$');
}

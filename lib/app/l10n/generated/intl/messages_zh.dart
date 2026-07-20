// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(book) => "《${book}》已加入书架";

  static String m1(number) => "第 ${number} 章";

  static String m2(book) => "继续阅读：${book}";

  static String m3(count) => "${count} 天";

  static String m4(path) => "EPUB 缺少资源：${path}";

  static String m5(count) => "连续达标 ${count} 天";

  static String m6(count) => "${count} 小时";

  static String m7(hours, minutes) => "${hours} 小时 ${minutes} 分";

  static String m8(count) => "最长 ${count} 天";

  static String m9(minutes) => "${minutes}分钟";

  static String m10(page) => "第${page}页";

  static String m11(count) => "${count} 次会话";

  static String m12(total, cleanable, missing, metadata, covers, external) =>
      "共发现 ${total} 个问题。\n\n可安全修复：${cleanable}\n文件缺失：${missing}\n文件信息异常：${metadata}\n封面缺失：${covers}\n非应用管理路径：${external}\n\n自动修复仅处理应用目录内的临时文件、生成封面和可重建缓存，不会删除用户原文件或普通本地书籍文件。";

  static String m13(count, size) =>
      "已处理 ${count} 个临时、缓存或封面问题，释放 ${size}。\n\n用户原文件和普通本地书籍文件未被删除。";

  static String m14(count) => "${count} 次";

  static String m15(duration) => "今日已达标，建议再读 ${duration}";

  static String m16(remaining, suggested) =>
      "还差 ${remaining}，建议本次阅读 ${suggested}";

  static String m17(count) => "本周达标 ${count} 天";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addNote": MessageLookupByLibrary.simpleMessage("添加笔记"),
    "adjustGoal": MessageLookupByLibrary.simpleMessage("调整目标"),
    "annotations": MessageLookupByLibrary.simpleMessage("批注"),
    "ascending": MessageLookupByLibrary.simpleMessage("正序"),
    "averageDuration": MessageLookupByLibrary.simpleMessage("平均时长"),
    "background": MessageLookupByLibrary.simpleMessage("背景"),
    "bookAddedToShelf": m0,
    "bookSources": MessageLookupByLibrary.simpleMessage("书源"),
    "bookStore": MessageLookupByLibrary.simpleMessage("书城"),
    "bookmarkEmptyHint": MessageLookupByLibrary.simpleMessage("阅读时点击书签按钮可添加"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("书签"),
    "bookshelf": MessageLookupByLibrary.simpleMessage("书架"),
    "brightness": MessageLookupByLibrary.simpleMessage("亮度"),
    "cache": MessageLookupByLibrary.simpleMessage("缓存"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "chapterError": MessageLookupByLibrary.simpleMessage("章节错误"),
    "chapterNumber": m1,
    "clear": MessageLookupByLibrary.simpleMessage("清除"),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "continueReadingBook": m2,
    "cover": MessageLookupByLibrary.simpleMessage("覆盖"),
    "customFont": MessageLookupByLibrary.simpleMessage("自定义字体"),
    "dailyReadingGoal": MessageLookupByLibrary.simpleMessage("每日阅读目标"),
    "daysCount": m3,
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "descending": MessageLookupByLibrary.simpleMessage("倒序"),
    "directory": MessageLookupByLibrary.simpleMessage("目录"),
    "disabled": MessageLookupByLibrary.simpleMessage("禁用"),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "editNote": MessageLookupByLibrary.simpleMessage("编辑笔记"),
    "emptyFileCannotImport": MessageLookupByLibrary.simpleMessage(
      "文件内容为空，无法导入",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("启用"),
    "epubExpandedTooLarge": MessageLookupByLibrary.simpleMessage(
      "EPUB 解压后的内容过大，已停止导入",
    ),
    "epubFileNotFound": MessageLookupByLibrary.simpleMessage(
      "EPUB 文件不存在，请重新选择",
    ),
    "epubFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "EPUB 文件过大，暂不支持导入",
    ),
    "epubManifestMissing": MessageLookupByLibrary.simpleMessage("EPUB 缺少内容清单"),
    "epubNoReadableChapters": MessageLookupByLibrary.simpleMessage(
      "EPUB 未解析到可阅读章节",
    ),
    "epubResourceMissing": m4,
    "epubUnsafeResourcePath": MessageLookupByLibrary.simpleMessage(
      "EPUB 包含不安全的资源路径",
    ),
    "eyeProtection": MessageLookupByLibrary.simpleMessage("护眼模式"),
    "fileNotFoundReselect": MessageLookupByLibrary.simpleMessage("文件不存在，请重新选择"),
    "flip": MessageLookupByLibrary.simpleMessage("翻页"),
    "fontSelectionTitle": MessageLookupByLibrary.simpleMessage("字体选择"),
    "goalStreakDays": m5,
    "highlights": MessageLookupByLibrary.simpleMessage("高亮"),
    "hoursCount": m6,
    "hoursMinutesCount": m7,
    "importFailed": MessageLookupByLibrary.simpleMessage("导入失败"),
    "importPathUnavailable": MessageLookupByLibrary.simpleMessage("无法读取所选文件路径"),
    "importRetryLater": MessageLookupByLibrary.simpleMessage("导入失败，请稍后重试"),
    "importSucceeded": MessageLookupByLibrary.simpleMessage("导入成功"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "languageChinese": MessageLookupByLibrary.simpleMessage("简体中文"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "lastRead": MessageLookupByLibrary.simpleMessage("上次"),
    "lastSevenDays": MessageLookupByLibrary.simpleMessage("近 7 日"),
    "letterSpacing": MessageLookupByLibrary.simpleMessage("字间距"),
    "lineSpacing": MessageLookupByLibrary.simpleMessage("行间距"),
    "loading": MessageLookupByLibrary.simpleMessage("正在加载"),
    "localStorageCheck": MessageLookupByLibrary.simpleMessage("本地书籍存储检查"),
    "localStorageCheckSubtitle": MessageLookupByLibrary.simpleMessage(
      "检查缺失文件并安全清理临时缓存",
    ),
    "longestDays": m8,
    "minutesCount": m9,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "nextChapter": MessageLookupByLibrary.simpleMessage("下一章"),
    "noAnimation": MessageLookupByLibrary.simpleMessage("无动画"),
    "noAnnotations": MessageLookupByLibrary.simpleMessage("暂无批注"),
    "noBookmarks": MessageLookupByLibrary.simpleMessage("暂无书签"),
    "noReadingRecords": MessageLookupByLibrary.simpleMessage("还没有阅读记录"),
    "notNow": MessageLookupByLibrary.simpleMessage("暂不处理"),
    "note": MessageLookupByLibrary.simpleMessage("笔记"),
    "ok": MessageLookupByLibrary.simpleMessage("确定"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "pageMargin": MessageLookupByLibrary.simpleMessage("页面边距"),
    "pageN": m10,
    "pageTurn": MessageLookupByLibrary.simpleMessage("翻页"),
    "previousChapter": MessageLookupByLibrary.simpleMessage("上一章"),
    "readFromHere": MessageLookupByLibrary.simpleMessage("从这里朗读"),
    "readFromHereSubtitle": MessageLookupByLibrary.simpleMessage(
      "从本段第一句开始继续朗读",
    ),
    "readingMode": MessageLookupByLibrary.simpleMessage("阅读模式"),
    "readingSessions": MessageLookupByLibrary.simpleMessage("阅读会话"),
    "readingStats": MessageLookupByLibrary.simpleMessage("阅读统计"),
    "readingStatsLoadFailed": MessageLookupByLibrary.simpleMessage("阅读统计加载失败"),
    "readingStatsSubtitle": MessageLookupByLibrary.simpleMessage(
      "时长、连续阅读与书籍排行",
    ),
    "readingStreak": MessageLookupByLibrary.simpleMessage("连续阅读"),
    "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "reloadTheme": MessageLookupByLibrary.simpleMessage("重新加载主题配置"),
    "remark": MessageLookupByLibrary.simpleMessage("备注"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "safeRepair": MessageLookupByLibrary.simpleMessage("安全修复"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "sessionsCount": m11,
    "setting": MessageLookupByLibrary.simpleMessage("设置"),
    "simulation": MessageLookupByLibrary.simpleMessage("仿真"),
    "slide": MessageLookupByLibrary.simpleMessage("平移"),
    "spacingSettings": MessageLookupByLibrary.simpleMessage("间距设置"),
    "startReadingAloud": MessageLookupByLibrary.simpleMessage("开始朗读"),
    "statsByBook": MessageLookupByLibrary.simpleMessage("按书统计"),
    "storageCheckFailed": MessageLookupByLibrary.simpleMessage("存储检查失败"),
    "storageCheckFailedMessage": MessageLookupByLibrary.simpleMessage(
      "暂时无法检查本地书籍存储，请稍后重试",
    ),
    "storageCheckTitle": MessageLookupByLibrary.simpleMessage("本地书籍存储检查"),
    "storageCleanupComplete": MessageLookupByLibrary.simpleMessage("清理完成"),
    "storageHealthy": MessageLookupByLibrary.simpleMessage("未发现存储问题。"),
    "storageIssuesSummary": m12,
    "storageRepairCompleteMessage": m13,
    "supportedLocalFormats": MessageLookupByLibrary.simpleMessage(
      "仅支持 TXT 和 EPUB 文件",
    ),
    "systemFont": MessageLookupByLibrary.simpleMessage("系统字体"),
    "timesCount": m14,
    "tips": MessageLookupByLibrary.simpleMessage("提示"),
    "todayGoalReached": m15,
    "todayGoalRemaining": m16,
    "todayPlan": MessageLookupByLibrary.simpleMessage("今日计划"),
    "totalReadingTime": MessageLookupByLibrary.simpleMessage("总阅读时长"),
    "txtFileTooLarge": MessageLookupByLibrary.simpleMessage("TXT 文件过大，暂不支持导入"),
    "underline": MessageLookupByLibrary.simpleMessage("下划线"),
    "unnamedLocalBook": MessageLookupByLibrary.simpleMessage("未命名本地书籍"),
    "vertical": MessageLookupByLibrary.simpleMessage("上下"),
    "warning": MessageLookupByLibrary.simpleMessage("警告"),
    "weekGoalDays": m17,
    "writeYourThoughts": MessageLookupByLibrary.simpleMessage("写下你的想法"),
  };
}

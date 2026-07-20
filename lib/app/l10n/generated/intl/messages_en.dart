// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(book) => "${book} was added to your bookshelf";

  static String m1(number) => "Chapter ${number}";

  static String m2(book) => "Continue reading: ${book}";

  static String m3(count) => "${count} days";

  static String m4(path) => "EPUB resource is missing: ${path}";

  static String m5(count) => "Goal streak: ${count} days";

  static String m6(count) => "${count} hr";

  static String m7(hours, minutes) => "${hours} hr ${minutes} min";

  static String m8(count) => "Longest: ${count} days";

  static String m9(minutes) => "${minutes} min";

  static String m10(page) => "Page ${page}";

  static String m11(count) => "${count} sessions";

  static String m12(total, cleanable, missing, metadata, covers, external) =>
      "Found ${total} issues.\n\nSafe to repair: ${cleanable}\nMissing files: ${missing}\nFile metadata issues: ${metadata}\nMissing covers: ${covers}\nPaths outside app storage: ${external}\n\nAutomatic repair only handles temporary files, generated covers, and rebuildable cache inside app storage. It never deletes original user files or regular local book files.";

  static String m13(count, size) =>
      "Handled ${count} temporary, cache, or cover issues and reclaimed ${size}.\n\nOriginal user files and regular local book files were not deleted.";

  static String m14(count) => "${count} times";

  static String m15(duration) =>
      "Goal reached. Suggested extra reading: ${duration}";

  static String m16(remaining, suggested) =>
      "${remaining} remaining. Suggested session: ${suggested}";

  static String m17(count) => "Weekly goal: ${count} days";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addNote": MessageLookupByLibrary.simpleMessage("Add note"),
    "adjustGoal": MessageLookupByLibrary.simpleMessage("Adjust goal"),
    "annotations": MessageLookupByLibrary.simpleMessage("Annotations"),
    "ascending": MessageLookupByLibrary.simpleMessage("Ascending"),
    "averageDuration": MessageLookupByLibrary.simpleMessage("Average duration"),
    "background": MessageLookupByLibrary.simpleMessage("Background"),
    "bookAddedToShelf": m0,
    "bookSources": MessageLookupByLibrary.simpleMessage("Sources"),
    "bookStore": MessageLookupByLibrary.simpleMessage("Discover"),
    "bookmarkEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Tap the bookmark button while reading to add one",
    ),
    "bookmarks": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "bookshelf": MessageLookupByLibrary.simpleMessage("Bookshelf"),
    "brightness": MessageLookupByLibrary.simpleMessage("Brightness"),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "chapterError": MessageLookupByLibrary.simpleMessage("Invalid chapter"),
    "chapterNumber": m1,
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "continueReadingBook": m2,
    "cover": MessageLookupByLibrary.simpleMessage("Cover"),
    "customFont": MessageLookupByLibrary.simpleMessage("Custom font"),
    "dailyReadingGoal": MessageLookupByLibrary.simpleMessage(
      "Daily reading goal",
    ),
    "daysCount": m3,
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "descending": MessageLookupByLibrary.simpleMessage("Descending"),
    "directory": MessageLookupByLibrary.simpleMessage("Contents"),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "editNote": MessageLookupByLibrary.simpleMessage("Edit note"),
    "emptyFileCannotImport": MessageLookupByLibrary.simpleMessage(
      "The file is empty and cannot be imported",
    ),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "epubExpandedTooLarge": MessageLookupByLibrary.simpleMessage(
      "The expanded EPUB content is too large to import safely",
    ),
    "epubFileNotFound": MessageLookupByLibrary.simpleMessage(
      "EPUB file not found. Please select it again.",
    ),
    "epubFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "This EPUB file is too large to import",
    ),
    "epubManifestMissing": MessageLookupByLibrary.simpleMessage(
      "The EPUB package manifest is missing",
    ),
    "epubNoReadableChapters": MessageLookupByLibrary.simpleMessage(
      "No readable chapters were found in the EPUB",
    ),
    "epubResourceMissing": m4,
    "epubUnsafeResourcePath": MessageLookupByLibrary.simpleMessage(
      "The EPUB contains an unsafe resource path",
    ),
    "eyeProtection": MessageLookupByLibrary.simpleMessage("Eye comfort"),
    "fileNotFoundReselect": MessageLookupByLibrary.simpleMessage(
      "File not found. Please select it again.",
    ),
    "flip": MessageLookupByLibrary.simpleMessage("Turn page"),
    "fontSelectionTitle": MessageLookupByLibrary.simpleMessage("Choose font"),
    "goalStreakDays": m5,
    "highlights": MessageLookupByLibrary.simpleMessage("Highlight"),
    "hoursCount": m6,
    "hoursMinutesCount": m7,
    "importFailed": MessageLookupByLibrary.simpleMessage("Import failed"),
    "importPathUnavailable": MessageLookupByLibrary.simpleMessage(
      "Unable to read the selected file path",
    ),
    "importRetryLater": MessageLookupByLibrary.simpleMessage(
      "Import failed. Please try again later.",
    ),
    "importSucceeded": MessageLookupByLibrary.simpleMessage("Import complete"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageChinese": MessageLookupByLibrary.simpleMessage("简体中文"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageSystem": MessageLookupByLibrary.simpleMessage("System default"),
    "lastRead": MessageLookupByLibrary.simpleMessage("Last read"),
    "lastSevenDays": MessageLookupByLibrary.simpleMessage("Last 7 days"),
    "letterSpacing": MessageLookupByLibrary.simpleMessage("Letter spacing"),
    "lineSpacing": MessageLookupByLibrary.simpleMessage("Line spacing"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading"),
    "localStorageCheck": MessageLookupByLibrary.simpleMessage(
      "Local book storage check",
    ),
    "localStorageCheckSubtitle": MessageLookupByLibrary.simpleMessage(
      "Find missing files and safely clear temporary cache",
    ),
    "longestDays": m8,
    "minutesCount": m9,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "nextChapter": MessageLookupByLibrary.simpleMessage("Next chapter"),
    "noAnimation": MessageLookupByLibrary.simpleMessage("No animation"),
    "noAnnotations": MessageLookupByLibrary.simpleMessage("No annotations yet"),
    "noBookmarks": MessageLookupByLibrary.simpleMessage("No bookmarks yet"),
    "noReadingRecords": MessageLookupByLibrary.simpleMessage(
      "No reading records yet",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Not now"),
    "note": MessageLookupByLibrary.simpleMessage("Note"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "pageMargin": MessageLookupByLibrary.simpleMessage("Page margins"),
    "pageN": m10,
    "pageTurn": MessageLookupByLibrary.simpleMessage("Page turn"),
    "previousChapter": MessageLookupByLibrary.simpleMessage("Previous chapter"),
    "readFromHere": MessageLookupByLibrary.simpleMessage("Read from here"),
    "readFromHereSubtitle": MessageLookupByLibrary.simpleMessage(
      "Continue reading aloud from the first sentence here",
    ),
    "readingMode": MessageLookupByLibrary.simpleMessage("Reading mode"),
    "readingSessions": MessageLookupByLibrary.simpleMessage("Reading sessions"),
    "readingStats": MessageLookupByLibrary.simpleMessage("Reading statistics"),
    "readingStatsLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to load reading statistics",
    ),
    "readingStatsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Time, streaks, and book ranking",
    ),
    "readingStreak": MessageLookupByLibrary.simpleMessage("Reading streak"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "reloadTheme": MessageLookupByLibrary.simpleMessage(
      "Reload theme configuration",
    ),
    "remark": MessageLookupByLibrary.simpleMessage("Remark"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "safeRepair": MessageLookupByLibrary.simpleMessage("Repair safely"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "sessionsCount": m11,
    "setting": MessageLookupByLibrary.simpleMessage("Settings"),
    "simulation": MessageLookupByLibrary.simpleMessage("Curl"),
    "slide": MessageLookupByLibrary.simpleMessage("Slide"),
    "spacingSettings": MessageLookupByLibrary.simpleMessage("Spacing"),
    "startReadingAloud": MessageLookupByLibrary.simpleMessage("Start reading"),
    "statsByBook": MessageLookupByLibrary.simpleMessage("By book"),
    "storageCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Storage check failed",
    ),
    "storageCheckFailedMessage": MessageLookupByLibrary.simpleMessage(
      "Unable to check local book storage. Please try again later.",
    ),
    "storageCheckTitle": MessageLookupByLibrary.simpleMessage(
      "Local book storage check",
    ),
    "storageCleanupComplete": MessageLookupByLibrary.simpleMessage(
      "Cleanup complete",
    ),
    "storageHealthy": MessageLookupByLibrary.simpleMessage(
      "No storage issues found.",
    ),
    "storageIssuesSummary": m12,
    "storageRepairCompleteMessage": m13,
    "supportedLocalFormats": MessageLookupByLibrary.simpleMessage(
      "Only TXT and EPUB files are supported",
    ),
    "systemFont": MessageLookupByLibrary.simpleMessage("System font"),
    "timesCount": m14,
    "tips": MessageLookupByLibrary.simpleMessage("Notice"),
    "todayGoalReached": m15,
    "todayGoalRemaining": m16,
    "todayPlan": MessageLookupByLibrary.simpleMessage("Today\'s plan"),
    "totalReadingTime": MessageLookupByLibrary.simpleMessage(
      "Total reading time",
    ),
    "txtFileTooLarge": MessageLookupByLibrary.simpleMessage(
      "This TXT file is too large to import",
    ),
    "underline": MessageLookupByLibrary.simpleMessage("Underline"),
    "unnamedLocalBook": MessageLookupByLibrary.simpleMessage(
      "Untitled local book",
    ),
    "vertical": MessageLookupByLibrary.simpleMessage("Vertical"),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "weekGoalDays": m17,
    "writeYourThoughts": MessageLookupByLibrary.simpleMessage(
      "Write down your thoughts",
    ),
  };
}

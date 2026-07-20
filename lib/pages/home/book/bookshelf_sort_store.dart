import 'package:shared_preferences/shared_preferences.dart';

class BookshelfSortStore {
  const BookshelfSortStore();

  static const String _sortModeKey = 'bookshelf_sort_mode';

  Future<String?> loadSortModeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sortModeKey);
  }

  Future<void> saveSortModeName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortModeKey, value);
  }
}

part of 'app_database.dart';

const _databaseFileName = 'reader_nover.db';

LazyDatabase openAppDatabaseConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, _databaseFileName));
    LogUtils.d('数据库路径: ${file.path}');
    return NativeDatabase.createInBackground(file);
  });
}

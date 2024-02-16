import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'lines_top.db'),
        onCreate: (db, version) async{
          await db.execute('CREATE TABLE user_data(id TEXT PRIMARY KEY,progress TEXT,statistics TEXT,username TEXT,stats_dates TEXT)');
          await db.execute('CREATE TABLE exercises(id TEXT PRIMARY KEY, title TEXT,video TEXT,description TEXT,exercise_list_texts TEXT,repetition_list_texts TEXT,version INTEGER)');
          await db.execute('CREATE TABLE trainings(id TEXT PRIMARY KEY, title TEXT,sections TEXT,is_set INTEGER,description TEXT,image TEXT,version INTEGER,ex_repetitions_ids TEXT)');
          await db.execute('CREATE TABLE programs(id TEXT PRIMARY KEY, title TEXT,priority TEXT,subtext TEXT,trainings TEXT,body_text TEXT,image TEXT,is_free INTEGER,version INTEGER)');
      return db.execute('CREATE TABLE blog_posts(id TEXT PRIMARY KEY, title TEXT, short_desc TEXT, body_text TEXT, date TEXT, images TEXT,is_primary INTEGER,version INTEGER)');
    }, version: 1);
  }

  static Future<bool> exists() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.databaseExists(path.join(dbPath, 'lines_top.db'));
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.update(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> deleteTables() async {
    final dbPath = await sql.getDatabasesPath();
    await sql.deleteDatabase(path.join(dbPath, 'lines_top.db'));
    print('dropped db');
  }

}

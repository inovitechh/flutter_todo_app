import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  static final _tableName = 'todo';
  static final _columnId = 'id';
  static final _columnTitle = 'title';
  static final _columnDescription = 'description';

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'todo.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY,
        $_columnTitle TEXT,
        $_columnDescription TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final Database db = await database;
    return await db.query(_tableName);
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final Database db = await database;
    return await db.insert(_tableName, row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    final Database db = await database;
    return await db.update(
      _tableName,
      row,
      where: '$_columnId = ?',
      whereArgs: [row[_columnId]],
    );
  }

  Future<int> delete(int id) async {
    final Database db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }
}

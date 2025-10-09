import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TodoDatabase {
  static Database? _database;
  static const String _dbName = 'todo_projects.db';
  static const String _tableName = 'projects';

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        plannedDate TEXT,
        totalTasks INTEGER,
        completedTasks INTEGER
      )
    ''');
  }

  // Insert project
  static Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    return await db.insert(_tableName, project);
  }

  // Get all projects
  static Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query(_tableName);
  }

  // Delete a single project
  static Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete ALL projects (but keep database)
  static Future<void> clearAllProjects() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Delete the ENTIRE database file
  static Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    // Close before deleting
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
    debugPrint('🗑️ Database "$_dbName" deleted successfully');
  }

  // Close DB connection
  static Future close() async {
    final db = await database;
    await db.close();
  }
}

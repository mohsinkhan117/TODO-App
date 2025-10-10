import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/todo_database/todo_tasks_database.dart';

class TodoDatabase {
  static Database? _database;
  static const String _dbName = 'todo_projects.db';
  static const String _projectTableName = 'projects';
  static const String _taskTableName = 'tasks'; // New table name

  // Singleton pattern
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Deleting the database on version change is common for testing/schema updates.
    // In production, use 'onUpgrade' for proper schema migration.
    // We'll stick to a simple onCreate for this example.
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    // 1. PROJECTS Table Creation
    await db.execute('''
      CREATE TABLE $_projectTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        plannedDate TEXT NOT NULL,
        totalTasks INTEGER DEFAULT 0,
        completedTasks INTEGER DEFAULT 0
      )
    ''');

    // 2. TASKS Table Creation with Foreign Key Relationship
    await db.execute('''
      CREATE TABLE $_taskTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL, 
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        plannedDate TEXT NOT NULL,
        extendedDate TEXT,
        -- RELATIONSHIP: Links projectId in tasks to id in projects
        -- ON DELETE CASCADE: If a project is deleted, all its tasks are also deleted
        FOREIGN KEY (projectId) REFERENCES $_projectTableName (id) ON DELETE CASCADE
      )
    ''');
  }

  // ====================== Project CRUD Methods ======================

  // Insert project
  static Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert(_projectTableName, project.toMap());
  }

  // Get all projects
  static Future<List<Project>> getProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_projectTableName);

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  // Update project (useful for updating task counts)
  static Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update(
      _projectTableName,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  // Delete a single project (ON DELETE CASCADE handles tasks)
  static Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(_projectTableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete ALL projects
  static Future<void> clearAllProjects() async {
    final db = await database;
    await db.delete(_projectTableName);
    // Note: Deleting projects will cascade and delete all tasks as well.
  }

  // ====================== Task CRUD Methods ======================

  // Insert Task
  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(_taskTableName, task.toMap());
  }

  // Get Tasks for a specific project
  static Future<List<Task>> getTasksForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _taskTableName,
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: 'plannedDate ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Modify Task (Update)
  static Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      _taskTableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete Task
  static Future<int> deleteTask(int taskId) async {
    final db = await database;
    return await db.delete(
      _taskTableName,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Extend Date (Special Update)
  static Future<int> extendTaskDate(int taskId, DateTime newDate) async {
    final db = await database;
    return await db.update(
      _taskTableName,
      {
        // Update both plannedDate and extendedDate (or just extendedDate,
        // depending on your desired logic)
        'plannedDate': newDate.toIso8601String(),
        'extendedDate': newDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ====================== Database Management ======================

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

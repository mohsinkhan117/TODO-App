// lib\core\todo_database\todo_project_database.dart

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/models/todo_tasks_model.dart';

// --- Database Constants for Clarity and Safety ---
// Define table and column names as static constants to prevent typos
class DatabaseConstants {
  static const String dbName = 'todo_projects.db';
  static const int dbVersion = 1;

  // Project Table
  static const String projectTable = 'projects';
  static const String projectId = 'id';
  static const String projectTitle = 'title';
  static const String projectDescription = 'description';
  static const String projectPlannedDate = 'plannedDate';
  static const String projectTotalTasks = 'totalTasks';
  static const String projectCompletedTasks = 'completedTasks';

  // Task Table
  static const String taskTable = 'tasks';
  static const String taskId = 'id';
  static const String taskProjectId = 'projectId'; // Foreign Key
  static const String taskTitle = 'title';
  static const String taskIsDone = 'isDone';
  static const String taskPlannedDate = 'plannedDate';
  static const String taskExtendedDate = 'extendedDate';
}

class TodoDatabase {
  static Database? _database;

  // Singleton getter
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.dbName);
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _createDB,
      // Important for Foreign Key integrity: set foreign_keys = ON immediately after opening
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // --- Database Creation: Defining the Relationship ---
  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.projectTable} (
        ${DatabaseConstants.projectId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.projectTitle} TEXT NOT NULL,
        ${DatabaseConstants.projectDescription} TEXT,
        ${DatabaseConstants.projectPlannedDate} TEXT NOT NULL,
        ${DatabaseConstants.projectTotalTasks} INTEGER DEFAULT 0,
        ${DatabaseConstants.projectCompletedTasks} INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.taskTable} (
        ${DatabaseConstants.taskId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.taskProjectId} INTEGER NOT NULL, 
        ${DatabaseConstants.taskTitle} TEXT NOT NULL,
        ${DatabaseConstants.taskIsDone} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.taskPlannedDate} TEXT NOT NULL,
        ${DatabaseConstants.taskExtendedDate} TEXT,
        
        -- FOREIGN KEY DEFINITION (Crucial for the relationship)
        FOREIGN KEY (${DatabaseConstants.taskProjectId}) 
          REFERENCES ${DatabaseConstants.projectTable} (${DatabaseConstants.projectId}) 
          ON DELETE CASCADE
      )
    ''');
  }

  // --------------------------------------------------------------------------
  //                              Project CRUD
  // --------------------------------------------------------------------------

  // Insert project
  static Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert(DatabaseConstants.projectTable, project.toMap());
  }

  // Get all projects
  static Future<List<Project>> getProjects() async {
    final db = await database;
    // Query uses the table constants
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.projectTable,
    );

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  // Update project
  static Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update(
      DatabaseConstants.projectTable,
      project.toMap(),
      where: '${DatabaseConstants.projectId} = ?',
      whereArgs: [project.id],
    );
  }

  // Delete a single project (ON DELETE CASCADE handles tasks)
  static Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      DatabaseConstants.projectTable,
      where: '${DatabaseConstants.projectId} = ?',
      whereArgs: [id],
    );
  }

  // --------------------------------------------------------------------------
  //                                Task CRUD
  // --------------------------------------------------------------------------

  // Insert Task
  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(DatabaseConstants.taskTable, task.toMap());
  }

  // Get Tasks for a specific project
  static Future<List<Task>> getTasksForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.taskTable,
      where: '${DatabaseConstants.taskProjectId} = ?',
      whereArgs: [projectId],
      orderBy: '${DatabaseConstants.taskPlannedDate} ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Modify Task (Update)
  static Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      DatabaseConstants.taskTable,
      task.toMap(),
      where: '${DatabaseConstants.taskId} = ?',
      whereArgs: [task.id],
    );
  }

  // Delete Task
  static Future<int> deleteTask(int taskId) async {
    final db = await database;
    return await db.delete(
      DatabaseConstants.taskTable,
      where: '${DatabaseConstants.taskId} = ?',
      whereArgs: [taskId],
    );
  }

  // Delete the ENTIRE database file
  static Future<void> deleteDatabaseFile() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.dbName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
    debugPrint(
      '🗑️ Database "${DatabaseConstants.dbName}" deleted successfully',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todo_app/core/todo_database/todo_database.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _projects = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final plannedDateController = TextEditingController();

  DateTime? selectedPlannedDate;
  List<Map<String, dynamic>> get projects => _projects;
  //================= Load Projects ==================
  Future<void> loadProjects() async {
    _projects = await TodoDatabase.getProjects();
    notifyListeners();
  }

  Future<void> createProject() async {
    try {
      final newProject = {
        'title': titleController.text,
        'description': descriptionController.text,
        'plannedDate': plannedDateController.text,
        'totalTasks': 0,
        'completedTasks': 0,
      };

      // Insert into database
      await TodoDatabase.insertProject(newProject);

      // Add to local list for immediate UI update
      _projects.add(newProject);

      clearControllers();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error creating project: $e");
    }
  }

  Future<void> deleteProject(Map<String, dynamic> project) async {
    if (project.containsKey('id')) {
      final id = project['id'] as int;

      await TodoDatabase.deleteProject(id);

      _projects.removeWhere((p) => p['id'] == id);

      print('🗑️ Project deleted: $id');
      print('Remaining Projects: ${_projects.length}');

      notifyListeners();
    } else {
      print('⚠️ Cannot delete: Project has no ID.');
    }
  }

  // ===================== Set Planned Date =====================
  void setPlannedDate(DateTime date) {
    selectedPlannedDate = date;
    plannedDateController.text = "${date.day}/${date.month}/${date.year}";
    notifyListeners();
  }

  Future<void> deleteDataBase() async {
    await TodoDatabase.deleteDatabaseFile();
    notifyListeners();
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();

    plannedDateController.clear();
  }
}

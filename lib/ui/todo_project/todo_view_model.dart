import 'package:flutter/material.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/todo_database/todo_project_database.dart';

class ProjectViewModel extends ChangeNotifier {
  // Change to use the Project model class
  List<Project> _projects = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final plannedDateController = TextEditingController();

  DateTime? selectedPlannedDate;
  // Change the getter return type
  List<Project> get projects => _projects;

  //================= Load Projects ==================
  Future<void> loadProjects() async {
    // TodoDatabase.getProjects now returns List<Project>
    _projects = await TodoDatabase.getProjects();
    notifyListeners();
  }

  Future<void> createProject() async {
    // 1. Validation Check for required fields
    if (titleController.text.isEmpty || selectedPlannedDate == null) {
      debugPrint(
        "❌ Project creation failed: Title or Planned Date is missing.",
      );
      return;
    }

    try {
      // 2. Create an instance of the Project model
      final newProject = Project(
        title: titleController.text,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        plannedDate: selectedPlannedDate!, // Use the DateTime object
        totalTasks: 0,
        completedTasks: 0,
      );

      // 3. Insert into database and get the ID
      final newId = await TodoDatabase.insertProject(newProject);

      // 4. Create a copy with the generated ID for the local list
      final projectWithId = newProject.copyWith(id: newId);
      _projects.add(projectWithId);

      clearControllers();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error creating project: $e");
    }
  }

  Future<void> deleteProject(Project project) async {
    // Use the model's 'id' property directly
    if (project.id != null) {
      final id = project.id!;

      // 1. Delete from database (which handles cascading delete of tasks)
      await TodoDatabase.deleteProject(id);

      // 2. Remove from local list
      _projects.removeWhere((p) => p.id == id);

      debugPrint('🗑️ Project deleted: $id');
      debugPrint('Remaining Projects: ${_projects.length}');

      notifyListeners();
    } else {
      debugPrint('⚠️ Cannot delete: Project has no ID.');
    }
  }

  // ===================== Set Planned Date =====================
  void setPlannedDate(DateTime date) {
    selectedPlannedDate = date;
    // Format the date for display in the TextField
    plannedDateController.text =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    notifyListeners();
  }

  Future<void> deleteDataBase() async {
    await TodoDatabase.deleteDatabaseFile();
    _projects.clear(); // Clear the local list after database is deleted
    notifyListeners();
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    plannedDateController.clear();
    selectedPlannedDate = null; // Also clear the DateTime object
  }
}

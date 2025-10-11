import 'package:flutter/material.dart';
import 'package:todo_app/core/models/project_model.dart';
import 'package:todo_app/core/database/database.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final plannedDateController = TextEditingController();

  DateTime? selectedPlannedDate;

  List<Project> get projects => _projects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool hasLoaded = false;
  //================= Load Projects ==================
  // In ProjectViewModel - Update loadProjects method
  Future<void> loadProjects() async {
    if (!hasLoaded) {
      _isLoading = true;
      notifyListeners();
      _projects.clear();
    }

    try {
      _projects = await TodoDatabase.getProjects();

      // for (final project in _projects) {
      //   if (project.id != null) {
      //     await TodoDatabase.recalculateProjectStats(project.id!);
      //   }
      // }

      // Reload projects with updated stats
      _projects = await TodoDatabase.getProjects();

      hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error loading projects: $e");
    } finally {
      hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject() async {
    if (titleController.text.isEmpty || selectedPlannedDate == null) {
      debugPrint(
        "❌ Project creation failed: Title or Planned Date is missing.",
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newProject = Project(
        title: titleController.text,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        plannedDate: selectedPlannedDate!,
        totalTasks: 0,
        completedTasks: 0,
      );

      final newId = await TodoDatabase.insertProject(newProject);

      final projectWithId = newProject.copyWith(id: newId);
      _projects.add(projectWithId);

      clearControllers();

      // Data is ready, it will be set to false in the finally block
    } catch (e) {
      debugPrint("❌ Error creating project: $e");
    } finally {
      // 2. Set loading state to false and notify listeners
      _isLoading = false;
      notifyListeners();
    }
  }

  // In ProjectViewModel - FIX the deleteProject method
  Future<void> deleteProject(Project project) async {
    if (project.id != null) {
      _isLoading = true;
      notifyListeners();

      final id = project.id!;

      try {
        // CORRECT: Delete only this project, not the entire database
        await TodoDatabase.deleteProject(id);

        // Remove from local state
        _projects.removeWhere((p) => p.id == id);

        debugPrint('🗑️ Project deleted: $id');
        debugPrint('Remaining Projects: ${_projects.length}');
      } catch (e) {
        debugPrint("❌ Error deleting project: $e");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      debugPrint('⚠️ Cannot delete: Project has no ID.');
    }
  }

  // ===================== Set Planned Date =====================
  void setPlannedDate(DateTime date) {
    selectedPlannedDate = date;
    plannedDateController.text =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    notifyListeners();
  }

  Future<void> deleteDataBase() async {
    _isLoading = true;
    notifyListeners();

    try {
      await TodoDatabase.deleteDatabaseFile();
      _projects.clear();
    } catch (e) {
      debugPrint("❌ Error deleting database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    plannedDateController.clear();
    selectedPlannedDate = null;
  }
}

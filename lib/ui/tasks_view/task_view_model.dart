//lib\ui\todo_project_tasks.dart\task_view_model.dart
import 'package:flutter/material.dart';
import 'package:todo_app/core/models/project_model.dart';
import 'package:todo_app/core/models/tasks_model.dart';
import 'package:todo_app/core/database/database.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> todos = [];
  Project? _currentProject;
  TextEditingController todoController = TextEditingController();
  TextEditingController plannedTime = TextEditingController();
  int _remainingDays = 0;
  int get remainingDays => _remainingDays;
  bool isLoading = false;
  bool _isDone = false;
  bool get isDone => _isDone;
  bool hasLoaded = false;
  int? _lastLoadedProjectId;

  Future<void> setCurrentProject(Project project) async {
    if (project.id != null && project.id == _lastLoadedProjectId && hasLoaded) {
      _currentProject = project;
      debugPrint("Skipping load: Project ${project.id} already loaded.");
      return;
    }

    _lastLoadedProjectId = project.id;
    hasLoaded = false;
    todos.clear();

    await loadTodos(project);
  }

  Future<void> loadTodos(Project project) async {
    isLoading = true;
    todos.clear();
    notifyListeners();
    try {
      todos = await TodoDatabase.getTasksForProject(project.id!);
      hasLoaded = true;
      notifyListeners();
    } catch (e) {
      hasLoaded = false;
      debugPrint("Error loading tasks: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateProjectStats(Project project) async {
    await TodoDatabase.updateProject(_currentProject!);
  }

  Future<void> _syncProjectStats() async {
    if (_currentProject == null) return;

    // Always recalculate from actual tasks to ensure consistency
    final newTotalTasks = todos.length;
    final newCompletedTasks = todos.where((task) => task.isDone).length;

    final updatedProject = _currentProject!.copyWith(
      totalTasks: newTotalTasks,
      completedTasks: newCompletedTasks,
    );

    _currentProject = updatedProject;
    await _updateProjectStats(updatedProject);
  }

  Future<void> creatTask(Project parentProject) async {
    debugPrint("📌 Creating task for project id: ${parentProject.id}");

    if (todoController.text.isEmpty || parentProject.id == null) {
      debugPrint("⚠️ Skipping task creation — invalid project or empty title");
      return;
    }

    final projectToUpdate = _currentProject ?? parentProject;

    final DateTime finalPlannedDate = DateTime.now();

    final newTask = Task(
      projectId: projectToUpdate.id!,
      title: todoController.text,
      isDone: false,
      plannedDate: finalPlannedDate,
    );

    try {
      final newId = await TodoDatabase.insertTask(newTask);
      final taskWithId = newTask.copyWith(id: newId);
      todos.add(taskWithId);

      // Use the sync method instead of manual calculation
      await _syncProjectStats();

      todoController.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating task: $e");
    }
  }

  // Update toggleTaskStatus method
  Future<void> toggleTaskStatus(Task task, bool newValue) async {
    final index = todos.indexOf(task);
    final updatedTask = task.copyWith(isDone: newValue);
    todos[index] = updatedTask;

    try {
      await TodoDatabase.updateTask(updatedTask);
      // Use sync method instead of manual calculation
      await _syncProjectStats();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating task or project stats: $e");
    }
  }

  // Update deleteTask method
  void deleteTask(Task task) {
    final wasDone = task.isDone;
    todos.remove(task);
    TodoDatabase.deleteTask(task.id!);

    // Use sync method instead of manual calculation
    _syncProjectStats();

    notifyListeners();
  }

  // void editTask(Task task, String newTitle) {
  //   task.title = newTitle;
  //   notifyListeners();
  //   // TODO: update in database
  // }
}

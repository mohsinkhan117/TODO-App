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

  Future<void> creatTask(Project parentProject) async {
    debugPrint("📌 Creating task for project  id: ${parentProject.id}");

    if (todoController.text.isEmpty || parentProject.id == null) {
      debugPrint("⚠️ Skipping task creation — invalid project or empty title");
      return;
    }
    //will make it editable once database structure is cleared
    final DateTime finalPlannedDate = DateTime.now();

    final newTask = Task(
      projectId: parentProject.id!,
      title: todoController.text,
      isDone: false,
      plannedDate: finalPlannedDate,
    );
    try {
      // await TodoDatabase.insertTask(newTask);
      final newId = await TodoDatabase.insertTask(newTask);
      final taskWithId = newTask.copyWith(id: newId);
      todos.add(taskWithId);
      await _updateProjectStats(
        parentProject.copyWith(totalTasks: parentProject.totalTasks + 1),
      );

      todoController.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error creating task: $e");
    }
  }

  Future<void> _updateProjectStats(Project project) async {
    await TodoDatabase.updateProject(project);
  }

  Future<void> toggleTaskStatus(Task task, bool newValue) async {
    final index = todos.indexOf(task);
    final updatedTask = task.copyWith(isDone: newValue);
    todos[index] = updatedTask;
    final int toggleCompleted = newValue ? 1 : -1;
    final completedTasks = _currentProject!.completedTasks + toggleCompleted;
    final updatedProject = _currentProject!.copyWith(
      completedTasks: completedTasks,
    );
    _currentProject = updatedProject;
    try {
      await TodoDatabase.updateTask(updatedTask);
      await TodoDatabase.updateProject(updatedProject);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating task or project stats: $e");
    }
  }

  Future<void> deleteTodo(int index) async {
    await todos.removeAt(index);
    notifyListeners();
  }
}

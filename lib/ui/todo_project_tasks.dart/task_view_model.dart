//lib\ui\todo_project_tasks.dart\task_view_model.dart
import 'package:flutter/material.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/models/todo_tasks_model.dart';
import 'package:todo_app/core/todo_database/todo_project_database.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> todos = [];
  TextEditingController todoController = TextEditingController();
  TextEditingController plannedTime = TextEditingController();
  int _remainingDays = 0;
  int get remainingDays => _remainingDays;
  bool isLoading = false;
  bool _isDone = false;
  bool get isDone => _isDone;
  bool isLoaded = false;
  Future<void> loadTodos(Project project) async {
    try {
      todos = await TodoDatabase.getTasksForProject(project.id!);
      isLoaded = true;
      notifyListeners();
    } catch (e) {
      isLoaded = false;
      debugPrint("Error loading tasks: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> creatTask(Project parentProject) async {
    debugPrint(
      "📌 Creating task for project: ${parentProject.title}, id: ${parentProject.id}",
    );

    if (todoController.text.isEmpty || parentProject.id == null) {
      debugPrint("⚠️ Skipping task creation — invalid project or empty title");
      return;
    }
    final DateTime finalPlannedDate = DateTime.now();

    final newTask = Task(
      projectId: parentProject.id!,
      title: todoController.text,
      isDone: false,
      plannedDate: finalPlannedDate,
    );
    try {
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

    notifyListeners();
  }

  Future<void> _updateProjectStats(Project project) async {
    await TodoDatabase.updateProject(project);
  }

  void toggleTaskStatus(Task task, bool newValue) {
    final index = todos.indexOf(task);
    if (index != -1) {
      todos[index] = todos[index].copyWith(isDone: newValue);
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int index) async {
    await todos.removeAt(index);
    notifyListeners();
  }
}

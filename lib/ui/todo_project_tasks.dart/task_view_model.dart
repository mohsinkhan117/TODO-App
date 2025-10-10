//lib\ui\todo_project_tasks.dart\task_view_model.dart
import 'package:flutter/material.dart';

class TaskViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> todos = [];
  TextEditingController todoController = TextEditingController();
  TextEditingController plannedTime = TextEditingController();
  int _remainingDays = 0;
  int get remainingDays => _remainingDays;

  bool _isDone = false;
  //isDone -> true -> done
  //isDone -> flase -> missed
  //isDone -> false && remianingDays < 0 --> missed
  bool get isDone => _isDone;
  void creatTask() {
    Map<String, dynamic> newTask = {
      'todo': todoController.text,
      'plannedTime': plannedTime.text,
      'isDone': _isDone,
    };
    todos.add(newTask);
    notifyListeners();
  }

  Future<void> deleteTodo(int index) async {
    await todos.removeAt(index);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _projects = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  List<Map<String, dynamic>> get projects => _projects;

  void createProject() {
    final newProject = {
      'title': titleController.text,
      'description': descriptionController.text,
      'dueDate': dueDateController.text,
      'totalTasks': 10, // just an example
      'completedTasks': 3, // example
    };

    _projects.add(newProject);
    clearControllers();
    notifyListeners();
  }

  void deleteProject(int index) {
    if (index >= 0 && index < _projects.length) {
      _projects.removeAt(index);
      print('👍 Project Deleted at $index');
      print('Remaining Projects ${_projects.length}');
      notifyListeners();
    }
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    dueDateController.clear();
  }
}

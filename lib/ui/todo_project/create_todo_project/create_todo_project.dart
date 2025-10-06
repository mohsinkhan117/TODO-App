//lib\ui\todo_project\create_todo_project\create_todo_project.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/ui/todo_project/todo_view_model.dart';

class CreateTodoProject extends StatelessWidget {
  const CreateTodoProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text('Title')),
                controller: vm.titleController,
              ),
              SizedBox(height: 7),
              TextFormField(
                decoration: InputDecoration(label: Text('description')),
                controller: vm.descriptionController,
              ),
              ElevatedButton(
                onPressed: () {
                  vm.createProject();
                },
                child: Text('Create Project'),
              ),
            ],
          ),
        );
      },
    );
  }
}

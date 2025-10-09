import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/todo_project_tasks.dart/task_view_model.dart';

class ToDos extends StatelessWidget {
  final Map<String, dynamic> project;
  final int index;

  const ToDos({super.key, required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('ADD TODO'),
      ),
      body: CustomScrollView(
        slivers: [
          //================ AppBar ================
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
            title: Text(
              project['title'],
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            expandedHeight: 200.0,

            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.gradients.values.elementAt(index),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100.0,
                    left: 15.0,
                    right: 15.0,
                    bottom: 30.0,
                  ),
                  child: Text(
                    project['description'] ?? "No description",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          //================ ToDo List ================
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => const ToDoContainer(),
              childCount: 15,
            ),
          ),
        ],
      ),
    );
  }
}

//================ ToDo Container ================
class ToDoContainer extends StatelessWidget {
  const ToDoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Checkbox(value: false, onChanged: (v) {}),
            const Text("Task name here", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

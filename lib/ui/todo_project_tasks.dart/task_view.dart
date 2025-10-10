// lib/ui/todo_project_tasks.dart/task_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/models/todo_tasks_model.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/todo_project_tasks.dart/task_view_model.dart';

class ToDos extends StatelessWidget {
  final Project project;
  final int index;

  const ToDos({super.key, required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!vm.isLoaded) {
        vm.loadTodos(project);
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            enableDrag: true,
            showDragHandle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            builder: (context) {
              final double keyboardHeight = MediaQuery.of(
                context,
              ).viewInsets.bottom;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  20.0,
                  20.0,
                  20.0 + keyboardHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New ToDo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: vm.todoController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (vm.todoController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a title'),
                              ),
                            );
                            return;
                          }
                          await vm.creatTask(project);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: const Text('ADD TODO'),
        icon: const Icon(Icons.add),
      ),

      // ✅ Main scrollable body
      body: CustomScrollView(
        slivers: [
          // ================= SliverAppBar =================
          SliverAppBar(
            title: Text(
              maxLines: 2,
              project.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            pinned: true,
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
                    left: 16.0,
                    right: 16.0,
                    bottom: 30.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.description?.trim().isNotEmpty == true
                              ? project.description!
                              : "No description available.",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= ToDo List =================
          SliverToBoxAdapter(
            child: vm.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : vm.todos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No ToDos yet.\nTap the '+' button to add one!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.todos.length,
                    itemBuilder: (context, i) {
                      final task = vm.todos[i];
                      return ToDoContainer(task: task);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

//
// ================= ToDo Container =================
//
class ToDoContainer extends StatelessWidget {
  final Task task;
  const ToDoContainer({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 75,
        decoration: BoxDecoration(
          color: task.isDone
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.isDone,
              onChanged: (value) {
                if (value != null) {
                  vm.toggleTaskStatus(task, value);
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

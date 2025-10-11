// lib/ui/todo_project_tasks.dart/task_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/models/project_model.dart';
import 'package:todo_app/core/models/tasks_model.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/tasks_view/task_view_model.dart';

class ToDos extends StatelessWidget {
  final Project project;
  final int index;

  const ToDos({super.key, required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.setCurrentProject(project);
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
// lib/ui/todo_project_tasks.dart/task_view.dart (Updated)

// ... existing imports ...

//
// ================= ToDo Container (Stateful) =================
//
class ToDoContainer extends StatefulWidget {
  final Task task;
  const ToDoContainer({super.key, required this.task});

  @override
  State<ToDoContainer> createState() => _ToDoContainerState();
}

class _ToDoContainerState extends State<ToDoContainer> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TaskViewModel>(context);

    final Color containerColor = widget.task.isDone
        ? Colors.green.withOpacity(0.2)
        : Colors.red.withOpacity(0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _showOptions = true;
          });
        },
        onTap: () {
          if (_showOptions) {
            setState(() {
              _showOptions = false;
            });
          } else {
            vm.toggleTaskStatus(widget.task, !widget.task.isDone);
          }
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          height: 75,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: widget.task.isDone,
                      onChanged: (value) {
                        if (value != null) {
                          vm.toggleTaskStatus(widget.task, value);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: widget.task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_showOptions)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: LongPressMenu(
                        onDelete: () {
                          vm.deleteTask(widget.task);
                          setState(() => _showOptions = false);
                        },
                        onEdit: () {
                          setState(() => _showOptions = false);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LongPressMenu extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const LongPressMenu({
    super.key,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(width: 1.0, color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),

      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete Button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
            const VerticalDivider(width: 1, color: Colors.grey),
            // Edit Button
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

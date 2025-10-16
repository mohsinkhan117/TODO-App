// lib\ui\todo_project\todo_project.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/models/project_model.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/create_project_view/create_todo_project.dart';
import 'package:todo_app/ui/project_view/project_view_model.dart';
import 'package:todo_app/ui/tasks_view/task_view.dart';
import 'package:todo_app/ui/widgets/dialogueBox.dart';

class TodoProject extends StatelessWidget {
  const TodoProject({super.key});

  @override
  Widget build(BuildContext context) {
    final vmNoListen = Provider.of<ProjectViewModel>(context, listen: false);
    final vm = Provider.of<ProjectViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => vmNoListen.loadProjects(),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/scaffold_background.png"),
            fit: BoxFit.cover, // This will cover the entire screen
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => vm.loadProjects(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'P R O J E C T S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pinned: true,
                expandedHeight: 180,
                backgroundColor:
                    Colors.transparent, // Keep transparent to see background
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.gradients.values.elementAt(7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => vm.deleteDataBase(),
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: vm.isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(radius: 15),
                        )
                      : vm.projects.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No Projects Created, Create One',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final project = vm.projects[index];
                            return ToDoProjectContainer(
                              index: index,
                              project: project,
                              onDelete: () => vm.deleteProject(project),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: vm.projects.length,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('CREATE PROJECT'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTodoProject()),
          );
        },
      ),
    );
  }
}

class ToDoProjectContainer extends StatelessWidget {
  final Project project;
  final VoidCallback onDelete;
  final int index;

  const ToDoProjectContainer({
    super.key,
    required this.project,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProjectViewModel>(context);
    final double progress = (project.totalTasks > 0)
        ? (project.completedTasks / project.totalTasks).clamp(0.0, 1.0)
        : 0.0;

    final String plannedDateStr =
        '${project.plannedDate.day}/${project.plannedDate.month}/${project.plannedDate.year}';

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToDos(project: project, index: index),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white30),
          ),

          height: MediaQuery.of(context).devicePixelRatio * 70.0,
          width: MediaQuery.of(context).devicePixelRatio * 110.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  right: 15.0,
                  left: 15.0,
                  bottom: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.title.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11.0),
                        Consumer<ProjectViewModel>(
                          builder: (context, vm, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: vm.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () async {
                                        dialogueBox(
                                          context: context,
                                          onDelete: () =>
                                              vm.deleteProject(project),
                                          content:
                                              'You are deleting "${project.title.toUpperCase()}"\n You will be unable to restore it',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 18.0,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.white30, thickness: 1.5),
                    // Description
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                        child: Text(
                          project.description ?? 'No description',
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 5),
                    // Progress Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Count
                        Row(
                          children: [
                            Text(
                              '${project.completedTasks}/${project.totalTasks} tasks completed',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Progress Bar
                        LinearPercentIndicator(
                          barRadius: const Radius.circular(10),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          animation: true,
                          animationDuration: 800,
                          progressColor: Colors.white,
                          percent: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          lineHeight: 12.0,
                          padding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 8),

                        // Planned Date
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Planned for: $plannedDateStr',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

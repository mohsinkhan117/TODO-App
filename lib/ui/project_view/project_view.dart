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
      appBar: AppBar(
        title: Text(
          'T A S K L E',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadProjects(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stats(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: vm.isLoading
                    ? const Center(
                        child: CupertinoActivityIndicator(radius: 15),
                      )
                    : vm.projects.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No Projects Created, Create One'),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROJECTS\n',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          ListView.separated(
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
                        ],
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

class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATS', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 5.0),
          Container(
            height: MediaQuery.of(context).devicePixelRatio * 50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppGradients.gradients.values.elementAt(7),
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularPercentIndicator(
                  footer: FittedBox(
                    child: Text(
                      'Done TODOs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  center: Text('70%'),
                  radius: 35.0,
                  progressColor: Colors.blue,
                  animation: true,
                  animationDuration: 800,
                  lineWidth: 10,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressBorderColor: Colors.black,
                  percent: 0.7,
                ),
                CircularPercentIndicator(
                  footer: FittedBox(
                    child: Text(
                      'Remaining',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  center: FittedBox(child: Text('30%')),
                  radius: 35.0,
                  animation: true,
                  animationDuration: 800,
                  lineWidth: 10,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.green,
                  progressBorderColor: Colors.black,
                  percent: 0.3,
                ),
                CircularPercentIndicator(
                  footer: Text(
                    'Over Due',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  center: Text('35%'),
                  radius: 35.0,
                  progressColor: Colors.yellow,
                  animation: true,
                  animationDuration: 800,
                  lineWidth: 10,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressBorderColor: Colors.black,
                  percent: 0.35,
                ),
              ],
            ),
          ),
        ],
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
            // gradient: AppGradients.gradients.values.elementAt(
            //   index % AppGradients.gradients.length,
            // ),
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.grey.withValues(alpha: 0.3),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                              // color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11.0),
                        Consumer<ProjectViewModel>(
                          builder: (context, vm, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: vm.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: CupertinoActivityIndicator(
                                        // color: Colors.white,
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
                                        // color: Colors.white,
                                        size: 18.0,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey, thickness: 1.5),
                    // Description
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                        child: Text(
                          project.description ?? 'No description',
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            // color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 3.0),
                    // Progress Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${project.completedTasks}/${project.totalTasks} ',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const SizedBox(width: 8),

                        // Progress Bar
                        Expanded(
                          child: LinearPercentIndicator(
                            barRadius: const Radius.circular(10),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            animation: true,
                            animationDuration: 800,
                            progressColor: Colors.green,
                            percent: progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            lineHeight: 12.0,
                            // padding: EdgeInsets.zero,
                          ),
                        ),

                        // const SizedBox(width: 8),

                        // Planned Date
                        Expanded(
                          child: Text(
                            'Planned For: $plannedDateStr',
                            style: const TextStyle(
                              color: Colors.green,
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

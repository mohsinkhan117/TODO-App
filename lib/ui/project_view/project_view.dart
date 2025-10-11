// lib\ui\todo_project\todo_project.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 👈 Import for CupertinoActivityIndicator
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
        actions: [
          IconButton(
            onPressed: () {
              vm.deleteDataBase();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
        title: Text(
          '  P R O J E C T S',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (vm.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CupertinoActivityIndicator(radius: 15.0),
              ),
            )
          else if (vm.projects.isEmpty)
            const Center(child: Text('No Projects Created, Create One'))
          else
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final project = vm.projects[index];

                  return ToDoProjectContainer(
                    index: index,
                    project: project,

                    onDelete: () => vm.deleteProject(project),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: vm.projects.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('CREATE PROJECT'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTodoProject()),
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
    final double progress = (project.totalTasks > 0)
        ? project.completedTasks / project.totalTasks
        : 0.0;

    final String plannedDateStr =
        '${project.plannedDate.day}/${project.plannedDate.month}/${project.plannedDate.year}';

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            //
            builder: (context) => ToDos(project: project, index: index),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.gradients.values.elementAt(
              index % AppGradients.gradients.length,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          height: MediaQuery.of(context).devicePixelRatio * 70.0,
          width: MediaQuery.of(context).devicePixelRatio * 110.0,
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                right: 50,
                child: Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  project.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                right: 20,
                child: Text(
                  maxLines: 4,
                  // CHANGED: Access model property
                  project.description ?? 'undescribed',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              //============ Delete functionality===========
              Positioned(
                top: 10,
                right: 10,
                child: Consumer<ProjectViewModel>(
                  builder: (context, vm, child) {
                    return CircleAvatar(
                      backgroundColor: Colors.white30,
                      radius: 20,
                      child: vm.isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : IconButton(
                              onPressed: () async {
                                dialogueBox(
                                  context: context,
                                  onDelete: onDelete,
                                  content:
                                      'You are deleting "${project.title.toUpperCase()}"\n You will be unable to restore it',
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
              //============= Task completed ===============
              Positioned(
                bottom: 37,
                left: 20,
                child: Text(
                  // CHANGED: Access model properties
                  ' ${project.completedTasks}/${project.totalTasks + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //============= percent indicator ============
              Positioned(
                bottom: 20,
                left: 10,
                right: 20,
                child: LinearPercentIndicator(
                  barRadius: const Radius.circular(10),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  animation: true,
                  animationDuration: 800,
                  progressColor: Colors.white,

                  percent: project.completedTasks / (project.totalTasks + 1),
                  backgroundColor: Colors.blue[100],
                  width: MediaQuery.of(context).devicePixelRatio * 50.0,
                  lineHeight: 15.0,
                ),
              ),
              //================ planned for ============
              Positioned(
                bottom: 10,
                right: 15,
                child: Text(
                  // CHANGED: Use formatted date string
                  'Planned for: $plannedDateStr',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//lib\ui\todo_project\todo_project.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/todo_project/create_todo_project/create_todo_project.dart';
import 'package:todo_app/ui/todo_project/todo_view_model.dart';
import 'package:todo_app/ui/todo_project_tasks.dart/task_view.dart';

class TodoProject extends StatelessWidget {
  const TodoProject({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProjectViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => vm.loadProjects());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              vm.deleteDataBase();
            },
            icon: Icon(Icons.delete),
          ),
        ],
        title: Row(
          children: [
            Image.asset('assets/app_logo.png', width: 40.0, height: 40.0),
            Text('  ToDos', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          vm.projects.isEmpty
              ? Text('No Projects Created, Create One')
              : Expanded(
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final project = vm.projects[index];

                      return ToDoProjectContainer(
                        index: index,
                        project: project,
                        onDelete: () => vm.deleteProject(project),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemCount: vm.projects.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('CREATE PROJECT'),
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
  final Map<String, dynamic> project;
  final VoidCallback onDelete;
  final int index;
  ToDoProjectContainer({
    super.key,
    required this.project,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
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
                  project['title'] ?? 'UnTitled',
                  style: TextStyle(
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
                  project['description'] ?? 'undescribed',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              //============ Delete functionality===========
              Positioned(
                top: 10,

                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white30,
                  radius: 20,
                  child: IconButton(
                    onPressed: onDelete,

                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              //============= Task completed ===============
              Positioned(
                bottom: 37,
                left: 20,
                child: Text(
                  ' ${project['completedTasks'] ?? 0}/${project['totalTasks'] ?? 0}',
                  style: TextStyle(
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
                  barRadius: const Radius.circular(10), // for rounded corners
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  animation: true,
                  progressColor: Colors.white,
                  percent:
                      project['completedTasks'] / project['totalTasks'] ?? 0.0,
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
                  'Planned for: ${project['plannedDate']}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

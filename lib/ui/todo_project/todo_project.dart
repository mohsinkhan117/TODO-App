// lib\ui\todo_project\todo_project.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/models/todo_project_model.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
 import 'package:todo_app/ui/todo_project/create_todo_project/create_todo_project.dart';
import 'package:todo_app/ui/todo_project/todo_view_model.dart';
import 'package:todo_app/ui/todo_project_tasks.dart/task_view.dart';

class TodoProject extends StatelessWidget {
  const TodoProject({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure vm.projects is now List<Project>
    final vm = Provider.of<ProjectViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => vm.loadProjects());
    
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
        title: Row(
          children: [
            Image.asset('assets/app_logo.png', width: 40.0, height: 40.0),
            const Text('  ToDos', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          vm.projects.isEmpty
              ? const Text('No Projects Created, Create One')
              : Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final project = vm.projects[index];

                      return ToDoProjectContainer(
                        index: index,
                        project: project,
                        // Pass the Project object to the delete function
                        onDelete: () => vm.deleteProject(project), 
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
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
  // CHANGED: Use the Project model here
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
    // Calculate progress safely
    final double progress = (project.totalTasks > 0) 
        ? project.completedTasks / project.totalTasks 
        : 0.0;
        
    // Format the date for display
    final String plannedDateStr = 
        '${project.plannedDate.day}/${project.plannedDate.month}/${project.plannedDate.year}';

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            // NOTE: You'll need to update the `ToDos` widget to accept a Project object 
            // instead of Map<String, dynamic> if you continue with model-based data.
            // For now, passing the Project object directly:
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
                  // CHANGED: Access model property
                  project.title, 
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
                child: CircleAvatar(
                  backgroundColor: Colors.white30,
                  radius: 20,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
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
                  // CHANGED: Access model properties
                  ' ${project.completedTasks}/${project.totalTasks}', 
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
                  progressColor: Colors.white,
                  // CHANGED: Use calculated progress
                  percent: progress, 
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
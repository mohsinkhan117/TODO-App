// lib/ui/todo_project/create_todo_project/create_todo_project.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/todo_project/todo_view_model.dart';

class CreateTodoProject extends StatelessWidget {
  const CreateTodoProject({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient =
        AppGradients.gradients.values.first; // Use first gradient by default
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ProjectViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              //==================== App Bar ====================
              SliverAppBar(
                expandedHeight: 180.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'Create New Project',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(gradient: gradient),
                  ),
                ),
              ),

              //==================== Form ====================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: screenWidth * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Project Details",
                              style: TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 20),

                            //========= Title Field =========
                            TextFormField(
                              controller: vm.titleController,
                              decoration: _inputDecoration('Title'),
                            ),
                            const SizedBox(height: 20),

                            //========= Description Field =========
                            TextFormField(
                              controller: vm.descriptionController,
                              maxLines: 3,
                              decoration: _inputDecoration('Description'),
                            ),
                            const SizedBox(height: 25),

                            //========= Planned Date =========
                            TextFormField(
                              controller: vm.plannedDateController,
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  vm.setPlannedDate(date);
                                }
                              },
                              decoration: _inputDecoration('Planned Date'),
                            ),
                            const SizedBox(height: 40),

                            //========= Create Button =========
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await vm.createProject();
                                  Navigator.pop(context);
                                },

                                child: const Text(
                                  'Create Project',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

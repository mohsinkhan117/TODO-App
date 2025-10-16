// lib/ui/todo_project/create_todo_project/create_todo_project.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/theme/app_gradients.dart';
import 'package:todo_app/ui/project_view/project_view_model.dart';

class CreateTodoProject extends StatelessWidget {
  const CreateTodoProject({super.key});

  InputDecoration _whiteUnderlineDecoration(
    String hintText, {
    Widget? prefixIcon,
  }) {
    const whiteBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1.5),
    );

    const hintStyle = TextStyle(
      color: Colors.white70,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      border: whiteBorder,
      enabledBorder: whiteBorder,
      focusedBorder: whiteBorder,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      errorStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  InputDecoration _outlinedDescriptionDecoration(String hintText) {
    const outlineBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white24, width: 1.5),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      border: outlineBorder,
      enabledBorder: outlineBorder,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      contentPadding: const EdgeInsets.all(16),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppGradients.gradients.values.isNotEmpty
        ? AppGradients.gradients.values.first
        : const LinearGradient(colors: [Colors.blue, Colors.purple]);

    return Consumer<ProjectViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240.0,
                floating: true,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 16,
                  ),
                  centerTitle: false,
                  background: Container(
                    decoration: BoxDecoration(gradient: gradient),
                    padding: const EdgeInsets.only(
                      top: 100,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: vm.titleController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: _whiteUnderlineDecoration('Project Title')
                              .copyWith(
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                errorText: vm.titleError,
                              ),
                          maxLines: 1,
                          onChanged: (value) => vm.validateTitle(value),
                        ),
                        const SizedBox(height: 20),

                        GestureDetector(
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
                          child: AbsorbPointer(
                            child: TextField(
                              controller: vm.plannedDateController,
                              readOnly: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: _whiteUnderlineDecoration(
                                'Select planned date',
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white70,
                                ),
                              ).copyWith(errorText: vm.dateError),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: vm.descriptionController,
                        maxLines: null,
                        minLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 16),
                        decoration: _outlinedDescriptionDecoration(
                          'Project description...',
                        ).copyWith(errorText: vm.descriptionError),
                        onChanged: (value) => vm.validateDescription(value),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vm.isFormValid && !vm.isLoading
                              ? () async {
                                  FocusScope.of(context).unfocus();
                                  final success = await vm.createProject();
                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: vm.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Create Project',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

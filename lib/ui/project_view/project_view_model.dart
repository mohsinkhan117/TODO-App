import 'package:flutter/material.dart';
import 'package:todo_app/core/models/project_model.dart';
import 'package:todo_app/core/database/database.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final plannedDateController = TextEditingController();

  DateTime? selectedPlannedDate;

  // Validation states
  String? _titleError;
  String? _dateError;
  String? _descriptionError;

  String? get titleError => _titleError;
  String? get dateError => _dateError;
  String? get descriptionError => _descriptionError;

  List<Project> get projects => _projects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool hasLoaded = false;

  //================= VALIDATION METHODS ==================

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      _titleError = 'Project title is required';
      notifyListeners();
      return _titleError;
    }

    if (value.length < 3) {
      _titleError = 'Title must be at least 3 characters long';
      notifyListeners();
      return _titleError;
    }

    if (value.length > 50) {
      _titleError = 'Title cannot exceed 50 characters';
      notifyListeners();
      return _titleError;
    }

    // Clear error if valid
    _titleError = null;
    notifyListeners();
    return null;
  }

  String? validateDate(DateTime? date) {
    if (date == null) {
      _dateError = 'Planned date is required';
      notifyListeners();
      return _dateError;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(today)) {
      _dateError = 'Planned date cannot be in the past';
      notifyListeners();
      return _dateError;
    }

    // Check if date is too far in the future (optional)
    final maxDate = today.add(const Duration(days: 365 * 5)); // 5 years max
    if (selectedDate.isAfter(maxDate)) {
      _dateError = 'Planned date cannot be more than 5 years in the future';
      notifyListeners();
      return _dateError;
    }

    // Clear error if valid
    _dateError = null;
    notifyListeners();
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      // Description is optional, so no error
      _descriptionError = null;
      notifyListeners();
      return null;
    }

    if (value.length > 500) {
      _descriptionError = 'Description cannot exceed 500 characters';
      notifyListeners();
      return _descriptionError;
    }

    // Clear error if valid
    _descriptionError = null;
    notifyListeners();
    return null;
  }

  //================= FORM VALIDATION ==================

  bool get isFormValid {
    return validateTitle(titleController.text) == null &&
        validateDate(selectedPlannedDate) == null &&
        validateDescription(descriptionController.text) == null;
  }

  void validateAllFields() {
    validateTitle(titleController.text);
    validateDate(selectedPlannedDate);
    validateDescription(descriptionController.text);
  }

  void clearValidationErrors() {
    _titleError = null;
    _dateError = null;
    _descriptionError = null;
    notifyListeners();
  }

  //================= Load Projects ==================
  Future<void> loadProjects() async {
    if (!hasLoaded) {
      _isLoading = true;
      notifyListeners();
      _projects.clear();
    }

    try {
      _projects = await TodoDatabase.getProjects();
      hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error loading projects: $e");
    } finally {
      hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  //================= Create Project ==================
  Future<bool> createProject() async {
    // Validate all fields before creating
    validateAllFields();

    if (!isFormValid) {
      debugPrint("❌ Project creation failed: Form validation errors");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newProject = Project(
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        plannedDate: selectedPlannedDate!,
        totalTasks: 0,
        completedTasks: 0,
      );

      final newId = await TodoDatabase.insertProject(newProject);
      final projectWithId = newProject.copyWith(id: newId);
      _projects.add(projectWithId);

      clearControllers();
      clearValidationErrors();

      debugPrint("✅ Project created successfully");
      return true;
    } catch (e) {
      debugPrint("❌ Error creating project: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //================= Delete Project ==================
  Future<void> deleteProject(Project project) async {
    if (project.id != null) {
      _isLoading = true;
      notifyListeners();

      final id = project.id!;

      try {
        await TodoDatabase.deleteProject(id);
        _projects.removeWhere((p) => p.id == id);
        debugPrint('🗑️ Project deleted: $id');
      } catch (e) {
        debugPrint("❌ Error deleting project: $e");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      debugPrint('⚠️ Cannot delete: Project has no ID.');
    }
  }

  //================= Set Planned Date ==================
  void setPlannedDate(DateTime date) {
    selectedPlannedDate = date;
    plannedDateController.text =
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    // Auto-validate date when set
    validateDate(date);
    notifyListeners();
  }

  //================= Auto-validation on text changes ==================
  void initializeValidationListeners() {
    titleController.addListener(() {
      validateTitle(titleController.text);
    });

    descriptionController.addListener(() {
      validateDescription(descriptionController.text);
    });
  }

  //================= Cleanup ==================
  void disposeControllers() {
    titleController.dispose();
    descriptionController.dispose();
    plannedDateController.dispose();
  }

  Future<void> deleteDataBase() async {
    _isLoading = true;
    notifyListeners();

    try {
      await TodoDatabase.deleteDatabaseFile();
      _projects.clear();
    } catch (e) {
      debugPrint("❌ Error deleting database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    plannedDateController.clear();
    selectedPlannedDate = null;
    clearValidationErrors();
  }
}

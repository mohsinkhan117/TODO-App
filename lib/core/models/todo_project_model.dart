class Project {
  final int? id;
  final String title;
  final String? description;
  final DateTime plannedDate;
  final int totalTasks;
  final int completedTasks;

  Project({
    this.id,
    required this.title,
    this.description,
    required this.plannedDate,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  // Convert Project object to Map (for SQLite insertion/update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'plannedDate': plannedDate.toIso8601String(),
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
    };
  }

  // Create Project object from Map (from SQLite query)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      // Assuming 'plannedDate' is stored as an ISO 8601 string
      plannedDate: DateTime.parse(map['plannedDate'] as String),
      totalTasks: map['totalTasks'] as int,
      completedTasks: map['completedTasks'] as int,
    );
  }

  // Utility method for updates (e.g., updating task counts)
  Project copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? plannedDate,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      plannedDate: plannedDate ?? this.plannedDate,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}

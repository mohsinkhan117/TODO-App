class Task {
  final int? id; // Task ID (Primary Key)
  final int projectId; // Foreign Key linking to the Project table
  final String title;
  final bool isDone;
  final DateTime plannedDate;
  final DateTime? extendedDate;
  Task({
    this.id,
    required this.projectId,
    required this.title,
    required this.isDone,
    required this.plannedDate,
    this.extendedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'isDone': isDone ? 1 : 0,
      'plannedDate': plannedDate.toIso8601String(),
      'extendedDate': extendedDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      projectId: map['projectId'] as int,
      title: map['title'] as String,
      isDone: map['isDone'] as bool,
      plannedDate: map['plannedDate'] as DateTime,
      extendedDate: map['extendedDate'] != null
          ? DateTime.parse(map['extendedDate'] as String)
          : null,
    );
  }
  Task copyWith({
    int? id,
    int? projectId,
    String? title,
    bool? isDone,
    DateTime? plannedDate,
    DateTime? extendedDate,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      plannedDate: plannedDate ?? this.plannedDate,
      extendedDate: extendedDate ?? this.extendedDate,
    );
  }
}

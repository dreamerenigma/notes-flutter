class TaskModel {
  final int id;
  late final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isImportant;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.isCompleted = false,
    this.isImportant = false,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isImportant,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['due_date'] ?? ''),
      isCompleted: (map['is_completed'] ?? 0) == 1,
      isImportant: (map['is_important'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'title': title,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'is_important': isImportant ? 1 : 0,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }
}

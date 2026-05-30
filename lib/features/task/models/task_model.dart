import '../../../core/enums/repeat_type.dart';
import '../../../core/interfaces/selectable_item.dart';
import '../../../utils/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TaskModel implements SelectableItem {
  @override
  final int? id;
  final int? categoryColor;
  late final String title;
  final String description;
  final RepeatType repeatType;
  final String? category;
  final String? note;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isImportant;
  final bool isDeleted;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.note,
    this.category,
    this.repeatType = RepeatType.none,
    this.categoryColor,
    this.isCompleted = false,
    this.isImportant = false,
    this.isDeleted = false,
  });

  TaskModel copyWith({
    int? id,
    int? categoryColor,
    String? title,
    String? description,
    String? note,
    String? category,
    RepeatType? repeatType,
    DateTime? createdAt,
    Object? dueDate = _unset,
    bool? isCompleted,
    bool? isImportant,
  }) {
    return TaskModel(
      id: id ?? this.id,
      categoryColor: categoryColor ?? this.categoryColor,
      title: title ?? this.title,
      description: description ?? this.description,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate == _unset ? this.dueDate : dueDate as DateTime?,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      category: category ?? this.category,
      repeatType: repeatType ?? this.repeatType,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['due_date'] ?? ''),
      note: map['note'] as String?,
      isCompleted: (map['is_completed'] ?? 0) == 1,
      isImportant: (map['is_important'] ?? 0) == 1,
      category: map['category'] as String?,
      categoryColor: map['category_color'] as int?,
      repeatType: RepeatType.values.firstWhere((e) => e.name == map['repeat_type'], orElse: () => RepeatType.none),
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'title': title,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'note': note,
      'is_completed': isCompleted ? 1 : 0,
      'is_important': isImportant ? 1 : 0,
      'category': category ?? '',
      'category_color': categoryColor ?? AppColors.darkSlate.toARGB32(),
      'repeat_type': repeatType.name,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const _unset = Object();

  Color get categoryColorValue => Color(categoryColor ?? 0xFF000000);
}

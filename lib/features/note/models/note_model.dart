import '../../../core/interfaces/selectable_item.dart';
import '../../../utils/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NoteModel implements SelectableItem {
  @override
  final int? id;
  final int? categoryColor;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final String? category;
  final bool isFavorite;
  final bool isDeleted;
  final bool isSelected;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.category,
    this.categoryColor,
    this.isFavorite = false,
    this.isDeleted = false,
    this.isSelected = false,
  });

  NoteModel copyWith({
    int? id,
    int? categoryColor,
    String? title,
    String? imagePath,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isDeleted,
    bool? isSelected,
  }) {
    return NoteModel(
      id: id ?? this.id,
      categoryColor: categoryColor ?? this.categoryColor,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      imagePath: map['image_path'] as String?,
      category: map['category'] as String?,
      categoryColor: map['category_color'] as int?,
      isFavorite: map['is_favorite'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_path': imagePath,
      'category': category,
      'category_color': categoryColor ?? AppColors.darkSlate.toARGB32(),
      'is_favorite': isFavorite ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is NoteModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Color get categoryColorValue => Color(categoryColor ?? 0xFF000000);
}

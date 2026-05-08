class NoteModel {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
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
    this.imagePath,
    this.category,
    this.isFavorite = false,
    this.isDeleted = false,
    this.isSelected = false,
  });

  NoteModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? imagePath,
    String? category,
    bool? isFavorite,
    bool? isDeleted,
    bool? isSelected,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at']),
      imagePath: map['image_path'] as String?,
      category: map['category'] as String?,
      isFavorite: map['is_favorite'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'image_path': imagePath,
      'category': category,
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
}

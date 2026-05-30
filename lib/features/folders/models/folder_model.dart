class FolderModel {
  final int? id;
  final String icon;
  final String title;
  final int? position;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FolderModel({
    this.id,
    required this.icon,
    required this.title,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  FolderModel copyWith({
    int? id,
    String? icon,
    String? title,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FolderModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'position': position,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'] as int?,
      icon: map['icon'] as String,
      title: map['title'] as String,
      position: map['position'] as int? ?? 0,
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) : null,
    );
  }

  factory FolderModel.empty() {
    return FolderModel(
      id: null,
      icon: '',
      title: '',
      position: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class SettingsModel {
  final int id;
  final String theme;
  final String language;
  final String watermarkText;
  final int? defaultCategory;
  final int? defaultCategoryColor;
  final int weekStart;
  final bool passwordEnabled;

  SettingsModel({
    required this.id,
    required this.theme,
    required this.language,
    required this.watermarkText,
    required this.passwordEnabled,
    required this.weekStart,
    this.defaultCategory,
    this.defaultCategoryColor,
  });

  SettingsModel copyWith({
    int? id,
    String? theme,
    String? language,
    String? watermarkText,
    int? defaultCategory,
    int? defaultCategoryColor,
    int? weekStart,
    bool? passwordEnabled,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      watermarkText: watermarkText ?? this.watermarkText,
      passwordEnabled: passwordEnabled ?? this.passwordEnabled,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      weekStart: weekStart ?? this.weekStart,
      defaultCategoryColor: defaultCategoryColor ?? this.defaultCategoryColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': theme,
      'language': language,
      'default_category': defaultCategory,
      'default_category_color': defaultCategoryColor,
      'password_enabled': passwordEnabled ? 1 : 0,
      'week_start': weekStart,
      'watermark_text': watermarkText,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'],
      theme: map['theme'],
      language: map['language'],
      defaultCategory: map['default_category'],
      defaultCategoryColor: map['default_category_color'],
      passwordEnabled: map['password_enabled'] == 1,
      weekStart: map['week_start'] ?? 1,
      watermarkText: map['watermark_text'],
    );
  }
}

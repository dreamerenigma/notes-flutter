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

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'] as int,
      theme: map['theme'] as String? ?? 'light',
      language: map['language'] as String? ?? 'ru',
      watermarkText: map['watermark_text'] as String? ?? '',
      defaultCategory: map['default_category'] as int?,
      defaultCategoryColor: map['default_category_color'] as int?,
      passwordEnabled: (map['password_enabled'] ?? 0) == 1,
      weekStart: map['week_start'] as int? ?? 1,
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
}

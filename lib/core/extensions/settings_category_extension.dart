import '../../features/note/models/category_item.dart';
import '../../features/settings/models/settings_model.dart';
import '../../features/task/widgets/items/category_items.dart';

extension SettingsCategoryExtension on SettingsModel {
  CategoryItem? get defaultCategoryItem {
    if (defaultCategory == null) return null;

    return CategoryItems.categories.firstWhere((e) => e.id == defaultCategory, orElse: () => CategoryItems.categories.first);
  }
}

import '../../../utils/constants/app_colors.dart';
import '../../note/models/category_item.dart';

final List<CategoryItem> defaultCategories = [
  CategoryItem(title: 'Работа', color: AppColors.red, id: 1, stripeColor: AppColors.red),
  CategoryItem(title: 'Личное', color: AppColors.blueAccent, id: 2, stripeColor: AppColors.blueAccent),
  CategoryItem(title: 'Повседневное', color: AppColors.lightGreen, id: 3, stripeColor: AppColors.lightGreen),
  CategoryItem(title: 'Шоппинг', color: AppColors.secondary, id: 4, stripeColor: AppColors.secondary),
];

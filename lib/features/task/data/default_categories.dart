import '../../../utils/constants/app_colors.dart';
import '../../note/models/category_model.dart';

final List<CategoryModel> defaultCategories = [
  CategoryModel(title: 'Работа', color: AppColors.red, id: 1, stripeColor: AppColors.red),
  CategoryModel(title: 'Личное', color: AppColors.blueAccent, id: 2, stripeColor: AppColors.blueAccent),
  CategoryModel(title: 'Повседневное', color: AppColors.lightGreen, id: 3, stripeColor: AppColors.lightGreen),
  CategoryModel(title: 'Шоппинг', color: AppColors.secondary, id: 4, stripeColor: AppColors.secondary),
];

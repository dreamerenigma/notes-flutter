import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/models/category_model.dart';

class CategoryItems {
  static final List<CategoryModel> categories = [
    CategoryModel(title: 'Работа', color: AppColors.red, id: 1, stripeColor: AppColors.red),
    CategoryModel(title: 'Личное', color: AppColors.blueAccent, id: 2, stripeColor: AppColors.blueAccent),
    CategoryModel(title: 'Шоппинг', color: AppColors.secondary, id: 3, stripeColor: AppColors.secondary),
    CategoryModel(title: 'Без категории', color: AppColors.darkGrey, id: 4, svgAsset: AppVectors.bookmark, stripeColor: AppColors.darkGrey),
  ];
}

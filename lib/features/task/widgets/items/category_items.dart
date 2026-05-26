import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/models/category_item.dart';

class CategoryItems {
  static final List<CategoryItem> categories = [
    CategoryItem(title: 'Работа', color: AppColors.red, id: 1, stripeColor: AppColors.red),
    CategoryItem(title: 'Личное', color: AppColors.blueAccent, id: 2, stripeColor: AppColors.blueAccent),
    CategoryItem(title: 'Шоппинг', color: AppColors.secondary, id: 3, stripeColor: AppColors.secondary),
    CategoryItem(title: 'Без категории', color: AppColors.darkGrey, id: 4, svgAsset: AppVectors.bookmark, stripeColor: AppColors.darkGrey),
  ];
}

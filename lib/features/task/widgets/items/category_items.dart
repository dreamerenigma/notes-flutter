import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/models/category_item.dart';

class CategoryItems {
  static final List<CategoryItem> categories = [
    CategoryItem(title: 'Работа', color: AppColors.red, value: AppColors.red.toARGB32()),
    CategoryItem(title: 'Личное', color: AppColors.blueAccent, value: AppColors.blueAccent.toARGB32()),
    CategoryItem(title: 'Шоппинг', color: AppColors.secondary, value: AppColors.secondary.toARGB32()),
    CategoryItem(title: 'Без категории', color: AppColors.darkGrey, value: AppColors.darkGrey.toARGB32(), svgAsset: AppVectors.bookmark),
  ];
}

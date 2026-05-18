import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
      child: Container(
        height: 55,
        decoration: BoxDecoration(color: context.isDarkMode ? AppColors.black : AppColors.white),
        child: Row(
          children: [
            _buildItem(
              context: context,
              icon: SvgPicture.asset(
                selectedIndex == 0 ? AppVectors.documentBlue : context.isDarkMode ? AppVectors.documentGreyDark : AppVectors.documentGreyLight,
                width: 25,
                height: 25,
              ),
              label: 'Заметки',
              index: 0,
            ),
            _buildItem(
              context: context,
              icon: SvgPicture.asset(
                selectedIndex == 1 ? AppVectors.checkBlue : context.isDarkMode ? AppVectors.checkGreyDark : AppVectors.checkGreyLight,
                width: 25,
                height: 25,
              ),
              label: 'Задачи',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required BuildContext context, required Widget icon, required String label, required int index}) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          splashFactory: NoSplash.splashFactory,
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.youngNight,
          highlightColor: AppColors.youngNight,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.blueAccent : (context.isDarkMode ? AppColors.grey : AppColors.darkGrey))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

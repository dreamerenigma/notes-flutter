import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/features/utils/widgets/dividers/custom_divider.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../settings/widgets/dialogs/light_dialog.dart';
import '../../../task/widgets/buttons/custom_radio_button.dart';
import '../../models/note_view_model.dart';
import 'package:provider/provider.dart';

class SortingNoteDialogController extends GetxController {
  final GetStorage storage = GetStorage();
  var selectedValue = 1.obs;

  @override
  void onInit() {
    super.onInit();
    selectedValue.value = storage.read<int>('selectedSort') ?? 1;
  }

  void changeSort(int? value) {
    if (value == null) return;

    selectedValue.value = value;
    storage.write('selectedSort', value);
    update();
  }
}

void showSortingNoteDialog(BuildContext context) {
  final controller = Get.isRegistered<SortingNoteDialogController>() ? Get.find<SortingNoteDialogController>() : Get.put(SortingNoteDialogController());

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black54,
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: AppColors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 4), child: Text('Сортировка', style: TextStyle(fontSize: AppSizes.fontSizeBg))),
                  const SizedBox(height: 12),
                  Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        _buildSortItem(context, title: 'Дата изменения', value: 1, groupValue: controller.selectedValue.value, onChanged: controller.changeSort),
                        const SizedBox(height: 3),
                        CustomDivider(indent: 0, endIndent: 5, color: context.isDarkMode ? AppColors.softNight : AppColors.grey),
                        _buildSortItem(context, title: 'Дата создания', value: 2, groupValue: controller.selectedValue.value,  onChanged: controller.changeSort),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildSortItem(BuildContext context, {required String title, required int value, required int groupValue, required ValueChanged<int?> onChanged}) {
  final controller = Get.find<SortingNoteDialogController>();

  return Material(
    color: AppColors.transparent,
    child: InkWell(
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(8),
      splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
      onTap: () {
        controller.changeSort(value);

        final vm = context.read<NoteViewModel>();
        vm.setSortType(value);

        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 17)),
            CustomRadioButton<int>(
              value: value,
              groupValue: groupValue,
              activeColor: colorsController.getColor(colorsController.selectedColorScheme.value),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    ),
  );
}

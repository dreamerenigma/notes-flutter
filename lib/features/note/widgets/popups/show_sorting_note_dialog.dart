import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../models/note_view_model.dart';
import 'package:provider/provider.dart';

class SortingNoteDialogController extends GetxController {
  final GetStorage storage = GetStorage();
  var selectedValue = 1.obs;

  @override
  void onInit() {
    super.onInit();
    selectedValue.value = storage.read('selectedSort') ?? 1;
  }

  void changeSort(int value) {
    selectedValue.value = value;
    storage.write('selectedSort', value);
    update();
  }
}

void showSortingNoteDialog(BuildContext context) {
  final SortingNoteDialogController controller = Get.put(SortingNoteDialogController());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: AppColors.transparent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('Сортировка', style: TextStyle(fontSize: AppSizes.fontSizeBg)),
                ),
                const SizedBox(height: 12),
                Obx(() => RadioGroup<int>(
                  groupValue: controller.selectedValue.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeSort(value);
                    }
                  },
                  child: Column(
                    children: [
                      _buildSortItem(context, title: 'Дата изменения', value: 1),
                      const SizedBox(height: 3),
                      Divider(height: 0, indent: 10, endIndent: 10),
                      _buildSortItem(context, title: 'Дата создания', value: 2),
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
      );
    },
  );
}

Widget _buildSortItem(BuildContext context, {required String title, required int value}) {
  return Material(
    color: AppColors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      splashColor: AppColors.softNight,
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.lightSoftNight,
      onTap: () {
        final vm = context.read<NoteViewModel>();
        vm.setSortType(value);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 17)),
            Radio<int>(value: value, activeColor: AppColors.blueAccent),
          ],
        ),
      ),
    ),
  );
}

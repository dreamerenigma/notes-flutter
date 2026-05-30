import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../generated/l10n/l10n.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../../../utils/constants/app_vectors.dart';

class LanguagesController extends GetxController {
  static LanguagesController get instance => Get.find();

  var selectedLanguage = 'ru'.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    String? savedLanguage = box.read('selectedLanguage');
    if (savedLanguage != null) {
      selectedLanguage.value = savedLanguage;
      Get.updateLocale(Locale(savedLanguage));
    } else {
      selectedLanguage.value = 'ru';
    }
  }

  void setLanguage(String language) {
    selectedLanguage.value = language;
    box.write('selectedLanguage', language);
    Get.updateLocale(Locale(language));
  }

  String getLanguageTitle() {
    switch (selectedLanguage.value) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'ru':
      default:
        return 'Русский';
    }
  }

  Future<void> selectLanguage(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10, bottom: 10),
                  child: Text(S.of(context).selectLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            Obx(() => RadioGroup<String>(
                groupValue: selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) {
                    setLanguage(value);
                    Get.back();
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 6.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppVectors.rus, width: 25, height: 25),
                            const SizedBox(width: 16),
                            Text(S.of(context).russianLanguage),
                          ],
                        ),
                      ),
                      value: 'ru',
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                    RadioListTile<String>(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 6.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppVectors.usa, width: 25, height: 25),
                            const SizedBox(width: 16),
                            Text(S.of(context).englishLanguage),
                          ],
                        ),
                      ),
                      value: 'en',
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                    RadioListTile<String>(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 6.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(AppVectors.esp, width: 25, height: 25),
                            const SizedBox(width: 16),
                            Text(S.of(context).spanishLanguage),
                          ],
                        ),
                      ),
                      value: 'es',
                      controlAffinity: ListTileControlAffinity.trailing,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                    SizedBox(height: AppSizes.spaceBtwLittle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

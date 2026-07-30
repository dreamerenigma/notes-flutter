import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../generated/l10n/l10n.dart';

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

  String getLanguageTitle(BuildContext context) {
    return getLanguageName(context, selectedLanguage.value);
  }

  String getLanguageName(BuildContext context, String code) {
    switch (code) {
      case 'ru':
        return S.of(context).russian;
      case 'en':
        return S.of(context).english;
      case 'fr':
        return S.of(context).french;
      case 'de':
        return S.of(context).deutsch;
      case 'it':
        return S.of(context).italian;
      case 'pt':
        return S.of(context).portuguese;
      case 'es':
        return S.of(context).spanish;
      case 'zh':
        return S.of(context).chinese;
      case 'ko':
        return S.of(context).korean;
      case 'ja':
        return S.of(context).japanese;
      default:
        return code;
    }
  }
}

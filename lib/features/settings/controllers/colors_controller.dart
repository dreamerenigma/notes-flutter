import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/constants/app_colors.dart';

class ColorsController extends GetxController {
  static ColorsController get instance => Get.find();
  var selectedColorScheme = 'blue'.obs;
  final box = GetStorage();

  var defaultIconColor = AppColors.blueAccent.toARGB32().obs;


  @override
  void onInit() {
    super.onInit();
    selectedColorScheme.value = box.read('selectedColorScheme') ?? 'blue';
    defaultIconColor.value = box.read('defaultIconColor') ?? AppColors.blueAccent.toARGB32();
    applyColorScheme(selectedColorScheme.value);
  }

  Color get defaultIconColorValue {
    return Color(defaultIconColor.value);
  }

  Color getColor(String colorScheme) {
    switch (colorScheme) {
      case 'blue':
        return AppColors.blueAccent;
      case 'red':
        return AppColors.red;
      case 'green':
        return AppColors.green;
      case 'orange':
        return AppColors.orange;
      default:
        return Get.isDarkMode ? AppColors.white : AppColors.black;
    }
  }

  String getColorName() {
    switch (selectedColorScheme.value) {
      case 'blue':
        return 'Синий';
      case 'red':
        return 'Красный';
      case 'green':
        return 'Зеленый';
      case 'orange':
        return 'Оранжевый';
      default:
        return 'По умолчанию';
    }
  }

  void setDefaultIconColor(Color color) {
    defaultIconColor.value = color.toARGB32();
    box.write('defaultIconColor', color.toARGB32());
  }

  void setColorScheme(String colorScheme) {
    selectedColorScheme.value = colorScheme;
    box.write('selectedColorScheme', colorScheme);
    applyColorScheme(colorScheme);
  }

  void applyColorScheme(String colorScheme) {
    ThemeData themeData = ThemeData(
      primaryColor: getColor(colorScheme),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(getColor(colorScheme))),
      iconTheme: IconThemeData(color: getColor(colorScheme)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: getColor(colorScheme))),
    );

    Get.changeTheme(themeData);
  }

  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = {};

    final r = color.r, g = color.g, b = color.b;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        (r + ((ds < 0 ? r : (255 - r)) * ds)).toInt(),
        (g + ((ds < 0 ? g : (255 - g)) * ds)).toInt(),
        (b + ((ds < 0 ? b : (255 - b)) * ds)).toInt(),
        1,
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }
}

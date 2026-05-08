import 'package:flutter/material.dart';
import 'package:notes/utils/theme/widget_themes/appbar_theme.dart';
import 'package:notes/utils/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:notes/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:notes/utils/theme/widget_themes/chip_theme.dart';
import 'package:notes/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:notes/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:notes/utils/theme/widget_themes/text_field_theme.dart';
import 'package:notes/utils/theme/widget_themes/text_theme.dart';
import '../constants/app_colors.dart';

class NotesAppTheme {
  NotesAppTheme._();

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      disabledColor: AppColors.grey,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      textTheme: NotesTextTheme.lightTextTheme,
      chipTheme: NotesChipTheme.lightChipTheme,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: NotesAppBarTheme.lightAppBarTheme,
      checkboxTheme: NotesCheckboxTheme.lightCheckboxTheme,
      bottomSheetTheme: NotesBottomSheetTheme.lightBottomSheetTheme,
      elevatedButtonTheme: NotesElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: NotesOutlinedButtonTheme.lightOutlinedButtonTheme,
      inputDecorationTheme: NotesTextFormFieldTheme.lightInputDecorationTheme,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      disabledColor: AppColors.grey,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      textTheme: NotesTextTheme.darkTextTheme,
      chipTheme: NotesChipTheme.darkChipTheme,
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: NotesAppBarTheme.darkAppBarTheme,
      checkboxTheme: NotesCheckboxTheme.darkCheckboxTheme,
      bottomSheetTheme: NotesBottomSheetTheme.darkBottomSheetTheme,
      elevatedButtonTheme: NotesElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: NotesOutlinedButtonTheme.darkOutlinedButtonTheme,
      inputDecorationTheme: NotesTextFormFieldTheme.darkInputDecorationTheme,
    );
  }
}

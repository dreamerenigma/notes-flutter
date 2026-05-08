import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class NotesAppBarTheme{
  NotesAppBarTheme._();

  static final lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.white,
    surfaceTintColor: AppColors.transparent,
    iconTheme: const IconThemeData(color: AppColors.black, size: AppSizes.iconXl),
    actionsIconTheme: const IconThemeData(color: AppColors.black, size: AppSizes.iconXl),
    titleTextStyle: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.w600, color: AppColors.black),
  );
  static final darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.blackGrey,
    surfaceTintColor: AppColors.transparent,
    iconTheme: const IconThemeData(color: AppColors.white, size: AppSizes.iconXl),
    actionsIconTheme: const IconThemeData(color: AppColors.white, size: AppSizes.iconXl),
    titleTextStyle: TextStyle(fontSize: AppSizes.fontSizeLg, fontWeight: FontWeight.w600, color: AppColors.white),
  );
}

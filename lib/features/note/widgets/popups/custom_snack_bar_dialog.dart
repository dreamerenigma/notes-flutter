import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../models/note_model.dart';

void showCustomDialog(BuildContext context, List<NoteModel> selectedNotes) {
  showModalBottomSheet(
    context: context,
    barrierColor: AppColors.transparent,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      const horizontalPadding = 16.0;

      // Делаем анимацию исчезновения
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });

      return AnimatedBuilder(
        animation: ModalRoute.of(context)!.animation!,
        builder: (context, child) {
          final animation = ModalRoute.of(context)!.animation!;
          final slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero,).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

          return SlideTransition(
            position: slideAnimation,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: width - 2 * horizontalPadding,
                margin: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white.withAlpha((0.6 * 255).toInt()),
                      Colors.grey.withAlpha((0.6 * 255).toInt()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedNotes.length == 1 ? "заметка удалена" : "${selectedNotes.length} заметки удалены",
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import 'new_note_bottom_sheet_dialog.dart';

class CategoryPopupMenu extends StatefulWidget {
  const CategoryPopupMenu({super.key});

  @override
  CategoryPopupMenuState createState() => CategoryPopupMenuState();
}

class CategoryPopupMenuState extends State<CategoryPopupMenu> {
  final box = GetStorage();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = box.read('selectedCategory');
  }

  void _onCategorySelected(String category, Color color) {
    setState(() {
      selectedCategory = category;
    });
    box.write('selectedCategory', category);
    Navigator.pop(context, {'text': category, 'color': color});
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Map<String, dynamic>>(
      onSelected: (value) {
        final category = value['text'];
        final color = value['color'];

        setState(() {
          selectedCategory = category;
        });

        box.write('selectedCategory', category);
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.blackGrey
          : AppColors.white,
      itemBuilder: (context) => [
        _menuItem('Работа', AppColors.red),
        _menuItem('Личное', AppColors.blueAccent),
        _menuItem('Шоппинг', AppColors.secondary),
        const PopupMenuDivider(),
        _menuItemNoCategory('Без категории'),
        const PopupMenuDivider(),
        _menuCreateCategory(context),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  PopupMenuItem<Map<String, dynamic>> _menuItem(String text, Color color) {
    return PopupMenuItem(
      value: {'text': text, 'color': color},
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha((0.15 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 4,
                height: 24,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  PopupMenuItem<Map<String, dynamic>> _menuItemNoCategory(String text) {
    return PopupMenuItem(
      value: {'text': text, 'color': AppColors.darkGrey},
      child: Row(
        children: [
          const Icon(Icons.book_outlined, size: 22),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  PopupMenuItem<Map<String, dynamic>> _menuCreateCategory(BuildContext context) {
    return PopupMenuItem(
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // закрываем только меню
          showNewNoteBottomSheetDialog(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Создать',
            style: TextStyle(color: AppColors.blueAccent),
          ),
        ),
      ),
    );
  }
}

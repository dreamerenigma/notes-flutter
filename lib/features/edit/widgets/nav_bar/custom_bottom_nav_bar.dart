import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/models/note_model.dart';
import '../popups/delete_dialog.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onFavorites;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final bool showFavorites;
  final bool showMore;
  final List<NoteModel> selectedNotes;
  final List<NoteModel> allNotes;

  const CustomBottomNavBar({
    super.key,
    required this.onShare,
    this.onFavorites = _defaultCallback,
    required this.onDelete,
    this.onMore = _defaultCallback,
    this.showFavorites = true,
    this.showMore = true,
    required this.selectedNotes,
    required this.allNotes,
  });

  static void _defaultCallback() {}

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 52,
      color: AppColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Expanded(
              child: _buildBottomAppBarItem(
                context,
                Icon(Icons.share_outlined, color: context.isDarkMode ? AppColors.white : AppColors.black),
                'Отправить',
                onShare,
              ),
            ),
            if (showFavorites) Expanded(
              child: _buildBottomAppBarItem(
                context,
                Icon(Icons.star_border_rounded, color: context.isDarkMode ? AppColors.white : AppColors.black),
                'Избранное',
                onFavorites,
              ),
            ),
            Expanded(
              child: _buildBottomAppBarItem(
                context,
                Icon(FluentIcons.delete_48_regular, color: context.isDarkMode ? AppColors.white : AppColors.black),
                'Удалить',
                () => showDeleteDialog(context, onDelete, selectedCount: selectedNotes.length, allCount: allNotes.length, type: 'note'),
              ),
            ),
            if (showMore) Expanded(
              child: _buildBottomAppBarItem(
                context,
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SvgPicture.asset(
                      AppVectors.moreGrid,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn),
                    ),
                  ),
                ),
                'Ещё',
                onMore,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem(BuildContext context, Widget icon, String label, VoidCallback onTap) {
    return Center(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.youngNight,
          highlightColor: AppColors.youngNight,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 11, color: context.isDarkMode ? AppColors.white : AppColors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

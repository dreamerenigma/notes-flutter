import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/models/note_model.dart';
import '../popups/delete_dialog.dart';

class CustomBottomNavBar extends StatefulWidget {
  final VoidCallback onShare;
  final VoidCallback onFavorites;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final bool showFavorites;
  final bool showMore;
  final bool isFavorite;
  final List<NoteModel> selectedNotes;
  final List<NoteModel> allNotes;
  final GlobalKey moreKey;
  final NoteModel? currentNote;

  const CustomBottomNavBar({
    super.key,
    required this.onShare,
    this.onFavorites = _defaultCallback,
    required this.onDelete,
    this.onMore = _defaultCallback,
    this.showFavorites = true,
    this.showMore = true,
    this.isFavorite = false,
    required this.selectedNotes,
    required this.allNotes,
    required this.moreKey,
    this.currentNote,
  });

  static void _defaultCallback() {}

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFavorite != widget.isFavorite) {
      isFavorite = widget.isFavorite;
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    widget.onFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.zero,
        height: 60,
        color: AppColors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildBottomAppBarItem(
                  context,
                  Icon(Icons.share_outlined, color: context.isDarkMode ? AppColors.white : AppColors.black),
                  'Отправить',
                  widget.onShare,
                ),
              ),
              if (widget.showFavorites)
                Expanded(
                  flex: 1,
                  child: _buildBottomAppBarItem(
                    context,
                    Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: isFavorite ? Colors.blue : (context.isDarkMode ? AppColors.white : AppColors.black)),
                    isFavorite ? 'Из избранного' : 'Избранное',
                    _toggleFavorite,
                    textColor: isFavorite ? Colors.blue : null,
                  ),
                ),
              Expanded(
                flex: 1,
                child: _buildBottomAppBarItem(
                  context,
                  Icon(FluentIcons.delete_48_regular, color: context.isDarkMode ? AppColors.white : AppColors.black),
                  'Удалить',
                      () {
                    if (widget.currentNote != null) {

                      showDeleteDialog(context, widget.onDelete, selectedCount: 1, allCount: 1, type: 'note');

                    } else {

                      showDeleteDialog(context, widget.onDelete, selectedCount: widget.selectedNotes.length, allCount: widget.allNotes.length, type: 'note');
                    }
                  },
                ),
              ),
              if (widget.showMore)
                Expanded(
                  flex: 1,
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
                    widget.onMore,
                    key: widget.moreKey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem(BuildContext context, Widget icon, String label, VoidCallback onTap, {Key? key, Color? textColor}) {
    return Center(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(8),
          splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.grey.withAlpha((0.4 * 255).toInt()),
          onTap: onTap,
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  icon,
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: 11, color: textColor ?? (context.isDarkMode ? AppColors.white : AppColors.black)), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

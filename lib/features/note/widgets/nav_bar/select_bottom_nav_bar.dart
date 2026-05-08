import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../models/note_model.dart';
import '../../../task/models/task_model.dart';
import '../../../task/models/task_view_model.dart';
import '../../models/note_view_model.dart';

class SelectBottomNavBar extends StatefulWidget {
  final VoidCallback onShare;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  final List<NoteModel> selectedNotes;
  final List<TaskModel> selectedTasks;
  final NoteViewModel? noteViewModel;
  final TaskViewModel? taskViewModel;
  final bool showShare;
  final bool areAllSelected;

  const SelectBottomNavBar({
    super.key,
    this.onShare = _defaultCallback,
    required this.onMove,
    required this.onDelete,
    required this.onSelectAll,
    this.selectedNotes = const [],
    this.selectedTasks = const [],
    this.noteViewModel,
    this.taskViewModel,
    this.showShare  = true,
    required this.areAllSelected,
  });

  static void _defaultCallback() {}

  @override
  State<SelectBottomNavBar> createState() => _SelectBottomNavBarState();
}

class _SelectBottomNavBarState extends State<SelectBottomNavBar> {
  bool isSelectionMode = false;

  String formatLabel(String text) {
    if (text.length <= 12) return text;
    return '${text.substring(0, 12)}...';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedItems = widget.selectedNotes.isNotEmpty;
    final bool isActiveMode = isSelectionMode || hasSelectedItems;
    final bool isAllSelected = widget.areAllSelected;
    final String selectAllLabel = isAllSelected ? 'Отменить выбор' : 'Выбрать все';
    final Color selectAllColor = isAllSelected ? AppColors.blueAccent : (context.isDarkMode ? AppColors.white : AppColors.black);

    return BottomAppBar(
      height: 66,
      color: AppColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.showShare)
              Expanded(
                child: _buildBottomAppBarItem(
                  context,
                  Icon(Icons.share_outlined, color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black),
                  'Отправить',
                  isActiveMode  ? widget.onShare : null,
                  Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                  hasSelectedItems,
                ),
              ),
            Expanded(
              child: _buildBottomAppBarItem(
                context,
                Icon(
                  Icons.create_new_folder_outlined,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                ),
                'Переместить',
                isActiveMode  ? widget.onMove : null,
                Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                hasSelectedItems,
              ),
            ),
            Expanded(
              child: _buildBottomAppBarItem(
                context,
                Icon(
                  FluentIcons.delete_48_regular,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                ),
                'Удалить',
                isActiveMode ? widget.onDelete : null,
                Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.black,
                hasSelectedItems,
              ),
            ),
            Expanded(
              child: _buildBottomAppBarItem(
                context,
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SvgPicture.asset(
                    AppVectors.selectAll,
                    width: 19,
                    height: 19,
                    colorFilter: ColorFilter.mode(selectAllColor, BlendMode.srcIn),
                  ),
                ),
                selectAllLabel,
                widget.onSelectAll,
                spacing: 4,
                selectAllColor,
                hasSelectedItems,
                alwaysActive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem(BuildContext context, Widget icon, String label, VoidCallback? onTap, Color activeColor, bool isEnabled, {double spacing = 2, bool alwaysActive = false}) {
    final bool canTap = alwaysActive || isEnabled;
    final disabledColor = Theme.of(context).brightness == Brightness.dark ? AppColors.steelGrey : AppColors.grey;
    final Color color = canTap ? activeColor : disabledColor;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(8),
        splashColor: canTap ? AppColors.youngNight : AppColors.transparent,
        highlightColor: canTap ? AppColors.youngNight : AppColors.transparent,
        child: Opacity(
          opacity: canTap ? 1.0 : 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorFiltered(colorFilter: ColorFilter.mode(color, BlendMode.srcIn), child: icon),
              SizedBox(height: spacing),
              Text(formatLabel(label), style: TextStyle(fontSize: 11, color: color), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../screens/note_content_screen.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hasSelectedNotes;
  final bool hasSelectedTasks;
  final GlobalKey<NoteContentScreenState>? noteContentScreenKey;
  final VoidCallback? clearNoteSelection;
  final VoidCallback? clearTaskSelection;
  final Widget? popupMenu;
  final bool showAppBar;
  final bool isSelectionMode;

  const NoteAppBar({
    super.key,
    this.hasSelectedNotes = false,
    this.hasSelectedTasks = false,
    this.isSelectionMode = false,
    this.noteContentScreenKey,
    this.clearNoteSelection,
    this.clearTaskSelection,
    this.popupMenu,
    required this.showAppBar,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAppBar) {
      return const SizedBox(height: 24);
    }

    final bool showCloseIcon = hasSelectedNotes || hasSelectedTasks || isSelectionMode;

    return AppBar(
      backgroundColor: AppColors.transparent,
      leading: showCloseIcon
          ? IconButton(
        icon: const Icon(Icons.close, size: 30),
        onPressed: () {
          clearNoteSelection?.call();
          clearTaskSelection?.call();
        },
      )
          : null,
      actions: [
        if (!showCloseIcon)
          popupMenu ?? const SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'dart:async';
import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/features/note/models/note_model.dart';
import '../../../../../routes/custom_page_route.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_sizes.dart';
import '../../../../../utils/constants/app_vectors.dart';
import '../../../../../utils/formatters/date_formatter.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../screens/add_edit_note_screen.dart';

class NoteItemGrid extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onDelete;
  final VoidCallback onClick;
  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final bool showCheckboxes;
  final bool isLeftColumn;
  final VoidCallback onLongPress;

  final void Function(NoteModel) onNoteSelected;

  const NoteItemGrid({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onClick,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.showCheckboxes,
    required this.onLongPress,
    required this.onNoteSelected,
    required this.isLeftColumn,
  });

  @override
  NoteItemState createState() => NoteItemState();
}

class NoteItemState extends State<NoteItemGrid> {
  late String displayTime;
  Timer? timer;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    displayTime = DateFormatter.formatTime(widget.note.createdAt);
    timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      setState(() {
        displayTime = DateFormatter.formatTime(widget.note.createdAt);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.showCheckboxes) {
          Navigator.push(context, createPageRoute(AddEditNoteScreen(noteType: 'Edit', note: widget.note))).then((result) {
            if (result == 'saved') {
              AppLoaders.successSnackbar(message: 'Заметка обновлена', duration: 4);
            }
          });
        } else {
          widget.onSelectionChanged(!widget.isSelected);
        }
      },
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onLongPress: () {
        if (widget.showCheckboxes) {
          widget.onSelectionChanged(!widget.isSelected);
        } else {
          widget.onLongPress();
        }
      },
      onLongPressStart: (_) {
        setState(() => isPressed = true);
      },
      onLongPressEnd: (_) {
        setState(() => isPressed = false);
      },
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.blueAccent.withAlpha((0.3 * 255).toInt()) : (context.isDarkMode ? AppColors.nightGrey : AppColors.softGrey),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.showCheckboxes
              ? [
                  BoxShadow(color: context.isDarkMode ? AppColors.black : AppColors.white, blurRadius: 4, offset: const Offset(2, 2))
                ]
              : [],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.note.imagePath != null)
                    ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.file(File(widget.note.imagePath!), width: double.infinity, height: 160, fit: BoxFit.cover)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.note.title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.note.isFavorite) ...[
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                            ],
                            Text(displayTime, style: TextStyle(color: AppColors.darkGrey, fontSize: 13)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Container(width: 1.2, height: 14, color: context.isDarkMode ? AppColors.darkGrey : AppColors.darkerGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        widget.showCheckboxes
                          ? ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [AppColors.black, AppColors.transparent],
                                  stops: [0.82, 0.92],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Text(widget.note.description, maxLines: 3, overflow: TextOverflow.clip, style: const TextStyle(color: AppColors.darkGrey)))
                          : Text(widget.note.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.showCheckboxes)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: widget.isSelected ? SvgPicture.asset(AppVectors.checkbox, width: 20, height: 20) : const Icon(FluentIcons.checkbox_unchecked_24_regular, color: AppColors.darkGrey, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

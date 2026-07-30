import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/features/note/models/note_model.dart';
import '../../../../../routes/custom_page_route.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_sizes.dart';
import '../../../../../utils/formatters/date_formatter.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../screens/add_edit_note_screen.dart';

class NoteItemList extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onDelete;
  final VoidCallback onClick;
  final bool isSelected;
  final bool showCheckboxes;
  final DateTime createdAt;
  final VoidCallback onLongPress;
  final Function(int) onSelectionChanged;
  final void Function(NoteModel) onNoteSelected;

  const NoteItemList({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onClick,
    required this.isSelected,
    required this.showCheckboxes,
    required this.createdAt,
    required this.onLongPress,
    required this.onSelectionChanged,
    required this.onNoteSelected,
  });

  @override
  NoteItemListState createState() => NoteItemListState();
}

class NoteItemListState extends State<NoteItemList> {
  late String displayTime;
  bool isPressed = false;
  Timer? timer;

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
    log('🟦 BUILD NOTE ITEM');
    log('note id: ${widget.note.id}');
    log('showCheckboxes: ${widget.showCheckboxes}');
    log('isSelected: ${widget.isSelected}');

    return GestureDetector(
      onTap: () {
        if (!widget.showCheckboxes) {
          Navigator.push(
            context,
            createPageRoute(AddEditNoteScreen(noteType: 'Edit', note: widget.note)),
          ).then((result) {
            if (result == 'saved') {
              AppLoaders.successSnackbar(message: 'Заметка обновлена', duration: 4);
            }
          });
        } else {
          final id = widget.note.id;

          widget.onSelectionChanged(id);
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
        final id = widget.note.id;

        if (!widget.showCheckboxes) {
          widget.onLongPress();
        } else {
          widget.onSelectionChanged(id);
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).copyWith(right: widget.showCheckboxes ? 8.0 : 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.blueAccent.withAlpha((0.3 * 255).toInt()) : (context.isDarkMode ? AppColors.greySlate : AppColors.white),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.showCheckboxes
              ? [
                  BoxShadow(color: context.isDarkMode? AppColors.black : AppColors.white, blurRadius: 4, offset: const Offset(2, 2))
                ]
              : [],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(widget.note.title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayTime, style: TextStyle(color: context.isDarkMode? AppColors.darkGrey : AppColors.darkGrey)),
                      const Text(' | ', style: TextStyle(color: AppColors.darkGrey)),
                      Expanded(
                        child: Text(
                          widget.note.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.isDarkMode ? AppColors.darkGrey : AppColors.darkGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: widget.showCheckboxes ? (widget.isSelected ? Icon(Icons.check_box_rounded, color: AppColors.blueAccent) : Icon(Icons.check_box_outline_blank, color: AppColors.darkGrey)) : null,
          ),
        ),
      ),
    );
  }
}

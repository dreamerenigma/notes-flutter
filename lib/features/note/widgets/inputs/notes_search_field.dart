import 'package:flutter/material.dart';
import 'package:notes/features/note/widgets/inputs/search_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

class NotesSearchField extends StatefulWidget {
  final Function(String) onChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool selectionMode;
  final bool isFocused;
  final VoidCallback onClear;

  const NotesSearchField({
    super.key,
    required this.onChanged,
    required this.controller,
    required this.focusNode,
    required this.selectionMode,
    required this.isFocused,
    required this.onClear,
  });

  @override
  State<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends State<NotesSearchField> {
  @override
  Widget build(BuildContext context) {
    return SearchTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: !widget.selectionMode,

      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        hintText: 'Поиск заметок',
        hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd,
            color: widget.selectionMode ? (Theme.of(context).brightness == Brightness.dark ? AppColors.greyDarkerV1 : AppColors.grey) : (Theme.of(context).brightness == Brightness.dark ? AppColors.grey : AppColors.black),
            fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        fillColor: widget.isFocused
            ? (Theme.of(context).brightness == Brightness.dark ? AppColors.blackGrey : AppColors.white)
            : (widget.selectionMode ? (Theme.of(context).brightness == Brightness.dark ? AppColors.black : AppColors.white.withAlpha((0.5 * 255).toInt())) : (Theme.of(context).brightness == Brightness.dark ? AppColors.deepNight : AppColors.softGrey)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(Icons.search_rounded,
            color: widget.selectionMode ? (Theme.of(context).brightness == Brightness.dark ? AppColors.greyDarkerV1 : AppColors.grey) : (Theme.of(context).brightness == Brightness.dark ? AppColors.grey : AppColors.black),
          ),
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: widget.onClear,
        )
            : null,
      ),
    );
  }
}
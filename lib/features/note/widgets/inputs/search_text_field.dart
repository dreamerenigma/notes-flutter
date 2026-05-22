import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../utils/constants/app_colors.dart';

class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final InputDecoration decoration;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.enabled = true,
    this.decoration = const InputDecoration(),
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();

    widget.focusNode.hasFocus;

    _focusListener = () {
      if (!mounted) return;

      setState(() {
        widget.focusNode.hasFocus;
      });
    };

    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
        selectionHandleColor: AppColors.blue,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(maxHeight: 40),
        decoration: BoxDecoration(
          color: isFocused ? (context.isDarkMode ? AppColors.blackGrey : AppColors.white) : (context.isDarkMode ? AppColors.deepNight : AppColors.softGrey),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          readOnly: !widget.enabled,
          decoration: widget.decoration,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    );
  }
}

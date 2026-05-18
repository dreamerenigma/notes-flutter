import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../note/widgets/popups/custom_category_dialog.dart';

class NoteForm extends StatefulWidget {
  final TextEditingController noteTitleController;
  final FocusNode noteTitleFocusNode;
  final TextEditingController noteDescriptionController;
  final FocusNode noteDescriptionFocusNode;
  final ValueNotifier<int> characterCountNotifier;
  final String? createdAt;
  final bool isNewNote;
  final String? imagePath;
  final bool isBold;

  const NoteForm({
    super.key,
    required this.noteTitleController,
    required this.noteTitleFocusNode,
    required this.noteDescriptionController,
    required this.noteDescriptionFocusNode,
    required this.characterCountNotifier,
    required this.isNewNote,
    required this.isBold,
    this.createdAt,
    this.imagePath,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final urlRegex = RegExp(r'((https?://)?[\w\-]+(\.[\w\-]+)+[/#?]?.*)');
  final List<String> undoStack = [];
  final List<String> redoStack = [];
  late String displayTime;
  late Color selectedColor;
  late bool isDark;
  String? selectedCategoryText;
  String? imagePath;
  bool hasUnsavedChanges = false;
  bool isPressed = false;
  bool isEditing = true;
  bool isFocused = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    displayTime = widget.isNewNote ? 'Сегодня ${DateFormat('HH:mm').format(DateTime.now())}' : widget.createdAt!;
    imagePath = widget.imagePath;
    widget.noteTitleController.addListener(_onFormChanged);
    widget.noteDescriptionController.addListener(_onFormChanged);
    selectedCategoryText = null;
    widget.noteDescriptionFocusNode.addListener(() {
      setState(() {
        isFocused = widget.noteDescriptionFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    widget.noteTitleController.removeListener(_onFormChanged);
    widget.noteDescriptionController.removeListener(_onFormChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedColor = Theme.of(context).brightness == Brightness.dark ? AppColors.darkSlate.withAlpha((0.6 * 255).toInt()) : AppColors.softGrey.withAlpha((0.6 * 255).toInt());
  }

  void _onFormChanged() {
    setState(() {
      hasUnsavedChanges = true;
    });
  }

  void updateImagePath(String? newImagePath) {
    setState(() {
      imagePath = newImagePath;
    });
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  List<TextSpan> buildLinkSpans(String text) {
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final url = text.substring(match.start, match.end);

      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(color: AppColors.blueAccent, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) {
                  return Container(padding: const EdgeInsets.all(20), child: Text('Открыта ссылка:\n$url'));
                },
              );
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.dragged)) {
          return AppColors.darkerGrey;
        }
        return AppColors.darkerGrey;
      })),
      child: Scrollbar(
        thickness: 4,
        thumbVisibility: false,
        radius: const Radius.circular(8),
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditing)
                  TextSelectionTheme(
                    data: TextSelectionThemeData(
                      cursorColor: AppColors.blue,
                      selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
                      selectionHandleColor: AppColors.blue,
                    ),
                    child: TextField(
                      controller: widget.noteTitleController,
                      focusNode: widget.noteTitleFocusNode,
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 400), () {
                          undoStack.add(value);
                          redoStack.clear();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Название',
                        hintStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(displayTime, style: TextStyle(fontSize: AppSizes.fontSizeSm, fontWeight: FontWeight.w300, color: AppColors.darkGrey)),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields),
                          child: Ink(
                            decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.spaceBtwInputFields),
                              onTap: () async {
                                final result = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  barrierColor: AppColors.transparent,
                                  builder: (BuildContext context) {
                                    return const CustomCategoryDialog();
                                  },
                                );

                                if (result != null) {
                                  setState(() {
                                    selectedCategoryText = result['text'] as String;
                                    selectedColor = result['color'] as Color;
                                  });
                                }

                                isPressed = !isPressed;
                              },
                              child: Container(
                                padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 4),
                                decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(selectedCategoryText ?? 'Без категории', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down_outlined, size: 20, color: AppColors.darkGrey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(File(imagePath!), width: 250, height: 250, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imagePath = null;
                                });
                              },
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.grey.withAlpha((0.7 * 255).toInt()),
                                child: const Icon(Icons.close_rounded, color: AppColors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Opacity(
                        opacity: isFocused ? 1 : 0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            cursorColor: AppColors.blue,
                            selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()),
                            selectionHandleColor: AppColors.blue,
                          ),
                          child: TextField(
                            controller: widget.noteDescriptionController,
                            focusNode: widget.noteDescriptionFocusNode,
                            decoration: InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w400, height: 1.5, fontFamily: 'Poppins'),
                            maxLines: 30,
                          ),
                        ),
                      ),
                      if (!isFocused)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              widget.noteDescriptionFocusNode.requestFocus();
                              setState(() {});
                            },
                            child: AbsorbPointer(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w400, height: 1.4, letterSpacing: 0.5, fontFamily: 'Poppins'),
                                  children: buildLinkSpans(widget.noteDescriptionController.text),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: widget.characterCountNotifier,
                    builder: (context, characterCount, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text('$characterCount', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

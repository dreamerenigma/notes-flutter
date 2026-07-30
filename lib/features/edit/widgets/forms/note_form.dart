import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';

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
  final bool isListMode;
  final ValueChanged<bool> onListModeChanged;
  final ValueChanged<String?> onImageChanged;

  const NoteForm({
    super.key,
    required this.noteTitleController,
    required this.noteTitleFocusNode,
    required this.noteDescriptionController,
    required this.noteDescriptionFocusNode,
    required this.characterCountNotifier,
    required this.isNewNote,
    required this.isBold,
    required this.isListMode,
    required this.onListModeChanged,
    required this.imagePath,
    required this.onImageChanged,
    this.createdAt,
  });

  @override
  State<NoteForm> createState() => NoteFormState();
}

class NoteFormState extends State<NoteForm> {
  final List<FocusNode> listFocusNodes = [];
  final GlobalKey<NoteFormState> noteFormKey = GlobalKey<NoteFormState>();
  final urlRegex = RegExp(r'((https?://)?[\w\-]+(\.[\w\-]+)+[/#?]?.*)');
  final List<TextEditingController> listControllers = [];
  late bool isDark;
  String? selectedCategoryText;
  bool hasUnsavedChanges = false;
  bool isPressed = false;
  bool isEditing = true;
  bool isFocused = false;
  FocusNode? activeFocusNode;

  @override
  void initState() {
    super.initState();
    listControllers.add(TextEditingController());
    listFocusNodes.add(FocusNode());
    widget.noteTitleController.addListener(_onFormChanged);
    widget.noteDescriptionController.addListener(_onFormChanged);
    widget.noteDescriptionFocusNode.addListener(_focusListener);
    selectedCategoryText = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusListener();
      }
    });
  }

  @override
  void dispose() {
    widget.noteTitleController.removeListener(_onFormChanged);
    widget.noteDescriptionController.removeListener(_onFormChanged);
    widget.noteDescriptionFocusNode.removeListener(_focusListener);
    for (final controller in listControllers) {
      controller.dispose();
    }
    for (final node in listFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _focusListener() {
    if (!mounted) return;

    setState(() {
      isFocused = widget.noteDescriptionFocusNode.hasFocus;
    });
  }

  void _onFormChanged() {
    if (!mounted) return;

    setState(() {
      hasUnsavedChanges = true;
    });
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onImageChanged(image.path);
    }
  }

  List<TextSpan> buildLinkSpans(String text) {
    final spans = <TextSpan>[];
    final matches = urlRegex.allMatches(text);
    int start = 0;

    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

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

  void convertTextToList() {
    final text = widget.noteDescriptionController.text;

    setState(() {
      listControllers..clear()..addAll(text.split('\n').map((e) => TextEditingController(text: e)));
      listFocusNodes..clear()..addAll(List.generate(listControllers.length, (_) => FocusNode()));
      widget.noteDescriptionController.clear();
      widget.onListModeChanged(true);
    });
  }

  void convertListToText() {
    final text = listControllers.map((c) => c.text).join('\n');

    widget.noteDescriptionController.text = text;
    widget.onListModeChanged(false);
    setState(() {});
  }



  Future<ui.Image> _getImageInfo(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    return frame.image;
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (widget.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: FutureBuilder<ui.Image>(
                          future: _getImageInfo(File(widget.imagePath!)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final image = snapshot.data!;
                            final aspectRatio = image.width / image.height;

                            double width = 250;
                            double height = 250;

                            if (aspectRatio < 1) {
                              height = 350;
                            }

                            if (aspectRatio > 1) {
                              width = 350;
                              height = 250;
                            }

                            return  Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(widget.imagePath!), width: width, height: height, fit: BoxFit.cover)),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        widget.onImageChanged(null);
                                      });
                                    },
                                    child: CircleAvatar(radius: 11, backgroundColor: AppColors.black.withAlpha((0.2 * 255).toInt()), child: const Icon(Icons.close_rounded, color: AppColors.white, size: 20)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(height: 14),
                  widget.isListMode ? _buildListEditor() : Stack(
                    children: [
                      Opacity(
                        opacity: isFocused ? 1 : 0,
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(cursorColor: AppColors.blue, selectionColor: AppColors.blue.withAlpha((0.3 * 255).toInt()), selectionHandleColor: AppColors.blue),
                          child: TextField(
                            controller: widget.noteDescriptionController,
                            focusNode: widget.noteDescriptionFocusNode,
                            onTap: () {
                              activeFocusNode = widget.noteDescriptionFocusNode;
                            },
                            decoration: InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(fontSize: AppSizes.fontSizeMd),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(fontSize: 15, fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w400, height: 1.45, fontFamily: 'Poppins'),
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
                                  style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: 15, fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w400, height: 1.4, letterSpacing: 0.5, fontFamily: 'Poppins'),
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
                        child: Align(alignment: Alignment.bottomRight, child: Text('$characterCount', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey))),
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

  Widget _buildListEditor() {
    return Column(
      children: List.generate(listControllers.length, (index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: Icon(BootstrapIcons.circle, size: 22, color: context.isDarkMode ? AppColors.white : AppColors.black)),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {

                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }

                  /// ===== ENTER =====
                  if (event.logicalKey == LogicalKeyboardKey.enter) {

                    final newController = TextEditingController();
                    final newFocus = FocusNode();

                    setState(() {
                      listControllers.insert(index + 1, newController);
                      listFocusNodes.insert(index + 1, newFocus);
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        newFocus.requestFocus();
                      }
                    });

                    return KeyEventResult.handled;
                  }

                  /// ===== BACKSPACE =====
                  if (event.logicalKey == LogicalKeyboardKey.backspace) {
                    final controller = listControllers[index];

                    if (controller.text.isEmpty) {
                      if (listControllers.length == 1) {
                        widget.onListModeChanged(false);
                        return KeyEventResult.handled;
                      }

                      final currentFocus = FocusScope.of(context);

                      setState(() {
                        listControllers[index].dispose();
                        listFocusNodes[index].dispose();

                        listControllers.removeAt(index);
                        listFocusNodes.removeAt(index);
                      });

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        currentFocus.requestFocus();
                      });

                      if (index > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          listFocusNodes[index - 1].requestFocus();
                        });
                      }

                      return KeyEventResult.handled;
                    }
                  }

                  return KeyEventResult.ignored;
                },
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(
                    cursorColor: AppColors.blue,
                    selectionColor:
                    AppColors.blue.withAlpha((0.3 * 255).toInt()),
                    selectionHandleColor: AppColors.blue,
                  ),
                  child: TextField(
                    key: ValueKey(listFocusNodes[index]),
                    controller: listControllers[index],
                    focusNode: listFocusNodes[index],
                    cursorHeight: 24,
                    maxLines: 30,
                    decoration: const InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                    textCapitalization:
                    TextCapitalization.sentences,
                    style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeMd, fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w400, height: 1.5, fontFamily: 'Poppins'),
                    onTap: () {
                      activeFocusNode = listFocusNodes[index];
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

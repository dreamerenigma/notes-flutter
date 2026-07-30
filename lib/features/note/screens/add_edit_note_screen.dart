import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_images.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/popups/app_popup_menu.dart';
import '../../../utils/popups/items/popup_menu_items.dart';
import '../../edit/widgets/dialogs/anchored_dialog.dart';
import '../../edit/widgets/editors/handwriting_editor.dart';
import '../controllers/note_text_style_controller.dart';
import '../models/note_model.dart';
import '../models/note_view_model.dart';
import '../../edit/widgets/forms/note_form.dart';
import '../../edit/widgets/nav_bar/custom_bottom_nav_bar.dart';
import '../../edit/widgets/nav_bar/edit_message_bottom_nav_bar.dart';
import '../../edit/widgets/popups/open_gallery_dialog.dart';
import '../../edit/widgets/popups/save_dialog.dart';
import '../../edit/widgets/popups/text_style_bottom_sheet_dialog.dart';
import '../widgets/bars/app_bars/add_edit_note_app_bar.dart';
import '../widgets/dialogs/send_note_bottom_sheet_dialog.dart';
import '../widgets/popups/custom_category_dialog.dart';

class AddEditNoteScreen extends StatefulWidget {
  final String noteType;
  final NoteModel? note;

  const AddEditNoteScreen({
    super.key,
    this.noteType = 'Add',
    this.note,
  });

  @override
  AddEditNoteScreenState createState() => AddEditNoteScreenState();
}

class AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final GlobalKey moreKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey<NoteFormState> noteFormKey = GlobalKey<NoteFormState>();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteDescriptionController = TextEditingController();
  final TextFormattingController formattingController = TextFormattingController();
  final FocusNode _noteTitleFocusNode = FocusNode();
  final FocusNode _noteDescriptionFocusNode = FocusNode();
  final ValueNotifier<int> _characterCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isFieldFocused = ValueNotifier<bool>(false);
  final GetStorage storage = GetStorage();
  late String backgroundImage;
  late String originalTitle;
  late String originalDescription;
  late String currentNoteType;
  late String displayTime;
  late Color selectedColor;
  Timer? _timer;
  String? imagePath;
  String currentText = "";
  String? selectedCategoryText;
  List<String> undoStack = [];
  List<String> redoStack = [];
  List<String> listItems = [];
  bool isBold = false;
  bool hasUnsavedChanges = false;
  bool hasSavedChanges = false;
  bool isEditing = true;
  bool isListMode = false;
  bool isFavorite = false;
  bool isHandwritingMode = false;
  bool _initialized = false;
  NoteModel? currentNote;
  TextEditingValue? savedTextSelection;

  bool get showBottomBar => !isHandwritingMode;

  @override
  void initState() {
    super.initState();

    final box = GetStorage();

    backgroundImage = box.read<String>('backgroundImage') ?? '';

    displayTime = widget.noteType == 'Add' ? 'Сегодня ${DateFormat('HH:mm').format(DateTime.now())}' : DateFormat('d MMMM, HH:mm', 'ru').format(widget.note!.createdAt);

    currentNoteType = widget.noteType;
    currentNote = widget.note;

    isBold = storage.read<bool>('isBold') ?? false;

    if (widget.noteType == 'Edit' && widget.note != null) {
      imagePath = widget.note!.imagePath;

      _noteTitleController.text = widget.note!.title;
      _noteDescriptionController.text = widget.note!.description;
    }

    _noteTitleFocusNode.addListener(_updateFocusState);
    _noteDescriptionFocusNode.addListener(_updateFocusState);

    _noteTitleController.addListener(_checkForUnsavedChanges);
    _noteDescriptionController.addListener(_checkForUnsavedChanges);

    _noteDescriptionController.addListener(() {
      _characterCountNotifier.value = _noteDescriptionController.text.length;
    });

    _noteTitleFocusNode.addListener(() => setState(() {}));
    _noteDescriptionFocusNode.addListener(() => setState(() {}));

    originalTitle = _noteTitleController.text;
    originalDescription = _noteDescriptionController.text;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteTitleFocusNode.dispose();
    _noteDescriptionFocusNode.dispose();
    _characterCountNotifier.dispose();
    _isFieldFocused.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      selectedColor = context.isDarkMode ? AppColors.darkSlate.withAlpha((0.6 * 255).toInt()) : AppColors.softGrey.withAlpha((0.6 * 255).toInt());

      _initialized = true;
    }
    if (widget.noteType == 'Add') {
      FocusScope.of(context).requestFocus(_noteDescriptionFocusNode);
    }
    if (backgroundImage.isEmpty) {
      backgroundImage = context.isDarkMode ? AppImages.noteBgDark : AppImages.noteBgLight;
    }
  }

  bool get hasChanges {
    return _noteTitleController.text != originalTitle || _noteDescriptionController.text != originalDescription;
  }

  void _updateFocusState() {
    _isFieldFocused.value = _noteTitleFocusNode.hasFocus || _noteDescriptionFocusNode.hasFocus;
  }

  void _unfocusAllFields() {
    _noteTitleFocusNode.unfocus();
    _noteDescriptionFocusNode.unfocus();
  }

  void showImagePickerDialog(BuildContext context) {
    log('Открытие диалога для выбора изображения');
    showOpenGalleryDialog(context, (XFile? image) {
      if (image != null) {
        log('Изображение выбрано: ${image.path}');
      } else {
        log('Изображение не выбрано');
      }

      setState(() {
        imagePath = image?.path;
        if (imagePath != null) {
          log('Путь изображения сохранен: $imagePath');
        } else {
          log('Путь изображения не сохранен');
        }
      });

      log('AddEditNoteScreen imagePath: $imagePath');
    });
  }

  void changeBackground(String newBackground) {
    final box = GetStorage();
    box.write('backgroundImage', newBackground);
    setState(() {
      backgroundImage = newBackground;
      imagePath = newBackground;
    });
  }

  void _checkForUnsavedChanges() {
    final noteTitle = _noteTitleController.text;
    final noteDescription = _noteDescriptionController.text;
    setState(() {
      hasUnsavedChanges = noteTitle.isNotEmpty || noteDescription.isNotEmpty;
    });
  }

  Future<void> handleBackButton() async {
    if (!hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldSave = await showSaveDialog(context);

    if (shouldSave) {
      await saveNote(popAfterSave: true);
    } else {
      Navigator.pop(context, 'discarded');
    }
  }

  Future<void> saveNote({bool popAfterSave = false}) async {
    final noteTitle = _noteTitleController.text;
    final noteDescription = _noteDescriptionController.text;

    if (noteTitle.isEmpty || noteDescription.isEmpty) return;

    if (currentNoteType == 'Edit') {

      final updatedNote = currentNote!.copyWith(title: noteTitle, description: noteDescription, imagePath: imagePath, updatedAt: DateTime.now());

      await Provider.of<NoteViewModel>(context, listen: false).updateNote(updatedNote);


    } else {

      final newNote = NoteModel(id: 0, title: noteTitle, description: noteDescription, createdAt: DateTime.now(), imagePath: imagePath, updatedAt: DateTime.now());
      final createdNote = await Provider.of<NoteViewModel>(context, listen: false).addNote(newNote);

      setState(() {
        currentNoteType = 'Edit';
        currentNote = createdNote;
      });

    }

    originalTitle = _noteTitleController.text;
    originalDescription = _noteDescriptionController.text;

    hasSavedChanges = true;

    if (popAfterSave) {
      Navigator.pop(context, 'saved');
    }
  }

  Future<void> _showCategoryDialog() async {
    final result = await AnchoredDialog.show<Map<String, dynamic>>(context: context, targetKey: _categoryKey, leftOffset: -10, child: const CustomCategoryDialog());

    if(result != null){
      setState(() {
        selectedCategoryText = result['text'] as String;
        selectedColor = result['color'] as Color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log('BACKGROUND PATH: $backgroundImage');

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(backgroundImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(Icons.arrow_back, color: context.isDarkMode ? AppColors.white : AppColors.black), onPressed: handleBackButton),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_noteTitleFocusNode.hasFocus || _noteDescriptionFocusNode.hasFocus)
                            Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: undoStack.isNotEmpty ? () {
                                  redoStack.add(_noteDescriptionController.text);
                                  final previous = undoStack.removeLast();
                                  _noteDescriptionController.text = previous;
                                  _noteDescriptionController.selection = TextSelection.collapsed(offset: previous.length);
                                } : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    AppVectors.arrowLeft,
                                    width: 32,
                                    height: 32,
                                    colorFilter: ColorFilter.mode(
                                      undoStack.isNotEmpty ? Theme.of(context).iconTheme.color ?? AppColors.black : AppColors.grey.withAlpha((0.3 * 255).toInt()),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_noteTitleFocusNode.hasFocus || _noteDescriptionFocusNode.hasFocus)
                            Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: redoStack.isNotEmpty ? () {
                                  redoStack.add(_noteDescriptionController.text);
                                  final previous = redoStack.removeLast();
                                  _noteDescriptionController.text = previous;
                                  _noteDescriptionController.selection = TextSelection.collapsed(offset: previous.length);
                                } : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    AppVectors.arrowRight,
                                    width: 32,
                                    height: 32,
                                    colorFilter: ColorFilter.mode(
                                      undoStack.isNotEmpty ? Theme.of(context).iconTheme.color ?? AppColors.black : AppColors.grey.withAlpha((0.3 * 255).toInt()),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_noteTitleFocusNode.hasFocus || _noteDescriptionFocusNode.hasFocus)
                            IconButton(
                              icon: Icon(Icons.check_rounded, color: context.isDarkMode ? AppColors.white : AppColors.black, size: 27),
                              onPressed: () async {
                                _unfocusAllFields();
                                await saveNote(popAfterSave: false);
                                setState(() {
                                  isEditing = false;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddEditNoteAppBar(
                        titleController: _noteTitleController,
                        titleFocusNode: _noteTitleFocusNode,
                        displayTime: displayTime,
                        selectedColor: selectedColor,
                        selectedCategoryText: selectedCategoryText,
                        isEditing: isEditing,
                        categoryKey: _categoryKey,
                        onCategoryTap: () {
                          _showCategoryDialog();
                        },
                      ),
                      Expanded(
                        child: isHandwritingMode
                          ? HandwritingEditor(
                              onClose: () {
                                setState(() {
                                  isHandwritingMode = false;
                                });
                              },
                            )
                          : NoteForm(
                              key: noteFormKey,
                              noteTitleController: _noteTitleController,
                              noteTitleFocusNode: _noteTitleFocusNode,
                              noteDescriptionController: _noteDescriptionController,
                              noteDescriptionFocusNode: _noteDescriptionFocusNode,
                              characterCountNotifier: _characterCountNotifier,
                              isNewNote: widget.noteType == 'Add',
                              imagePath: imagePath,
                              isBold: isBold,
                              isListMode: isListMode,
                              onListModeChanged: (value) {
                                setState(() {
                                  isListMode = value;
                                });
                              },
                              onImageChanged: (path) {
                                setState(() {
                                  imagePath = path;
                                });
                              },
                            ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isFieldFocused,
                  builder: (context, isFieldFocused, child) {
                    if (!showBottomBar) {
                      return const SizedBox.shrink();
                    }

                    return isFieldFocused
                      ? EditMessageBottomNavBar(
                          onList: () {
                            setState(() {
                              final wasListMode = isListMode;

                              isListMode = !isListMode;

                              if (!wasListMode && isListMode) {
                                noteFormKey.currentState?.convertTextToList();
                              }

                              if (wasListMode && !isListMode) {
                                noteFormKey.currentState?.convertListToText();
                              }
                            });
                          },
                          onTextStyle: () async {
                            savedTextSelection = _noteDescriptionController.value;
                            formattingController.setSelection(_noteDescriptionController.selection);

                            await showTextStyleBottomSheetDialog(context, changeBackground, _noteDescriptionController, formattingController);

                            if (savedTextSelection != null) {
                              _noteDescriptionFocusNode.requestFocus();
                              _noteDescriptionController.value = savedTextSelection!;
                            }
                          },
                          onGallery: () => showImagePickerDialog(context),
                          onHandwritingInput: () {
                            _unfocusAllFields();

                            FocusScope.of(context).unfocus();

                            setState(() {
                              isHandwritingMode = true;
                            });
                          },
                        )
                      : CustomBottomNavBar(
                          onShare: () {
                            showSendNoteBottomSheetDialog(context);
                          },
                          onFavorites: () {
                            final noteViewModel = context.read<NoteViewModel>();
                            final updatedNote = widget.note!.copyWith(isFavorite: !widget.note!.isFavorite, updatedAt: DateTime.now());

                            noteViewModel.updateNote(updatedNote);
                          },
                          onDelete: () {
                            if (widget.note != null) {
                              context.read<NoteViewModel>().deleteNote(widget.note!);
                              Navigator.pop(context);
                            }
                          },
                          onMore: () async {
                            final result = await AppPopupMenu.showAt<int>(
                              context: context,
                              targetKey: moreKey,
                              maxWidth: 212,
                              offset: const Offset(-20, -110),
                              items: [
                                PopupMenuItems.item(value: 1, text: 'Добавить блокировку', context: context),
                                PopupMenuItems.divider(context),
                                PopupMenuItems.item(value: 2, text: 'Печать', context: context),
                              ],
                            );
                            if(result == 1){}
                            if(result == 2){}
                          },
                          currentNote: widget.note,
                          selectedNotes: const [],
                          allNotes: const [],
                          moreKey: moreKey,
                          isFavorite: widget.note?.isFavorite ?? false,
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

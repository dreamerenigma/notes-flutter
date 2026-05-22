import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_images.dart';
import '../../../utils/constants/app_vectors.dart';
import '../../../utils/popups/dialogs.dart';
import '../models/note_model.dart';
import '../models/note_view_model.dart';
import '../../edit/widgets/forms/note_form.dart';
import '../../edit/widgets/nav_bar/custom_bottom_nav_bar.dart';
import '../../edit/widgets/nav_bar/edit_message_bottom_nav_bar.dart';
import '../../edit/widgets/popups/open_gallery_dialog.dart';
import '../../edit/widgets/popups/save_dialog.dart';
import '../../edit/widgets/popups/text_style_bottom_sheet_dialog.dart';

class AddEditNoteScreen extends StatefulWidget {
  final String noteType;
  final String? noteTitle;
  final String? noteDescription;
  final DateTime createdAt;
  final int? noteID;

  const AddEditNoteScreen({
    super.key,
    this.noteType = 'Add',
    this.noteTitle,
    this.noteDescription,
    this.noteID,
    required this.createdAt,
  });

  @override
  AddEditNoteScreenState createState() => AddEditNoteScreenState();
}

class AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final GlobalKey<NoteFormState> noteFormKey = GlobalKey<NoteFormState>();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteDescriptionController = TextEditingController();
  final FocusNode _noteTitleFocusNode = FocusNode();
  final FocusNode _noteDescriptionFocusNode = FocusNode();
  final ValueNotifier<int> _characterCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isFieldFocused = ValueNotifier<bool>(false);
  final GetStorage storage = GetStorage();
  late String backgroundImage;
  late String originalTitle;
  late String originalDescription;
  Timer? _timer;
  String? imagePath;
  String currentText = "";
  List<String> undoStack = [];
  List<String> redoStack = [];
  List<String> listItems = [];
  bool isBold = false;
  bool hasUnsavedChanges = false;
  bool hasSavedChanges = false;
  bool isEditing = true;
  bool isListMode = false;

  @override
  void initState() {
    super.initState();

    isBold = storage.read<bool>('isBold') ?? false;

    if (widget.noteType == 'Edit') {
      _noteTitleController.text = widget.noteTitle ?? '';
      _noteDescriptionController.text = widget.noteDescription ?? '';
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
    final box = GetStorage();

    backgroundImage = box.read('backgroundImage') ?? (context.isDarkMode ? AppImages.noteBgDark : AppImages.noteBgLight);

    if (widget.noteType == 'Add') {
      FocusScope.of(context).requestFocus(_noteDescriptionFocusNode);
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
    });
  }

  void changeBackground(String newBackground) {
    setState(() {
      backgroundImage = newBackground;
      imagePath = newBackground;
      final box = GetStorage();
      box.write('backgroundImage', newBackground);
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

    final creationDate = widget.noteType == 'Edit' ? widget.createdAt : DateTime.now();

    if (widget.noteType == 'Edit') {
      if (widget.noteID == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Note ID is null')));
        return;
      }

      final updatedNote = NoteModel(id: widget.noteID!, title: noteTitle, description: noteDescription, createdAt: creationDate, imagePath: imagePath, updatedAt: DateTime.now());
      Provider.of<NoteViewModel>(context, listen: false).updateNote(updatedNote);
    } else {
      final newNote = NoteModel(id: 0, title: noteTitle, description: noteDescription, createdAt: DateTime.now(), imagePath: imagePath, updatedAt: DateTime.now());
      Provider.of<NoteViewModel>(context, listen: false).addNote(newNote);
      CustomIconSnackBar.showAnimatedSnackBar(context, 'Заметка добавлена', icon: const Icon(Icons.check_circle, color: AppColors.success), backgroundColor: AppColors.darkerGrey.withAlpha((0.15 * 255).toInt()));
    }

    originalTitle = _noteTitleController.text;
    originalDescription = _noteDescriptionController.text;

    hasSavedChanges = true;

    if (popAfterSave) {
      Navigator.pop(context, 'saved');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: handleBackButton),
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
                              icon: const Icon(Icons.check, size: 27),
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
                  child: NoteForm(
                    key: noteFormKey,
                    noteTitleController: _noteTitleController,
                    noteTitleFocusNode: _noteTitleFocusNode,
                    noteDescriptionController: _noteDescriptionController,
                    noteDescriptionFocusNode: _noteDescriptionFocusNode,
                    characterCountNotifier: _characterCountNotifier,
                    isNewNote: true,
                    imagePath: imagePath,
                    isBold: isBold,
                    isListMode: isListMode,
                    onListModeChanged: (value) {
                      setState(() {
                        isListMode = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isFieldFocused,
              builder: (context, isFieldFocused, child) {
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
                      onTextStyle: () {
                        showTextStyleBottomSheetDialog(context, changeBackground);
                      },
                      onGallery: () => showImagePickerDialog(context),
                      onHandwritingInput: () {})
                  : CustomBottomNavBar(
                      onShare: () {},
                      onFavorites: () {},
                      onDelete: () {},
                      onMore: () {},
                      selectedNotes: const [],
                      allNotes: const [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

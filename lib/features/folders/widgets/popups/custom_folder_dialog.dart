import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/utils/constants/app_vectors.dart';
import '../../../../core/enums/folder_dialog_type.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../routes/custom_page_route.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../note/models/category_model.dart';
import '../../../task/models/task_view_model.dart';
import '../../../utils/widgets/dividers/custom_divider.dart';
import '../../../utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/popups/app_popup_menu.dart';
import '../../../../utils/popups/items/popup_menu_items.dart';
import '../../../note/widgets/popups/new_note_bottom_sheet_dialog.dart';
import '../../../note/models/note_model.dart';
import '../../../note/models/note_view_model.dart';
import '../../models/folder_model.dart';
import '../../models/folder_view_model.dart';
import '../../screens/change_folder_screen.dart';
import 'folder_bottom_sheet_dialog.dart';

class CategoryIconData {
  final String icon;
  final double size;

  const CategoryIconData({required this.icon, this.size = 24});
}

class CustomFolderDialog extends StatefulWidget {
  final FolderDialogType type;
  final Color backgroundColor;

  const CustomFolderDialog({
    super.key,
    required this.type,
    required this.backgroundColor,
  });

  @override
  CustomFolderDialogState createState() => CustomFolderDialogState();
}

class CustomFolderDialogState extends State<CustomFolderDialog> {
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();
  final folderVM = Get.find<FolderViewModel>();
  final GlobalKey _manageKey = GlobalKey();
  final box = GetStorage();
  bool isMyNotesExpanded = false;
  Map<int?, List<CategoryModel>> folderCategories = {};

  String? selectedCategory;
  String get _prefix => widget.type == FolderDialogType.notes ? 'notes' : 'tasks';

  Map<String, CategoryIconData> get categoryIcons {
    switch (widget.type) {
      case FolderDialogType.notes:
        return {
          'Все заметки': const CategoryIconData(icon: AppVectors.note),
          'Без категории': const CategoryIconData(icon: AppVectors.bookmark, size: 20),
          'Избранное': const CategoryIconData(icon: AppVectors.favorite),
          'Недавно удаленное': const CategoryIconData(icon: AppVectors.delete),
        };

      case FolderDialogType.tasks:
        return {
          'Все задачи': const CategoryIconData(icon: AppVectors.note),
          'Без категории': const CategoryIconData(icon: AppVectors.bookmark, size: 20),
          'Недавно удаленное': const CategoryIconData(icon: AppVectors.delete),
        };
    }
  }

  int _getCount(String category) {
    if (widget.type == FolderDialogType.notes) {
      final notes = context.watch<NoteViewModel>().allNotes;

      switch (category) {
        case 'Все заметки':
          return notes.length;
        case 'Избранное':
          return notes.where((n) => n.isFavorite).length;
        case 'Без категории':
          return notes.where((n) => n.category == null || n.category!.isEmpty).length;
        case 'Недавно удаленное':
          return notes.where((n) => n.isDeleted).length;
      }
    } else {
      final tasks = context.watch<TaskViewModel>().allTasks;

      switch (category) {
        case 'Все задачи':
          return tasks.length;
        case 'Без категории':
          return tasks.where((t) => t.category == null || t.category!.isEmpty).length;
        case 'Недавно удаленное':
          return tasks.where((t) => t.isDeleted).length;
      }
    }

    return 0;
  }

  String _getMyItemsTitle() {
    switch (widget.type) {
      case FolderDialogType.notes:
        return 'Мои заметки';
      case FolderDialogType.tasks:
        return 'Мои задачи';
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = box.read('${_prefix}_selectedCategory');
    isMyNotesExpanded = box.read('${_prefix}_expanded') ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      folderVM.loadData();
    });
  }

  void _onCategorySelected(String category, Color color) {
    if (category ==  _getMyItemsTitle()) {
      final newValue = !isMyNotesExpanded;

      setState(() {
        isMyNotesExpanded = newValue;
      });

      box.write('${_prefix}_expanded', newValue);

      return;
    }
    setState(() {
      selectedCategory = category;
    });

    box.write('${_prefix}_selectedCategory', category);
    Navigator.pop(context, {'text': category, 'color': color});
  }

  int getAllCount(List notes) => notes.length;
  int getFavoriteCount(List notes) => notes.where((n) => n.isFavorite == true).length;
  int getNoCategoryCount(List notes) => notes.where((n) => n.category == null || n.category.isEmpty).length;
  int getDeletedCount(List notes) => notes.where((n) => n.isDeleted == true).length;
  int getCountByCategory(List<NoteModel> notes, String category) {
    return notes.where((note) => note.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();
    final notes = viewModel.allNotes;
    final travelCount = getCountByCategory(notes, 'Путешествия');
    final personalCount = getCountByCategory(notes, 'Личное');
    final everydayCount = getCountByCategory(notes, 'Повседневное');
    final workCount = getCountByCategory(notes, 'Работа');

    return Dialog(
      insetPadding: const EdgeInsets.only(top: 120, left: 0, right: 0, bottom: 0),
      alignment: Alignment.topCenter,
      backgroundColor: widget.backgroundColor,
      child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75, maxWidth: MediaQuery.of(context).size.width),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogContainer(
                      context,
                      children: [
                        ...categoryIcons.entries.map((entry) {
                          final data = entry.value;

                          return Column(
                            children: [
                              _buildDialogItemNoCategory(entry.key, context.isDarkMode ? AppColors.black : AppColors.white, iconPath: data.icon, iconSize: data.size, count: _getCount(entry.key), onTap: () => _onCategorySelected(entry.key, context.isDarkMode ? AppColors.black : AppColors.white)),
                              if (entry.key != categoryIcons.keys.last)
                                CustomDivider(),
                            ],
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Папки', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                          Builder(
                            builder: (context) {
                              return InkWell(
                                key: _manageKey,
                                borderRadius: BorderRadius.circular(8),
                                splashColor: AppColors.blueAccent.withAlpha(60),
                                highlightColor: AppColors.blueAccent.withAlpha(60),
                                onTap: () async {
                                  final RenderBox box = _manageKey.currentContext!.findRenderObject() as RenderBox;
                                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                  final Offset position = box.localToGlobal(Offset.zero);
                                  final RelativeRect positionRect = RelativeRect.fromRect(Rect.fromLTWH(position.dx + 5, position.dy + box.size.height, box.size.width, 0), Offset.zero & overlay.size);

                                  final result = await AppPopupMenu.show<int>(
                                    context: context,
                                    position: positionRect,
                                    maxWidth: 180,
                                    items: [
                                      PopupMenuItems.item(value: 1, text: 'Новая папка', context: context),
                                      PopupMenuItems.divider(),
                                      PopupMenuItems.item(value: 2, text: 'Изменить', context: context),
                                    ],
                                  );

                                  switch (result) {
                                    case 1:
                                      showFolderBottomSheetDialog(
                                        context,
                                        title: 'Новая папка',
                                        hintText: 'Имя',
                                        onCreate: (title) async {
                                          log("ON CREATE: $title");
                                          final folder = FolderModel(title: title.trim(), icon: '');
                                          await folderVM.createFolder(folder);
                                          log("ON CREATE: $title");
                                        },
                                      );
                                      break;
                                    case 2:
                                      Navigator.of(context).push(createPageRoute(ChangeFolderScreen()));
                                      break;
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text('Управление', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.blueAccent)),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDialogContainer(
                      context,
                      children: [
                        _buildDialogItemNoCategory(
                          _getMyItemsTitle(),
                          AppColors.darkGrey,
                          iconPath: AppVectors.folder,
                          showArrow: true,
                          isExpanded: isMyNotesExpanded,
                          onTap: () {
                            setState(() {
                              isMyNotesExpanded = !isMyNotesExpanded;
                              box.write('${_prefix}_expanded', isMyNotesExpanded);
                            });
                          },
                        ),
                        if (isMyNotesExpanded) ...[
                          CustomDivider(),
                          _buildDialogItem('Путешествия', AppColors.secondary, AppColors.secondary, count: travelCount),
                          CustomDivider(left: 42),
                          _buildDialogItem('Личное', AppColors.lightBlue, AppColors.lightBlue, count: personalCount),
                          CustomDivider(left: 42),
                          _buildDialogItem('Повседневное', AppColors.lightGreen, AppColors.lightGreen, count: everydayCount),
                          CustomDivider(left: 42),
                          _buildDialogItem('Работа', AppColors.red, AppColors.red, count: workCount),
                          CustomDivider(left: 42),
                          _buildDialogCreateCategory('Создать', null),
                        ],
                      ],
                    ),
                    SizedBox(height: 12),
                    Obx(() {
                      return Column(
                        children: [
                          ...folderVM.folders.map((folder) {
                            final categories = folderVM.grouped[folder.id] ?? [];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildDialogContainer(
                                context,
                                children: [
                                  _buildDialogItemNoCategory(folder.title, AppColors.darkGrey, iconPath: AppVectors.folder, showArrow: true, isExpanded: folderVM.isExpanded(folder.id), onTap: () => folderVM.toggleFolder(folder.id)),
                                  if (folderVM.isExpanded(folder.id))
                                    CustomDivider(),
                                  if (folderVM.isExpanded(folder.id)) ...[
                                    ...categories.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final cat = entry.value;
                                      final count = context.watch<NoteViewModel>().allNotes.where((n) => n.category == cat.title).length;

                                      return Column(
                                        children: [
                                          _buildDialogItem(cat.title, cat.color, cat.stripeColor, count: count, onTap: () => _onCategorySelected(cat.title, cat.color)),

                                          if (index != categories.length - 1)
                                            CustomDivider(left: 42),
                                        ],
                                      );
                                    }),
                                  ],
                                  if (folderVM.isExpanded(folder.id))
                                    CustomDivider(left: 42),
                                  if (folderVM.isExpanded(folder.id))
                                    _buildDialogCreateCategory('Создать', folder),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContainer(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildDialogItem(String text, Color containerColor, Color stripeColor, {int? count, VoidCallback? onTap}) {
    final isSelected = selectedCategory == text;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: onTap ?? () => _onCategorySelected(text, containerColor),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: isSelected ? containerColor.withAlpha((0.2 * 255).toInt()) : AppColors.transparent, borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius)),
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 10, top: 16, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 24,
                  decoration: BoxDecoration(color: containerColor.withAlpha((0.15 * 255).toInt()), borderRadius: BorderRadius.circular(6)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(color: stripeColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: isSelected ? containerColor : context.isDarkMode ? AppColors.white : AppColors.black)),
                ),
                if (count != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('$count', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogItemNoCategory(String text, Color containerColor, {String? iconPath, double iconSize = 24, int? count, VoidCallback? onTap, bool showArrow = false, bool isExpanded = false}) {
    final isSelected = selectedCategory == text;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        onTap: onTap,
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueAccent.withAlpha((0.2 * 255).toInt()) : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                if (iconPath != null)
                  SvgPicture.asset(iconPath, width: iconSize, height: iconSize, colorFilter: ColorFilter.mode(isSelected ? AppColors.blueAccent : context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn))
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 19),
                Expanded(child: Text(text, style: TextStyle(color: isSelected ? AppColors.blueAccent : context.isDarkMode ? AppColors.white : AppColors.black, fontSize: AppSizes.fontSizeMd))),
                if (count != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('$count', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                  ),
                if (showArrow)
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: AppColors.darkGrey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogCreateCategory(String text, FolderModel? folder) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.blueAccent.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: () async {
          final CategoryModel? newCategory = await showNewNoteBottomSheetDialog(context);

          if (newCategory != null) {
            final categoryWithFolder = newCategory.copyWith(folderId: folder?.id);

            await categoryRepository.insertCategory(categoryWithFolder);
            await folderVM.loadData();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 58),
              Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: AppColors.blueAccent)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/utils/constants/app_vectors.dart';
import '../../../../core/enums/folder_dialog_type.dart';
import '../../../../core/states/app_state.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/extensions/color_extension.dart';
import '../../../task/models/task_view_model.dart';
import '../../../utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/popups/app_popup_menu.dart';
import '../../../../utils/popups/items/popup_menu_items.dart';
import '../../../task/widgets/popups/new_note_bottom_sheet_dialog.dart';
import '../../models/note_model.dart';
import '../../models/note_view_model.dart';

class CategoryIconData {
  final String icon;
  final double size;

  const CategoryIconData({required this.icon, this.size = 24});
}

class CustomFolderDialog extends StatefulWidget {
  final FolderDialogType type;

  const CustomFolderDialog({super.key, required this.type});

  @override
  CustomFolderDialogState createState() => CustomFolderDialogState();
}

class CustomFolderDialogState extends State<CustomFolderDialog> {
  final GlobalKey _manageKey = GlobalKey();
  final box = GetStorage();
  bool isMyNotesExpanded = false;
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
    final color = context.watch<AppState>().getColor('tasks');

    return Dialog(
      insetPadding: const EdgeInsets.only(top: 120, left: 0, right: 0, bottom: 0),
      alignment: Alignment.topCenter,
      backgroundColor: (color ?? AppColors.black).getBackgroundColor(),
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
                              _buildDialogItemNoCategory(entry.key, AppColors.darkGrey, iconPath: data.icon, iconSize: data.size, count: _getCount(entry.key)),
                              if (entry.key != categoryIcons.keys.last)
                                _buildDivider(context),
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
                                      PopupMenuItems.item(value: 1, text: 'Новая папка', onTap: () {}, context: context),
                                      PopupMenuItems.divider(),
                                      PopupMenuItems.item(value: 2, text: 'Изменить', onTap: () {}, context: context),
                                    ],
                                  );

                                  if (result == 1) {

                                  } else if (result == 2) {

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
                        _buildDialogItemNoCategory(_getMyItemsTitle(), AppColors.darkGrey, iconPath: AppVectors.folder),
                        if (isMyNotesExpanded) ...[
                          _buildDivider(context),
                          _buildDialogItem('Путешествия', AppColors.secondary, AppColors.secondary, count: travelCount),
                          _buildDivider(context),
                          _buildDialogItem('Личное', AppColors.lightBlue, AppColors.lightBlue, count: personalCount),
                          _buildDivider(context),
                          _buildDialogItem('Повседневное', AppColors.lightGreen, AppColors.lightGreen, count: everydayCount),
                          _buildDivider(context),
                          _buildDialogItem('Работа', AppColors.red, AppColors.red, count: workCount),
                          _buildDivider(context),
                          _buildDialogCreateCategory('Создать'),
                        ],
                      ],
                    ),
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

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 20),
      child: Divider(height: 0, thickness: 1, color: context.isDarkMode ? AppColors.darkSlate : AppColors.buttonDisabled),
    );
  }

  Widget _buildDialogItem(String text, Color containerColor, Color stripeColor, {int? count}) {
    final isSelected = selectedCategory == text;

    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
          onTap: () => _onCategorySelected(text, containerColor),
          splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: isSelected ? containerColor.withAlpha((0.2 * 255).toInt()) : AppColors.transparent, borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius)),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 10, top: 16, bottom: 16),
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
      ),
    );
  }

  Widget _buildDialogItemNoCategory(String text, Color containerColor, {String? iconPath, double iconSize = 24, int? count}) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        onTap: () => _onCategorySelected(text, containerColor),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        child: Container(
          decoration: BoxDecoration(color: AppColors.transparent, borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                if (iconPath != null)
                  SvgPicture.asset(iconPath, width: iconSize, height: iconSize, colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn))
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 19),
                Expanded(child: Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd))),
                if (count != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('$count', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                  ),
                if (text == _getMyItemsTitle())
                  AnimatedRotation(
                    turns: isMyNotesExpanded ? 0.5 : 0.0,
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

  Widget _buildDialogCreateCategory(String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      highlightColor: AppColors.blueAccent.withAlpha((0.4 * 255).toInt()),
      hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
      onTap: () {
        showNewNoteBottomSheetDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
        child: Row(
          children: [
            const SizedBox(width: 58),
            Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: AppColors.blueAccent)),
          ],
        ),
      ),
    );
  }
}

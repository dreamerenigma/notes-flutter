import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/folder_repository.dart';
import '../../settings/widgets/app_bars/custom_app_bar.dart';
import '../../task/data/default_categories.dart';
import '../../note/widgets/popups/new_note_bottom_sheet_dialog.dart';
import '../../note/models/category_model.dart';
import '../../utils/widgets/dividers/custom_divider.dart';
import '../models/folder_model.dart';
import '../models/folder_view_model.dart';
import '../widgets/popups/delete_folder_dialog.dart';
import '../widgets/popups/edit_note_bottom_sheet_dialog.dart';
import '../widgets/popups/folder_bottom_sheet_dialog.dart';

class ChangeFolderScreen extends StatefulWidget {
  const ChangeFolderScreen({super.key});

  @override
  State<ChangeFolderScreen> createState() => _ChangeFolderScreenState();
}

class _ChangeFolderScreenState extends State<ChangeFolderScreen> {
  final FolderRepository folderRepository = Get.find<FolderRepository>();
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();
  final random = Random();
  final folderVM = Get.find<FolderViewModel>();
  List<CategoryModel> categories = List.from(defaultCategories);
  RxList<FolderModel> folders = <FolderModel>[].obs;
  Map<int?, List<CategoryModel>> folderCategories = {};
  bool isReorderMode = false;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    categories = List.from(defaultCategories);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      folderVM.loadData();
    });
  }

  Future<void> editFolder(FolderModel folder, BuildContext context) async {
    final FolderViewModel viewModel = Get.find<FolderViewModel>();

    final updatedTitle = await showFolderBottomSheetDialog(
      context,
      title: 'Изменить папку',
      hintText: 'Имя категории',
      initialText: folder.title,
      actionIcon: SvgPicture.asset(AppVectors.delete, width: 25, height: 25, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
      onActionTap: () async {
        final shouldDelete = await showDeleteFolderDialog(context);

        if (shouldDelete != true || folder.id == null) return;

        await viewModel.deleteFolder(folder.id!);

        setState(() {
          folders.removeWhere((f) => f.id == folder.id);
          folderCategories.remove(folder.id);
        });

        Navigator.pop(context);
      },
    );

    if (updatedTitle == null || folder.id == null) return;

    final updatedFolder = folder.copyWith(title: updatedTitle, updatedAt: DateTime.now());

    await folderRepository.updateFolder(updatedFolder);

    final index = folderVM.folders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      folderVM.folders[index] = updatedFolder;
      folderVM.folders.refresh();
    }
  }

  Future<void> editCategory(FolderModel folder, BuildContext context) async {

  }

  void onCategorySelected(String text, Color color) {
    setState(() {
      selectedCategory = text;
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;

      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      appBar: CustomAppBar(
        title: 'Изменить',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                borderRadius: BorderRadius.circular(8),
                splashColor: context.isDarkMode ? AppColors.youngNight : AppColors.softGrey,
                highlightColor: context.isDarkMode ? AppColors.youngNight : AppColors.softGrey,
                onTap: () async {
                  final title = await showFolderBottomSheetDialog(context, title: 'Новая папка', hintText: 'Имя');

                  if (title == null) return;
                  if (title.trim().isEmpty) {
                    return;
                  }

                  final folder = FolderModel(title: title.trim(), icon: '');

                  await folderVM.createFolder(folder);
                },
                child: Center(
                  child: SvgPicture.asset(AppVectors.addFolder, width: 26, height: 26, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildFolderWidget(context, FolderModel(title: 'Мои задачи', icon: '', id: null, position: null, createdAt: null, updatedAt: null), categories),
            Obx(() {
              final folders = folderVM.folders;

              return Column(
                children: [
                  ...folders.map((folder) {
                    final cats = folderVM.grouped[folder.id] ?? [];

                    return _buildFolderWidget(context, folder, cats);
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderWidget(BuildContext context, FolderModel folder, List<CategoryModel> categories) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: context.isDarkMode ? AppColors.blackGrey : AppColors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          _buildFolderHeader(folder),
          CustomDivider(indent: 48),
          SingleChildScrollView(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: ReorderableListView(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                onReorderItem: onReorder,
                children: [
                  for (int i = 0; i < categories.length; i++)
                    _buildCustomSectionItem(categories[i], i),
                ],
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: AppColors.transparent,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: 1.03,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.isDarkMode ? AppColors.youngNight : AppColors.softGrey,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8), color: AppColors.black.withAlpha((0.5 * 255).toInt())),
                              ],
                            ),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: _buildDialogCreateCategory('Создать', folder)),
        ],
      ),
    );
  }

  Widget _buildFolderHeader(FolderModel folder) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 6),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
          splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
          onTap: () async {
            await editFolder(folder, context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                SvgPicture.asset(AppVectors.folder, width: 25, height: 25, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
                const SizedBox(width: 14),
                Expanded(child: Text(folder.title, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSectionItem(CategoryModel item, int index) {
    return Column(
      key: ValueKey(item.id),
      children: [
        _buildCustomSection(context, item.title, item.color, item.color, index: index),

        if (index != categories.length + 1)
          CustomDivider(indent: 82, endIndent: 2),
      ],
    );
  }

  Widget _buildCustomSection(BuildContext context, String text, Color containerColor, Color stripeColor, {required int index, int? count, VoidCallback? onIconTap}) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
        splashColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        highlightColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        hoverColor: AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()),
        onTap: () {
          showEditNoteBottomSheetDialog(context, initialText: text);
        },
        onLongPress: () {
          setState(() {
            isReorderMode = true;
          });
        },
        child: ReorderableDelayedDragStartListener(
          index: index,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.transparent, borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius)),
            child: Padding(
              padding: const EdgeInsets.only(left: 55, right: 10, top: 12, bottom: 12),
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
                    child: Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, color: context.isDarkMode ? AppColors.white : AppColors.black)),
                  ),
                  if (count != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('$count', style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                    ),
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onIconTap,
                      child: Padding(padding: const EdgeInsets.all(6), child: SvgPicture.asset(AppVectors.dragAndDrop, width: 25, height: 25, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogCreateCategory(String text, FolderModel folder) {
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
            final categoryWithFolder = newCategory.copyWith(folderId: folder.id);

            await categoryRepository.insertCategory(categoryWithFolder);
            await folderVM.loadData();
          }
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
      ),
    );
  }
}

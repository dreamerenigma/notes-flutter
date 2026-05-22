import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:notes/features/note/widgets/popups/show_sorting_note_dialog.dart';
import '../../../../routes/custom_page_route.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../settings/screens/settings_screen.dart';
import 'actions/popup_menu_action.dart';
import 'items/app_popup_menu_item.dart';

class NotePopupMenu extends StatefulWidget {
  final ValueChanged<bool> onGridViewChanged;
  final bool isFolderDialogOpen;

  const NotePopupMenu({super.key, required this.onGridViewChanged, required this.isFolderDialogOpen});

  @override
  NotePopupMenuState createState() => NotePopupMenuState();
}

class NotePopupMenuState extends State<NotePopupMenu> {
  final GetStorage storage = GetStorage();
  String gridText = 'Список';
  bool showSelectBottomNavBar = false;

  List<PopupMenuAction> get actions => [
    PopupMenuAction(value: 1, title: gridText, action: _toggleGrid),
    PopupMenuAction(value: 2, title: 'Удалить элементы', action: _toggleDeleteMode),
    PopupMenuAction(value: 3, title: 'Сортировка', action: _toggleSorting),
    PopupMenuAction(value: 4, title: 'Настройки', action: _openSettings),
  ];

  void _toggleGrid() {
    final current = storage.read('isGrid') ?? false;
    final newValue = !current;

    storage.write('isGrid', newValue);

    setState(() {
      gridText = newValue ? 'Сетка' : 'Список';
    });

    widget.onGridViewChanged(newValue);
  }

  void _toggleDeleteMode() {
    setState(() {
      showSelectBottomNavBar = !showSelectBottomNavBar;
    });
  }

  void _toggleSorting() {
    showSortingNoteDialog(context);
  }

  void _openSettings() {
    Navigator.push(context, createPageRoute(const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFolderDialogOpen) {
      return const SizedBox.shrink();
    }

    final isGrid = gridText == 'Сетка';
    final nextText = isGrid ? 'Список' : 'Сетка';

    return Column(
      children: [
        TooltipTheme(
          data: TooltipThemeData(decoration: BoxDecoration(color: context.isDarkMode ? AppColors.black : AppColors.white, borderRadius: BorderRadius.circular(8))),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: AppColors.darkerGrey, highlightColor: AppColors.darkerGrey, hoverColor: AppColors.darkerGrey),
            child: PopupMenuButton<int>(
              tooltip: 'Ещё',
              position: PopupMenuPosition.under,
              offset: const Offset(-12, 0),
              menuPadding: EdgeInsets.symmetric(vertical: 4),
              constraints: const BoxConstraints(minWidth: 0, maxWidth: 185),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.softNight;
                  }
                  return AppColors.transparent;
                }),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                overlayColor: WidgetStateProperty.all(AppColors.softNight.withAlpha((0.1 * 255).toInt())),
              ),
              color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
              icon: SvgPicture.asset(AppVectors.moreGrid, width: 22, height: 22, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  enabled: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: nextText,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        gridText = isGrid ? 'Список' : 'Сетка';
                        storage.write('gridText', gridText);
                        widget.onGridViewChanged(!isGrid);
                      });
                    },
                  ),
                ),
                const PopupMenuDivider(indent: 16, endIndent: 16, height: 0, color: AppColors.softNight),
                PopupMenuItem(
                  value: 2,
                  enabled: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: 'Удалить элементы',
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                        showSelectBottomNavBar = !showSelectBottomNavBar;
                      });
                    },
                  ),
                ),
                const PopupMenuDivider(indent: 16, endIndent: 16, height: 0, color: AppColors.softNight),
                PopupMenuItem(
                  value: 3,
                  enabled: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: 'Сортировка',
                    onTap: () {
                      Navigator.pop(context);
                      showSortingNoteDialog(context);
                    },
                  ),
                ),
                const PopupMenuDivider(indent: 16, endIndent: 16, height: 0, color: AppColors.softNight),
                PopupMenuItem(
                  value: 4,
                  enabled: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: 'Настройки',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, createPageRoute(const SettingsScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import '../../../../routes/custom_page_route.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../../note/widgets/popups/items/app_popup_menu_item.dart';
import '../../../settings/screens/settings_screen.dart';

class TasksPopupMenu extends StatefulWidget {
  final ValueChanged<bool> onShowCompletedChanged;
  final bool showCompleted;
  final bool isFolderDialogOpen;

  const TasksPopupMenu({super.key, required this.onShowCompletedChanged, required this.showCompleted, required this.isFolderDialogOpen});

  @override
  State<TasksPopupMenu> createState() => _TasksPopupMenuState();
}

class _TasksPopupMenuState extends State<TasksPopupMenu> {
  @override
  Widget build(BuildContext context) {
    if (widget.isFolderDialogOpen) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TooltipTheme(
          data: TooltipThemeData(decoration: BoxDecoration(color: context.isDarkMode ? AppColors.black : AppColors.white, borderRadius: BorderRadius.circular(8))),
          child: Theme(
            data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory, splashColor: AppColors.transparent, highlightColor: AppColors.transparent, hoverColor: AppColors.transparent),
            child: PopupMenuButton<int>(
              tooltip: 'Ещё',
              position: PopupMenuPosition.under,
              menuPadding: EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(minWidth: 0, maxWidth: widget.showCompleted ? 265 : 285),
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
              icon: SvgPicture.asset(
                AppVectors.moreGrid,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn),
              ),
              onSelected: (value) {
                if (value == 1) {
                  widget.onShowCompletedChanged(!widget.showCompleted);
                }
                else if (value == 2) {
                  Navigator.push(context, createPageRoute(const SettingsScreen()));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: widget.showCompleted ? 'Скрыть выполненные задачи' : 'Показать выполненные задачи',
                    onTap: () {
                      setState(() {
                        widget.onShowCompletedChanged(!widget.showCompleted);

                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
                const PopupMenuDivider(indent: 16, endIndent: 16, height: 0, color: AppColors.softNight),
                PopupMenuItem(
                  value: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text: 'Удалить элементы',
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
                const PopupMenuDivider(indent: 16, endIndent: 16, height: 0, color: AppColors.softNight),
                PopupMenuItem(
                  value: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppPopupMenuItem(
                    text:'Настройки',
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                        Navigator.push(context, createPageRoute(const SettingsScreen()));
                      });
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

import 'package:flutter/material.dart';
import '../../../../core/enums/repeat_type.dart';
import '../../../../core/extensions/repeat_type_extension.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../buttons/custom_radio_button.dart';

Future<RepeatType?> showRepeatBottomSheetDialog(BuildContext context, {required RepeatType currentValue}) async {
  return await showModalBottomSheet<RepeatType>(
    context: context,
    backgroundColor: AppColors.transparent,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (_) {
      return _RepeatDialogContent(currentValue: currentValue);
    },
  );
}

class _RepeatDialogContent extends StatefulWidget {
  final RepeatType currentValue;

  const _RepeatDialogContent({required this.currentValue});

  @override
  State<_RepeatDialogContent> createState() => _RepeatDialogContentState();
}

class _RepeatDialogContentState extends State<_RepeatDialogContent> {
  late int selectedIndex;
  late RepeatType selected;

  final List<RepeatType> items = [RepeatType.none, RepeatType.daily, RepeatType.weekly, RepeatType.monthly, RepeatType.yearly];

  @override
  void initState() {
    super.initState();
    selected = widget.currentValue;
    selectedIndex = items.indexOf(widget.currentValue);
    if (selectedIndex == -1) {
      selectedIndex = 0;
      selected = RepeatType.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.blackGrey, borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Повтор', style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(items.length, (index) {
              return Column(
                children: [
                  Material(
                    color: AppColors.transparent ,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        Navigator.pop(context, RepeatType.values[selectedIndex]);
                      },
                      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
                      splashColor: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey,
                      highlightColor: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey,
                      hoverColor: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Text(items[index].label, style: TextStyle(fontSize: AppSizes.fontSizeMd)),
                            ),
                          ),
                          CustomRadioButton(
                            value: index,
                            groupValue: selectedIndex,
                            onChanged: (value) {
                              setState(() {
                                selectedIndex = value!;
                              });

                              Navigator.pop(context, RepeatType.values[selectedIndex]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index != items.length - 1)
                    _buildDivider(context),
                ],
              );
            }),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, RepeatType.values[selectedIndex]);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.blueAccent,
                    overlayColor: AppColors.blueAccent.withAlpha((0.2 * 255).toInt()),
                    backgroundColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDivider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 25),
    child: Divider(
      height: 0,
      thickness: 1,
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSlate : AppColors.buttonDisabled,
    ),
  );
}

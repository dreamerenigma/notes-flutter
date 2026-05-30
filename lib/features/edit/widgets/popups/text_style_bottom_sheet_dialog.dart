import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_images.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../buttons/toolbar_icon_button.dart';
import '../sliders/custom_slider.dart';

Future<bool?> showTextStyleBottomSheetDialog(BuildContext context, Function(String) onBackgroundSelected) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
    backgroundColor: context.isDarkMode ? AppColors.blackGrey : AppColors.white,
    builder: (BuildContext context) {
      return FocusScope(node: FocusScopeNode(), child: SliderBottomSheetContent(onBackgroundSelected: onBackgroundSelected));
    },
  );
}

class SliderBottomSheetContent extends StatefulWidget {
  final Function(String) onBackgroundSelected;

  const SliderBottomSheetContent({super.key, required this.onBackgroundSelected});

  @override
  SliderBottomSheetContentState createState() => SliderBottomSheetContentState();
}

class SliderBottomSheetContentState extends State<SliderBottomSheetContent> {
  bool isBold = false;
  double sliderValue = 0.5;
  int selectedIndex = -1;
  int selectedColorIndex = 0;
  int selectedBgImageIndex = 0;
  final GetStorage storage = GetStorage();

  @override
  void initState() {
    super.initState();
    selectedColorIndex = storage.read('selectedColorIndex') ?? 0;
    sliderValue = storage.read('sliderValue') ?? 0.5;
    selectedBgImageIndex = storage.read('selectedBackgroundIndex') ?? 0;
    isBold = storage.read<bool>('isBold') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = context.isDarkMode
      ? [AppImages.noteBgDark, AppImages.noteBgDarkV1, AppImages.noteBgDarkV2, AppImages.noteBgDarkV3]
      : [AppImages.noteBgLight, AppImages.noteBgLightV1, AppImages.noteBgLightV2, AppImages.noteBgLightV3];

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: const EdgeInsets.only(left: 25, top: 5), child: Text('СТИЛЬ', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.bold))),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 5),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context, isBold);
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 20, top: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ToolbarIconButton(
                      icon: Icons.format_bold_outlined,
                      active: isBold,
                      onTap: () {
                        setState(() => isBold = !isBold);
                        storage.write('isBold', isBold);
                      },
                      size: 30,
                    ),
                    ToolbarIconButton(icon: TablerIcons.italic, size: 28, onTap: () {}),
                    ToolbarIconButton(icon: Icons.format_underline, size: 26, onTap: () {}),
                    ToolbarIconButton(icon: BootstrapIcons.text_left, size: 26, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.buttonDisabled, onTap: () {}),
                    ToolbarIconButton(icon: BootstrapIcons.text_center, size: 26, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.buttonDisabled, onTap: () {}),
                    ToolbarIconButton(icon: BootstrapIcons.text_right, size: 26, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.buttonDisabled, onTap: () {}),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 3, thickness: 1),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.format_indent_increase_outlined, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.buttonDisabled),
                    Icon(Icons.format_indent_decrease_outlined, color: context.isDarkMode ? AppColors.darkerGrey : AppColors.buttonDisabled),
                    const Icon(Icons.format_list_numbered_rounded),
                    const Icon(Icons.format_list_numbered_rounded),
                    const Icon(Icons.format_list_bulleted_rounded),
                    const Icon(Icons.format_list_bulleted_sharp),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 3, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(PhosphorIcons.text_aa, size: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomSlider(
                          value: sliderValue,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                            });
                            storage.write('sliderValue', sliderValue);
                          },
                        ),
                      ),
                    ),
                    const Icon(PhosphorIcons.text_aa, size: 25),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 3, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int index = 0; index < AppColors.categoryColors.length; index++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColorIndex = index;
                              storage.write('selectedColorIndex', selectedColorIndex);
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(margin: const EdgeInsets.symmetric(horizontal: 15), width: 40, height: 40, decoration: BoxDecoration(color: AppColors.categoryColors[index], shape: BoxShape.circle)),
                              if (selectedColorIndex == index)
                                Container(height: 11, width: 11, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 3, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBgImageIndex = index;
                          storage.write('selectedBackgroundIndex', selectedBgImageIndex);
                          widget.onBackgroundSelected(imagePaths[index]);
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index == 0 ? (context.isDarkMode ? AppColors.black : AppColors.white) : AppColors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedBgImageIndex == index ? Colors.blue : AppColors.grey, width: 2.0),
                        ),
                        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(imagePaths[index], fit: BoxFit.cover)),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

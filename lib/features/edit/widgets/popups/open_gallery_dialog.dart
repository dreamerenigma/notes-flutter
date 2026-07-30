import 'dart:developer';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:heroicons/heroicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/features/utils/widgets/dividers/custom_divider.dart';
import '../../../../routes/custom_page_route.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_sizes.dart';
import '../../../../utils/constants/app_vectors.dart';
import '../../screens/add_image_picker_screen.dart';
import '../../screens/simple_camera_screen.dart';

late List<CameraDescription> cameras;

Future<void> pickImageFromGallery(BuildContext context, void Function(XFile?) onImagePicked) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    log('Изображение выбрано: ${image.path}');
    onImagePicked(image);
    Navigator.pop(context);
  } else {
    log('Изображение не выбрано.');
  }
}

Future<void> pickImageFromCamera(BuildContext context, void Function(XFile?) onImagePicked) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  if (image != null) {
    log('Фото сделано: ${image.path}');
    onImagePicked(image);
    Navigator.pop(context);
  } else {
    log('Фото не сделано.');
  }
}

Future<void> initCameras() async {
  cameras = await availableCameras();
}

void showOpenGalleryDialog(BuildContext context, void Function(XFile?) onImagePicked) {
  log('[log] Открытие диалога для выбора изображения');
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black54,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: AppColors.transparent,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? AppColors.greySlate : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildOptionSend(context, onImagePicked),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 10)).copyWith(
                            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return AppColors.darkerGrey;
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return AppColors.darkerGrey;
                              }
                              return null;
                            }),
                          ),
                          child: Text('ОТМЕНА', style: TextStyle(fontSize: AppSizes.fontSizeLg, color: AppColors.blueAccent)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionSend(BuildContext context, void Function(XFile?) onImagePicked) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildOption(context, Icon(BootstrapIcons.camera, size: 24), 'Сделать фото', () {
        pickImageFromCamera(context, onImagePicked);
      }),
      CustomDivider(indent: 66, endIndent: 20, left: 0, right: 0),
      _buildOption(context, SvgPicture.asset(AppVectors.scanner, width: 24, height: 24, colorFilter: ColorFilter.mode(context.isDarkMode ? AppColors.white : AppColors.black, BlendMode.srcIn)), 'Сканировать документ', () async {
        final path = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SimpleCameraScreen()));

        if (path != null) {
          log('Фото документа: $path');
        }
      }),
      CustomDivider(indent: 66, endIndent: 20, left: 0, right: 0),
      _buildOption(context, HeroIcon(HeroIcons.creditCard, size: 24), 'Добавить карту', () {

      }),
      CustomDivider(indent: 66, endIndent: 20, left: 0, right: 0),
      _buildOption(
        context,
        Icon(Icons.photo_library_outlined, size: 24),
        'Выбрать из Галереи',
        () async {
          final selectedImagePath = await Navigator.push<String>(context, createPageRoute(const AddImagePickerScreen()));

          if (selectedImagePath != null) {
            log('Selected image path: $selectedImagePath');
            onImagePicked(XFile(selectedImagePath));

            Navigator.pop(context);
          }
        },
      ),
    ],
  );
}

Widget _buildOption(BuildContext context, Widget icon, String text, VoidCallback onTap,) {
  return Material(
    color: AppColors.transparent,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(8),
        splashColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.softGrey,
        highlightColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.softGrey,
        hoverColor: context.isDarkMode ? AppColors.darkerGrey.withAlpha((0.4 * 255).toInt()) : AppColors.softGrey,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 20),
              Text(text, style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    ),
  );
}

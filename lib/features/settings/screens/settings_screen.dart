import 'dart:developer';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../widgets/popups/add_watermark_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();
  String watermarkText = 'Из Заметок Honor';

  @override
  void initState() {
    super.initState();
    watermarkText = storage.read('watermarkText') ?? 'Из Заметок Honor';
  }

  void onSave(String newText) {
    setState(() {
      watermarkText = newText;
    });
    storage.write('watermarkText', newText);
    log("Save button clicked with text: $newText");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Настройки', style: TextStyle(fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400)),
        backgroundColor: AppColors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.greySlate : AppColors.softGrey,
          borderRadius: BorderRadius.circular(18),
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: AppColors.darkerGrey,
                  highlightColor: AppColors.darkerGrey,
                  onTap: () {
                    showAddWatermarkDialog(context, onSave, watermarkText);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Водяной знак', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
                        Row(
                          children: [
                            Text(watermarkText, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.darkGrey)),
                            const Icon(Icons.keyboard_arrow_right, size: 24, color: AppColors.darkGrey),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 0, thickness: 0),
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: AppColors.darkerGrey,
                  highlightColor: AppColors.darkerGrey,
                  onTap: () async {
                    log('Clicked option');

                    Future<int> getAndroidSdk() async {
                      final deviceInfo = DeviceInfoPlugin();
                      final androidInfo = await deviceInfo.androidInfo;
                      return androidInfo.version.sdkInt;
                    }

                    Future<void> openNotificationSettings(int sdk) async {
                      AndroidIntent intent;

                      if (sdk >= 26) {
                        intent = AndroidIntent(
                          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                          arguments: {'android.provider.extra.APP_PACKAGE': 'com.inputstudios.notes'},
                        );
                      } else {
                        intent = AndroidIntent(
                          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                          arguments: {'app_package': 'com.inputstudios.notes', 'app_uid': 0},
                        );
                      }

                      await intent.launch();
                    }

                    try {
                      final sdk = await getAndroidSdk();
                      await openNotificationSettings(sdk);
                    } catch (e) {
                      log('Error opening notification settings: $e');

                      await AndroidIntent(
                        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                        arguments: {'android.provider.extra.APP_PACKAGE': 'com.inputstudios.notes', 'app_package': 'com.inputstudios.notes'},
                      ).launch();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Уведомления', style: TextStyle(fontSize: AppSizes.fontSizeMd, fontWeight: FontWeight.w400)),
                        const Icon(Icons.keyboard_arrow_right, size: 24, color: AppColors.darkGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

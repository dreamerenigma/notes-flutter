import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../widgets/app_bars/custom_app_bar.dart';

class FontSizeScreen extends StatefulWidget {
  const FontSizeScreen({super.key});

  @override
  State<FontSizeScreen> createState() => _FontSizeScreenState();
}

class _FontSizeScreenState extends State<FontSizeScreen> {
  double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      appBar: CustomAppBar(title: 'Размер шрифта'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Заголовок 1', style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: fontSize + 8, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Text('Заголовок 2', style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: fontSize + 4, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 20),
                      Text('Заметки - отличное приложение для заметок на Android. Оно предлагает два режима записи заметок: текстовый и режим чеклиста, чьтоюбы полностью удовлетворить ваши потредности. Функции, такие как виджеты липких заметок, напоминания о заметках и блокировка заметок, делают процесс ведения заметок простым, быстрым и безопасным. Заметки сохраняются автоматически по мере ввода текста, так что вы можете вести записи, как если бы пользовались ручкой или бумагой.', style: TextStyle(color: context.isDarkMode ? AppColors.white : AppColors.black, fontSize: fontSize + 2, fontWeight: FontWeight.w400, height: 1.25)),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: context.isDarkMode ? AppColors.greySlate : AppColors.softGrey, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Text('A', style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w500)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.grey.withAlpha((0.3 * 255).toInt()),
                        inactiveTrackColor: AppColors.grey.withAlpha((0.3 * 255).toInt()),
                        thumbColor: AppColors.blueAccent,
                        overlayColor: AppColors.transparent,
                        trackHeight: 4,
                        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                        activeTickMarkColor: AppColors.darkGrey,
                        inactiveTickMarkColor: AppColors.darkGrey,
                      ),
                      child: Slider(
                        value: fontSize,
                        min: 14,
                        max: 22,
                        divisions: 2,
                        onChanged: (value) {
                          setState(() {
                            fontSize = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Text('A', style: TextStyle(fontSize: AppSizes.fontSizeGl, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
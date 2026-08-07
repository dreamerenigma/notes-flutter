import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import '../../../core/enums/password_step_type.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';
import '../widgets/app_bars/custom_app_bar.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  PasswordStepType step = PasswordStepType.create;
  List<int>? firstPattern;
  String? errorText;

  String get titleText {
    switch (step) {
      case PasswordStepType.create:
        return 'Нарисовать фигуру для разблокировки';
      case PasswordStepType.confirm:
        return 'Подтвердите фигуру для подтверждения';
    }
  }

  String get subtitleText {
    return 'Соедините не менее 4 точек';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Задать пароль'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            child: Column(
              children: [
                Text(titleText, style: TextStyle(fontSize: AppSizes.fontSizeBg, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(subtitleText, style: TextStyle(fontSize: AppSizes.fontSizeSm, color: AppColors.grey, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: PatternLock(
                selectedColor: AppColors.blueAccent,
                notSelectedColor: AppColors.blueAccent,
                pointRadius: 12,
                fillPoints: true,
                onInputComplete: (input) {
                  if (input.length < 4) {
                    setState(() {
                      errorText = 'Соедините не менее 4 точек';
                    });
                    return;
                  }

                  if (step == PasswordStepType.create) {
                    setState(() {
                      firstPattern = List.from(input);
                      step = PasswordStepType.confirm;
                    });
                  } else {
                    if (listEquals(firstPattern, input)) {
                      Navigator.pop(context, input);
                    } else {
                      setState(() {
                        errorText = 'Графические ключи не совпадают';
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

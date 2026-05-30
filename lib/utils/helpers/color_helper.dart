import 'dart:math';
import 'package:flutter/cupertino.dart';

final Random random = Random();

Color generateRandomColor() {
  return HSLColor.fromAHSL(1, random.nextDouble() * 360, 0.7, 0.55).toColor();
}

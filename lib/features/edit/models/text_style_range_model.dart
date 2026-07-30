import 'package:flutter/material.dart';

class TextStyleRangeModel {
  final int start;
  final int end;

  final Color? color;
  final bool? bold;
  final bool? italic;
  final bool? underline;

  TextStyleRangeModel({
    required this.start,
    required this.end,
    this.color,
    this.bold,
    this.italic,
    this.underline,
  });
}

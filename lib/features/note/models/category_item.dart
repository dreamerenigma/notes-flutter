import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final Color color;
  final String? svgAsset;
  final int value;

  const CategoryItem({
    required this.title,
    required this.color,
    required this.value,
    this.svgAsset,
  });
}

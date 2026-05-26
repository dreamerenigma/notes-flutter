import 'package:flutter/material.dart';

class CategoryItem {
  final int id;
  final String title;
  final Color color;
  final Color stripeColor;
  final String? svgAsset;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.color,
    required this.stripeColor,
    this.svgAsset,
  });
}

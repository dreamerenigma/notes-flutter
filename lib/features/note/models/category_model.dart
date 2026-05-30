import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final int? folderId;
  final String title;
  final Color color;
  final Color stripeColor;
  final int position;
  final String? svgAsset;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    this.id,
    this.folderId,
    required this.title,
    required this.color,
    required this.stripeColor,
    this.svgAsset,
    this.position = 0,
    this.createdAt,
    this.updatedAt,
  });

  CategoryModel copyWith({
    int? id,
    int? folderId,
    String? title,
    Color? color,
    Color? stripeColor,
    int? position,
    String? svgAsset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      color: color ?? this.color,
      stripeColor: stripeColor ?? this.stripeColor,
      position: position ?? this.position,
      svgAsset: svgAsset ?? this.svgAsset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_id': folderId,
      'title': title,
      'color': color.toARGB32(),
      'stripe_color': stripeColor.toARGB32(),
      'position': position,
      'svg_asset': svgAsset,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      folderId: map['folder_id'],
      title: map['title'] ?? '',
      color: Color(map['color']),
      stripeColor: Color(map['stripe_color']),
      position: map['position'] ?? 0,
      svgAsset: map['svg_asset'],
      createdAt: map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) : null,
    );
  }

  factory CategoryModel.empty() {
    return CategoryModel(
      id: null,
      folderId: null,
      title: '',
      color: Colors.grey,
      stripeColor: Colors.grey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

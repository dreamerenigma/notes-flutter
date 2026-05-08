import 'package:flutter/material.dart';

class PopupMenuAction {
  final int value;
  final String title;
  final VoidCallback action;

  const PopupMenuAction({
    required this.value,
    required this.title,
    required this.action,
  });
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../utils/constants/app_colors.dart';

class CustomAssetEntityImage extends StatelessWidget {
  final AssetEntity entity;
  final BoxFit fit;
  final double width;
  final double height;

  const CustomAssetEntityImage(this.entity, {
    super.key,
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: entity.thumbnailDataWithSize(const ThumbnailSize(250, 250)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: fit, width: width, height: height);
        }
        return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueAccent)));
      },
    );
  }
}

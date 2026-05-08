import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';

class FullScreenImageScreen extends StatefulWidget {
  final AssetEntity image;
  final bool isSelected;

  const FullScreenImageScreen({
    super.key,
    required this.image,
    required this.isSelected,
  });

  @override
  FullScreenImageScreenState createState() => FullScreenImageScreenState();
}

class FullScreenImageScreenState extends State<FullScreenImageScreen> {
  double _scale = 1.0;
  final double _minScale = 1.0;
  final double _maxScale = 2.0;
  bool _isZoomed = false;
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  void _toggleZoom() {
    setState(() {
      _isZoomed = !_isZoomed;
      _scale = _isZoomed ? _maxScale : _minScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: _minScale,
            maxScale: _maxScale,
            child: FutureBuilder<Uint8List?>(
              future: widget.image.thumbnailDataWithSize(const ThumbnailSize(500, 500)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Center(
                    child: GestureDetector(
                      onDoubleTap: _toggleZoom,
                      child: Transform.scale(scale: _scale, child: Image.memory(snapshot.data!, fit: BoxFit.contain)),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueAccent),
                ));
              },
            ),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.transparent,
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Все фото', style: TextStyle(color: AppColors.white, fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400)),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: isSelected ? AppColors.blueAccent : AppColors.transparent, borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        isSelected ? Icons.check : Icons.check_box_outline_blank_rounded,
                        color: isSelected ? AppColors.white : AppColors.darkerGrey,
                        size: isSelected ? 20 : 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

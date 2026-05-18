import 'dart:typed_data';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:notes/routes/custom_page_route.dart';
import 'package:notes/features/utils/widgets/scrolls/no_glow_scroll_behavior.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/images/asset_entity_images.dart';
import 'full_screen_image_screen.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_sizes.dart';

class AddImagePickerScreen extends StatefulWidget {
  const AddImagePickerScreen({super.key});

  @override
  AddImagePickerScreenState createState() => AddImagePickerScreenState();
}

class AddImagePickerScreenState extends State<AddImagePickerScreen> {
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _images = [];
  List<AssetEntity> orderedSelectedImages = [];
  Set<AssetEntity> selectedImages = {};
  AssetEntity? previewImage;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (permitted.isAuth) {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      setState(() {
        _albums = albums;
        if (_albums.isNotEmpty) {
          fetchImages(_albums.first);
        }
      });
    }
  }

  Future<void> fetchImages(AssetPathEntity album) async {
    final images = await album.getAssetListPaged(page: 0, size: 100);
    setState(() {
      _images = images;
    });
  }

  void _toggleSelection(AssetEntity image) {
    setState(() {
      if (orderedSelectedImages.contains(image)) {
        orderedSelectedImages.remove(image);
      } else {
        orderedSelectedImages.add(image);
      }
      selectedImages = orderedSelectedImages.toSet();
      previewImage = selectedImages.isNotEmpty ? selectedImages.first : null;
    });
  }

  Future<Uint8List?> _getThumbnailData(AssetEntity image) async {
    return await image.thumbnailDataWithSize(const ThumbnailSize(100, 100));
  }

  void setImagePath(String path) {
    setState(() {
      imagePath = path;
    });
  }

  void _onDone() async {
    if (selectedImages.isNotEmpty) {
      final firstImage = selectedImages.first;
      final file = await firstImage.file;

      if (file != null) {
        Navigator.of(context).pop(file.path);
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 30),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Все фото', style: TextStyle(fontSize: AppSizes.fontSizeXl, fontWeight: FontWeight.w400)),
            const Padding(padding: EdgeInsets.only(right: 8), child: Icon(PhosphorIcons.copy_simple)),
          ],
        ),
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return GestureDetector(
                    onTap: () => _toggleSelection(image),
                    onLongPress: () => _toggleSelection(image),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AssetEntityImage(image, fit: BoxFit.cover, width: 100, height: 100),
                        ),
                        if (orderedSelectedImages.contains(image))
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(color: AppColors.white.withAlpha((0.4 * 255).toInt()), borderRadius: BorderRadius.circular(8)),
                          ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(createPageRoute(FullScreenImageScreen(image: image, isSelected: orderedSelectedImages.contains(image))));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(color: AppColors.black.withAlpha((0.2 * 255).toInt()), borderRadius: BorderRadius.circular(6)),
                              child: const Icon(FluentIcons.full_screen_maximize_16_regular, size: 18, color: AppColors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: orderedSelectedImages.contains(image) ? AppColors.blueAccent : AppColors.white.withAlpha((0.3 * 255).toInt()),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: orderedSelectedImages.contains(image) ? AppColors.transparent : AppColors.white, width: 1),
                            ),
                            child: orderedSelectedImages.contains(image) ? Center(
                              child: Text('${orderedSelectedImages.indexOf(image) + 1}', style: TextStyle(color: Colors.white, fontSize: AppSizes.fontSizeMd)),
                            ) : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      height: 160,
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.black : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 12, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${selectedImages.length}/50', style: TextStyle(fontSize: AppSizes.fontSizeLg)),
                TextButton(
                  onPressed: selectedImages.isEmpty ? null : _onDone,
                  child: Text('ГОТОВО', style: TextStyle(color: selectedImages.isEmpty ? AppColors.blueAccent.withAlpha((0.4 * 255).toInt()) : AppColors.blueAccent, fontSize: AppSizes.fontSizeSm)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 12, bottom: 25),
            child: selectedImages.isNotEmpty
                ? SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  final image = selectedImages.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: _getThumbnailData(image),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(snapshot.data!, width: 70, height: 70, fit: BoxFit.cover),
                              );
                            }
                            return const Center(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueAccent),
                            ));
                          },
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _toggleSelection(image);
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(color: AppColors.black.withAlpha((0.2 * 255).toInt()), shape: BoxShape.circle),
                              child: const Center(child: Icon(Icons.close, size: 16, color: AppColors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
                : const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text('Выберите элементы которые нужно добавить.', style: TextStyle(color: AppColors.darkGrey)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

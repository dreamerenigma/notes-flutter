import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/app_colors.dart';
import '../widgets/popups/open_gallery_dialog.dart';

class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  late CameraController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    await controller.initialize();
    setState(() {
      isReady = true;
    });
  }

  Future<void> takePhoto() async {
    final file = await controller.takePicture();

    if (!mounted) return;
    Navigator.pop(context, file.path);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          CameraPreview(controller),
          Center(
            child: Container(
              width: 300,
              height: 420,
              decoration: BoxDecoration(border: Border.all(color: AppColors.white, width: 2), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: takePhoto,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                  child: const Icon(Icons.camera_alt, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
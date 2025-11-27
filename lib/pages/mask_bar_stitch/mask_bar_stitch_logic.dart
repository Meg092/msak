import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';
import 'package:mask_bar/components/mask_bar_save_dialog.dart';
import 'package:image/image.dart' as img;

class MaskBarStitchLogic extends GetxController {
  final selectedImageCount = 2.obs;
  final selectedLayoutIndex = 0.obs;
  final layouts = <PuzzleLayoutEntity>[].obs;
  final selectedImages = <File>[].obs;
  final sectionImages = <int, File>{}.obs;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey canvasKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _loadLayouts();
  }

  void _loadLayouts() {
    layouts.value = PuzzleLayouts.getLayoutsByImageCount(
      selectedImageCount.value,
    );
    selectedLayoutIndex.value = 0;
  }

  void switchImageCount(int count, {bool clearImages = true}) {
    selectedImageCount.value = count;
    _loadLayouts();

    if (clearImages) {
      selectedImages.clear();
      sectionImages.clear();
    }
  }

  void selectLayout(int index) {
    selectedLayoutIndex.value = index;
  }

  PuzzleLayoutEntity? get currentLayout {
    if (layouts.isEmpty) return null;
    return layouts[selectedLayoutIndex.value];
  }

  Future<void> onAddImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (images != null && images.isNotEmpty) {
        final totalCount = selectedImages.length + images.length;
        if (totalCount > 2) {
          Utils.errorToast('Too many images. Maximum 2 images allowed');
          return;
        }

        selectedImages.addAll(images.map((e) => File(e.path)).toList());

        switchImageCount(2, clearImages: false);

        _autoFillImages();

        Utils.successToast('${selectedImages.length} image(s) selected');
      }
    } catch (e) {
      Utils.errorToast('Failed to select images');
    }
  }

  void _autoFillImages() {
    sectionImages.clear();
    final layout = currentLayout;
    if (layout == null) return;

    for (
      int i = 0;
      i < layout.sections.length && i < selectedImages.length;
      i++
    ) {
      sectionImages[i] = selectedImages[i];
    }
  }

  void removeImage(int index) {
    if (index < selectedImages.length) {
      selectedImages.removeAt(index);

      _autoFillImages();
    }
  }

  Future<void> onSave() async {
    if (selectedImages.isEmpty) {
      Utils.errorToast('Please add images first');
      return;
    }

    final layout = currentLayout;
    if (layout == null) {
      Utils.errorToast('Please select a layout');
      return;
    }

    for (int i = 0; i < layout.sections.length; i++) {
      if (!sectionImages.containsKey(i)) {
        Utils.errorToast('Please fill all sections');
        return;
      }
    }

    MaskBarSaveDialog.show(
      onConfirm: (name) async {
        await _saveStitchedImage(name);
      },
    );
  }

  Future<void> _saveStitchedImage(String fileName) async {
    try {
      final layout = currentLayout;
      if (layout == null) return;

      final stitchedImage = await _createStitchedImage(layout, 1000, 1000);
      if (stitchedImage == null) {
        Utils.errorToast('Failed to create stitched image');
        return;
      }

      final uniqueFileName = FileManager.generateUniqueFileName(
        extension: '.jpg',
        prefix: fileName,
      );

      final imagePath = await FileManager.saveImage(
        stitchedImage,
        uniqueFileName,
      );

      final thumbnailPath = await FileManager.generateThumbnail(imagePath);

      final fileSize = await FileManager.getFileSize(imagePath);

      final history = EditHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: imagePath,
        thumbnail: thumbnailPath,
        functionType: 'stitch',
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: fileSize,
      );

      await MaskBarDatabase().insertHistory(history);

      Get.back();
      Utils.successToast('Stitched image saved successfully');
    } catch (e) {
      Utils.errorToast('Failed to save: ${e.toString()}');
    }
  }

  Future<Uint8List?> _createStitchedImage(
    PuzzleLayoutEntity layout,
    int canvasWidth,
    int canvasHeight,
  ) async {
    try {
      final canvas = img.Image(width: canvasWidth, height: canvasHeight);
      img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

      for (int i = 0; i < layout.sections.length; i++) {
        if (!sectionImages.containsKey(i)) continue;

        final section = layout.sections[i];
        final imageFile = sectionImages[i]!;

        final imageBytes = await imageFile.readAsBytes();
        final image = img.decodeImage(imageBytes);
        if (image == null) continue;

        final x = (section.x * canvasWidth).toInt();
        final y = (section.y * canvasHeight).toInt();
        final w = (section.width * canvasWidth).toInt();
        final h = (section.height * canvasHeight).toInt();

        final croppedImage = _cropImageByPosition(
          image,
          section.x,
          section.y,
          section.width,
          section.height,
        );

        final resized = img.copyResize(
          croppedImage,
          width: w,
          height: h,
          interpolation: img.Interpolation.average,
        );

        img.compositeImage(canvas, resized, dstX: x, dstY: y);
      }

      final jpegBytes = img.encodeJpg(canvas, quality: 90);
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      return null;
    }
  }

  img.Image _cropImageByPosition(
    img.Image image,
    double sectionX,
    double sectionY,
    double sectionWidth,
    double sectionHeight,
  ) {
    final cropX = (sectionX * image.width).toInt();
    final cropY = (sectionY * image.height).toInt();
    final cropWidth = (sectionWidth * image.width).toInt();
    final cropHeight = (sectionHeight * image.height).toInt();

    final safeX = cropX.clamp(0, image.width - 1);
    final safeY = cropY.clamp(0, image.height - 1);
    final safeWidth = (cropWidth).clamp(1, image.width - safeX);
    final safeHeight = (cropHeight).clamp(1, image.height - safeY);

    return img.copyCrop(
      image,
      x: safeX,
      y: safeY,
      width: safeWidth,
      height: safeHeight,
    );
  }
}

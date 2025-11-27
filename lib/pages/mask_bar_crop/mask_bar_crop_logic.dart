import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';
import 'package:mask_bar/components/mask_bar_save_dialog.dart';
import 'package:image/image.dart' as img;

class CropRatio {
  final String name;
  final double width;
  final double height;

  CropRatio({required this.name, required this.width, required this.height});

  double get aspectRatio => width / height;
  bool get isFree => width == 0 && height == 0;
}

class MaskBarCropLogic extends GetxController {

  final selectedRatioIndex = 0.obs;

  final ratios = [
    CropRatio(name: 'Free', width: 0, height: 0),
    CropRatio(name: '1 : 1', width: 1, height: 1),
    CropRatio(name: '4 : 3', width: 4, height: 3),
    CropRatio(name: '3 : 4', width: 3, height: 4),
    CropRatio(name: '16 : 9', width: 16, height: 9),
    CropRatio(name: '9 : 16', width: 9, height: 16),
  ];

  final selectedImage = Rx<File?>(null);

  final imageSize = Rx<Size?>(null);

  final cropRect = Rect.fromLTWH(0.1, 0.1, 0.8, 0.8).obs;

  final undoStack = <Rect>[].obs;

  final redoStack = <Rect>[].obs;

  final ImagePicker _picker = ImagePicker();

  bool get canUndo => undoStack.isNotEmpty;

  bool get canRedo => redoStack.isNotEmpty;

  CropRatio get currentRatio => ratios[selectedRatioIndex.value];

  @override
  void onInit() {
    super.onInit();
    _selectImage();
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (image != null) {
        selectedImage.value = File(image.path);

        final imageBytes = await File(image.path).readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          imageSize.value = Size(
            decodedImage.width.toDouble(),
            decodedImage.height.toDouble(),
          );
        }

        cropRect.value = Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
        undoStack.clear();
        redoStack.clear();
      } else {

        Get.back();
      }
    } catch (e) {
      Utils.errorToast('Failed to select image');
      Get.back();
    }
  }

  void selectRatio(int index) {
    _pushToUndoStack();
    selectedRatioIndex.value = index;
    _adjustCropRectByRatio();
  }

  void _adjustCropRectByRatio() {
    final ratio = currentRatio;
    if (ratio.isFree) return;

    final current = cropRect.value;
    final aspectRatio = ratio.aspectRatio;

    final centerX = current.left + current.width / 2;
    final centerY = current.top + current.height / 2;

    double newWidth;
    double newHeight;

    final currentAspect = current.width / current.height;

    if (currentAspect > aspectRatio) {

      newWidth = current.width;
      newHeight = newWidth / aspectRatio;
    } else {

      newHeight = current.height;
      newWidth = newHeight * aspectRatio;
    }

    double newLeft = centerX - newWidth / 2;
    double newTop = centerY - newHeight / 2;

    bool exceedsBounds =
        newLeft < 0 ||
        newTop < 0 ||
        newLeft + newWidth > 1.0 ||
        newTop + newHeight > 1.0;

    if (exceedsBounds) {

      if (currentAspect > aspectRatio) {

        newHeight = current.height;
        newWidth = newHeight * aspectRatio;
      } else {

        newWidth = current.width;
        newHeight = newWidth / aspectRatio;
      }

      newLeft = centerX - newWidth / 2;
      newTop = centerY - newHeight / 2;

      if (newLeft < 0) newLeft = 0;
      if (newTop < 0) newTop = 0;
      if (newLeft + newWidth > 1.0) newLeft = 1.0 - newWidth;
      if (newTop + newHeight > 1.0) newTop = 1.0 - newHeight;
    }

    cropRect.value = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
  }

  void updateCropRect(Rect newRect) {
    if (currentRatio.isFree) {

      cropRect.value = newRect;
    } else {

      final aspectRatio = currentRatio.aspectRatio;
      final newAspect = newRect.width / newRect.height;

      Rect constrainedRect;
      if ((newAspect - aspectRatio).abs() < 0.01) {

        constrainedRect = newRect;
      } else {

        final newWidth = newRect.height * aspectRatio;
        constrainedRect = Rect.fromLTWH(
          newRect.left,
          newRect.top,
          newWidth,
          newRect.height,
        );

        if (constrainedRect.right > 1.0) {
          final scale = 1.0 / constrainedRect.right;
          constrainedRect = Rect.fromLTWH(
            constrainedRect.left * scale,
            constrainedRect.top,
            constrainedRect.width * scale,
            constrainedRect.height * scale,
          );
        }
      }

      cropRect.value = constrainedRect;
    }
  }

  void onDragStart() {
    _pushToUndoStack();
  }

  void onDragEnd() {

    if (!currentRatio.isFree) {
      _adjustCropRectByRatio();
    }
  }

  void moveCropRect(Offset delta) {
    final current = cropRect.value;
    double newLeft = current.left + delta.dx;
    double newTop = current.top + delta.dy;

    if (newLeft < 0) newLeft = 0;
    if (newTop < 0) newTop = 0;
    if (newLeft + current.width > 1.0) newLeft = 1.0 - current.width;
    if (newTop + current.height > 1.0) newTop = 1.0 - current.height;

    cropRect.value = Rect.fromLTWH(
      newLeft,
      newTop,
      current.width,
      current.height,
    );
  }

  void _pushToUndoStack() {
    undoStack.add(cropRect.value);
    if (undoStack.length > 10) {
      undoStack.removeAt(0);
    }
    redoStack.clear();
  }

  void undo() {
    if (!canUndo) return;

    final current = cropRect.value;
    final previous = undoStack.removeLast();
    redoStack.add(current);
    cropRect.value = previous;
  }

  void redo() {
    if (!canRedo) return;

    final current = cropRect.value;
    final next = redoStack.removeLast();
    undoStack.add(current);
    cropRect.value = next;
  }

  Future<void> onSave() async {
    if (selectedImage.value == null) {
      Utils.errorToast('No image selected');
      return;
    }

    MaskBarSaveDialog.show(
      onConfirm: (name) async {
        await _saveCroppedImage(name);
      },
    );
  }

  Future<void> _saveCroppedImage(String fileName) async {
    try {
      if (selectedImage.value == null) return;

      final imageBytes = await selectedImage.value!.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        Utils.errorToast('Failed to decode image');
        return;
      }

      final rect = cropRect.value;
      final x = (rect.left * image.width).toInt();
      final y = (rect.top * image.height).toInt();
      final w = (rect.width * image.width).toInt();
      final h = (rect.height * image.height).toInt();

      final cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

      final jpegBytes = img.encodeJpg(cropped, quality: 90);
      final croppedData = Uint8List.fromList(jpegBytes);

      final uniqueFileName = FileManager.generateUniqueFileName(
        extension: '.jpg',
        prefix: fileName,
      );

      final imagePath = await FileManager.saveImage(
        croppedData,
        uniqueFileName,
      );

      final thumbnailPath = await FileManager.generateThumbnail(imagePath);

      final fileSize = await FileManager.getFileSize(imagePath);

      final history = EditHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: imagePath,
        thumbnail: thumbnailPath,
        functionType: 'crop',
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: fileSize,
      );

      await MaskBarDatabase().insertHistory(history);
      Get.back();
      Utils.successToast('Cropped image saved successfully');
    } catch (e) {
      Utils.errorToast('Failed to save: ${e.toString()}');
    }
  }
}
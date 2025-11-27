import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';
import 'package:mask_bar/components/mask_bar_save_dialog.dart';
import 'package:image/image.dart' as img;

class MaskBarEditLogic extends GetxController {

  final brightness = 0.0.obs;
  final contrast = 0.0.obs;
  final saturation = 0.0.obs;
  final sharpness = 0.0.obs;
  final temperature = 0.0.obs;

  final selectedImage = Rx<File?>(null);

  final showOriginal = false.obs;

  final undoStack = <ImageState>[].obs;

  final redoStack = <ImageState>[].obs;

  final ImagePicker _picker = ImagePicker();

  bool get canUndo => undoStack.isNotEmpty;

  bool get canRedo => redoStack.isNotEmpty;

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
        _resetParameters();
      } else {

        Get.back();
      }
    } catch (e) {
      Utils.errorToast('Failed to select image');
      Get.back();
    }
  }

  void updateBrightness(double value) {
    _pushToUndoStack();
    brightness.value = value;
  }

  void updateContrast(double value) {
    _pushToUndoStack();
    contrast.value = value;
  }

  void updateSaturation(double value) {
    _pushToUndoStack();
    saturation.value = value;
  }

  void updateSharpness(double value) {
    _pushToUndoStack();
    sharpness.value = value;
  }

  void updateTemperature(double value) {
    _pushToUndoStack();
    temperature.value = value;
  }

  void resetParameters() {
    _pushToUndoStack();
    _resetParameters();
  }

  void _resetParameters() {
    brightness.value = 0.0;
    contrast.value = 0.0;
    saturation.value = 0.0;
    sharpness.value = 0.0;
    temperature.value = 0.0;
    undoStack.clear();
    redoStack.clear();
  }

  void _pushToUndoStack() {
    final state = ImageState(
      brightness: brightness.value,
      contrast: contrast.value,
      saturation: saturation.value,
      sharpness: sharpness.value,
      temperature: temperature.value,
    );
    undoStack.add(state);
    if (undoStack.length > 10) {
      undoStack.removeAt(0);
    }
    redoStack.clear();
  }

  void undo() {
    if (!canUndo) return;

    final current = ImageState(
      brightness: brightness.value,
      contrast: contrast.value,
      saturation: saturation.value,
      sharpness: sharpness.value,
      temperature: temperature.value,
    );

    final previous = undoStack.removeLast();
    redoStack.add(current);

    _applyState(previous);
  }

  void redo() {
    if (!canRedo) return;

    final current = ImageState(
      brightness: brightness.value,
      contrast: contrast.value,
      saturation: saturation.value,
      sharpness: sharpness.value,
      temperature: temperature.value,
    );

    final next = redoStack.removeLast();
    undoStack.add(current);

    _applyState(next);
  }

  void _applyState(ImageState state) {
    brightness.value = state.brightness;
    contrast.value = state.contrast;
    saturation.value = state.saturation;
    sharpness.value = state.sharpness;
    temperature.value = state.temperature;
  }

  Future<void> onSave() async {
    if (selectedImage.value == null) {
      Utils.errorToast('No image selected');
      return;
    }

    MaskBarSaveDialog.show(
      onConfirm: (name) async {
        await _saveEditedImage(name);
      },
    );
  }

  img.Image _applyTemperature(img.Image image, double temperature) {
    if (temperature == 0) return image;

    final tempFactor = temperature / 100;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        final a = pixel.a.toInt();

        if (tempFactor > 0) {
          r = (r + tempFactor * 50).clamp(0, 255).toInt();
          b = (b - tempFactor * 30).clamp(0, 255).toInt();
        }

        else {
          r = (r + tempFactor * 30).clamp(0, 255).toInt();
          b = (b - tempFactor * 50).clamp(0, 255).toInt();
        }

        image.setPixel(x, y, img.ColorRgba8(r, g, b, a));
      }
    }

    return image;
  }

  img.Image _applySharpen(img.Image image, double sharpness) {
    if (sharpness == 0) return image;

    final intensity = (sharpness / 100).clamp(0.0, 1.0);

    final result = img.Image.from(image);

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y);
        final top = image.getPixel(x, y - 1);
        final bottom = image.getPixel(x, y + 1);
        final left = image.getPixel(x - 1, y);
        final right = image.getPixel(x + 1, y);

        int r = (center.r * 5 - top.r - bottom.r - left.r - right.r).toInt();
        int g = (center.g * 5 - top.g - bottom.g - left.g - right.g).toInt();
        int b = (center.b * 5 - top.b - bottom.b - left.b - right.b).toInt();

        r = (center.r * (1 - intensity) + r * intensity).clamp(0, 255).toInt();
        g = (center.g * (1 - intensity) + g * intensity).clamp(0, 255).toInt();
        b = (center.b * (1 - intensity) + b * intensity).clamp(0, 255).toInt();

        result.setPixel(x, y, img.ColorRgba8(r, g, b, center.a.toInt()));
      }
    }

    return result;
  }

  Future<void> _saveEditedImage(String fileName) async {
    try {
      if (selectedImage.value == null) return;

      final imageBytes = await selectedImage.value!.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        Utils.errorToast('Failed to decode image');
        return;
      }

      var editedImage = image;

      if (brightness.value != 0 ||
          contrast.value != 0 ||
          saturation.value != 0) {
        editedImage = img.adjustColor(
          editedImage,
          brightness: brightness.value / 100,
          contrast: 1.0 + (contrast.value / 100),
          saturation: 1.0 + (saturation.value / 100),
        );
      }

      if (temperature.value != 0) {
        editedImage = _applyTemperature(editedImage, temperature.value);
      }

      if (sharpness.value > 0) {
        editedImage = _applySharpen(editedImage, sharpness.value);
      }

      final jpegBytes = img.encodeJpg(editedImage, quality: 90);
      final editedData = Uint8List.fromList(jpegBytes);

      final uniqueFileName = FileManager.generateUniqueFileName(
        extension: '.jpg',
        prefix: fileName,
      );

      final imagePath = await FileManager.saveImage(editedData, uniqueFileName);

      final thumbnailPath = await FileManager.generateThumbnail(imagePath);

      final fileSize = await FileManager.getFileSize(imagePath);

      final history = EditHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: imagePath,
        thumbnail: thumbnailPath,
        functionType: 'edit',
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: fileSize,
      );

      await MaskBarDatabase().insertHistory(history);
      Get.back();
      Utils.successToast('Edited image saved successfully');
    } catch (e) {
      Utils.errorToast('Failed to save: ${e.toString()}');
    }
  }
}

class ImageState {
  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpness;
  final double temperature;

  ImageState({
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.sharpness,
    required this.temperature,
  });
}
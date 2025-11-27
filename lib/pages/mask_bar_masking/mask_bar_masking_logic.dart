import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:uuid/uuid.dart';
import 'package:mask_bar/utils/index.dart';
import 'package:mask_bar/components/mask_bar_save_dialog.dart';
import 'package:image/image.dart' as img;

class MaskItem {
  String id;
  double x;
  double y;
  double width;
  double height;
  String style;
  String color;
  int opacity;
  double borderRadius;

  MaskItem({
    required this.id,
    this.x = 0.1,
    this.y = 0.1,
    this.width = 0.3,
    this.height = 0.1,
    this.style = 'solid',
    this.color = '#000000',
    this.opacity = 80,
    this.borderRadius = 0,
  });
}

class MaskBarMaskingLogic extends GetxController {
  final MaskBarDatabase _database = Get.find<MaskBarDatabase>();
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  final GlobalKey repaintBoundaryKey = GlobalKey();

  final imageFile = Rxn<File>();
  final maskList = <MaskItem>[].obs;
  final selectedMaskId = RxnString();
  final maskBarConfigs = <MaskBarEntity>[].obs;

  final maskStyle = 'solid'.obs;
  final maskColor = '#000000'.obs;
  final maskOpacity = 80.obs;

  final _historyStack = <List<MaskItem>>[].obs;
  final _redoStack = <List<MaskItem>>[].obs;
  final canUndo = false.obs;
  final canRedo = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _selectImage();
    await _loadMaskConfig();
  }

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
      );

      if (image != null) {
        imageFile.value = File(image.path);
      } else {

        Get.back();
      }
    } catch (e) {
      Utils.errorToast('Failed to select image');
      Get.back();
    }
  }

  Future<void> _loadMaskConfig() async {
    final config = await _database.getMaskBarList();
    maskBarConfigs.value = config;
  }

  void _saveHistory() {

    final currentState = maskList
        .map(
          (mask) => MaskItem(
            id: mask.id,
            x: mask.x,
            y: mask.y,
            width: mask.width,
            height: mask.height,
            style: mask.style,
            color: mask.color,
            opacity: mask.opacity,
            borderRadius: mask.borderRadius,
          ),
        )
        .toList();
    _historyStack.add(currentState);

    _redoStack.clear();

    if (_historyStack.length > 50) {
      _historyStack.removeAt(0);
    }

    _updateHistoryState();
  }

  void _updateHistoryState() {
    canUndo.value = _historyStack.isNotEmpty;
    canRedo.value = _redoStack.isNotEmpty;
  }

  void undo() {
    if (_historyStack.isEmpty) return;

    final currentState = maskList
        .map(
          (mask) => MaskItem(
            id: mask.id,
            x: mask.x,
            y: mask.y,
            width: mask.width,
            height: mask.height,
            style: mask.style,
            color: mask.color,
            opacity: mask.opacity,
            borderRadius: mask.borderRadius,
          ),
        )
        .toList();
    _redoStack.add(currentState);

    final previousState = _historyStack.removeLast();
    maskList.value = previousState
        .map(
          (mask) => MaskItem(
            id: mask.id,
            x: mask.x,
            y: mask.y,
            width: mask.width,
            height: mask.height,
            style: mask.style,
            color: mask.color,
            opacity: mask.opacity,
            borderRadius: mask.borderRadius,
          ),
        )
        .toList();

    _updateHistoryState();
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final currentState = maskList
        .map(
          (mask) => MaskItem(
            id: mask.id,
            x: mask.x,
            y: mask.y,
            width: mask.width,
            height: mask.height,
            style: mask.style,
            color: mask.color,
            opacity: mask.opacity,
            borderRadius: mask.borderRadius,
          ),
        )
        .toList();
    _historyStack.add(currentState);

    final redoState = _redoStack.removeLast();
    maskList.value = redoState
        .map(
          (mask) => MaskItem(
            id: mask.id,
            x: mask.x,
            y: mask.y,
            width: mask.width,
            height: mask.height,
            style: mask.style,
            color: mask.color,
            opacity: mask.opacity,
            borderRadius: mask.borderRadius,
          ),
        )
        .toList();

    _updateHistoryState();
  }

  void addMask([MaskBarEntity? config]) {
    if (imageFile.value == null) return;

    _saveHistory();

    final newMask = MaskItem(
      id: _uuid.v4(),
      x: 0.1 + (maskList.length * 0.05) % 0.5,
      y: 0.1 + (maskList.length * 0.05) % 0.5,
      width: 0.3,
      height: 0.1,
      style: config?.style ?? maskStyle.value,
      color: config?.color ?? maskColor.value,
      opacity: config?.opacity ?? maskOpacity.value,
    );
    maskList.add(newMask);
    selectedMaskId.value = newMask.id;

    if (config != null) {
      Utils.successToast('Added mask with ${config.style} style');
    }
  }

  bool _isDragging = false;

  void updateMaskPosition(String id, double dx, double dy) {
    if (imageFile.value == null) return;

    if (!_isDragging) {
      _saveHistory();
      _isDragging = true;
    }

    final index = maskList.indexWhere((m) => m.id == id);
    if (index != -1 && index < maskList.length) {
      final mask = maskList[index];
      mask.x = (mask.x + dx).clamp(0.0, 1.0 - mask.width);
      mask.y = (mask.y + dy).clamp(0.0, 1.0 - mask.height);
      maskList[index] = mask;
    }
  }

  void onDragEnd() {
    _isDragging = false;
  }

  bool _isResizing = false;

  void updateMaskSizeFromHandle(
    String id,
    Alignment alignment,
    double dx,
    double dy,
  ) {
    if (imageFile.value == null) return;

    if (!_isResizing) {
      _saveHistory();
      _isResizing = true;
    }

    final index = maskList.indexWhere((m) => m.id == id);
    if (index == -1 || index >= maskList.length) return;

    final mask = maskList[index];
    double x = mask.x;
    double y = mask.y;
    double width = mask.width;
    double height = mask.height;

    if (alignment == Alignment.topLeft) {
      x += dx;
      y += dy;
      width -= dx;
      height -= dy;
    } else if (alignment == Alignment.topRight) {
      y += dy;
      width += dx;
      height -= dy;
    } else if (alignment == Alignment.bottomLeft) {
      x += dx;
      width -= dx;
      height += dy;
    } else if (alignment == Alignment.bottomRight) {
      width += dx;
      height += dy;
    }

    if (width < 0.05) width = 0.05;
    if (height < 0.05) height = 0.05;

    if (x < 0) {
      width += x;
      x = 0;
    }
    if (y < 0) {
      height += y;
      y = 0;
    }
    if (x + width > 1.0) width = 1.0 - x;
    if (y + height > 1.0) height = 1.0 - y;

    mask.x = x;
    mask.y = y;
    mask.width = width;
    mask.height = height;
    maskList[index] = mask;
  }

  void onResizeEnd() {
    _isResizing = false;
  }

  void selectMask(String id) {
    selectedMaskId.value = id;
  }

  void applyMaskConfig(MaskBarEntity config) {
    final mask = selectedMask;
    if (mask != null) {

      _saveHistory();
      final index = maskList.indexWhere((m) => m.id == mask.id);
      if (index != -1) {
        mask.style = config.style;
        mask.color = config.color;
        mask.opacity = config.opacity;
        maskList[index] = mask;
        Utils.successToast('Applied configuration to selected mask');
      }
    } else {

      maskStyle.value = config.style;
      maskColor.value = config.color;
      maskOpacity.value = config.opacity;
      Utils.successToast('Set as default configuration');
    }
  }

  void updateSelectedMaskStyle(String style) {
    final mask = selectedMask;
    if (mask == null) return;

    _saveHistory();
    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.style = style;
      maskList[index] = mask;
    }
  }

  void updateSelectedMaskColor(String color) {
    final mask = selectedMask;
    if (mask == null) return;

    _saveHistory();
    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.color = color;
      maskList[index] = mask;
    }
  }

  void updateSelectedMaskOpacity(int opacity) {
    final mask = selectedMask;
    if (mask == null) return;

    _saveHistory();
    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.opacity = opacity;
      maskList[index] = mask;
    }
  }

  void removeSelectedMask() {
    final selectedId = selectedMaskId.value;
    if (selectedId != null) {
      _saveHistory();
      maskList.removeWhere((m) => m.id == selectedId);
      selectedMaskId.value = null;
    }
  }

  MaskItem? get selectedMask {
    final selectedId = selectedMaskId.value;
    if (selectedId == null) return null;
    try {
      return maskList.firstWhere((m) => m.id == selectedId);
    } catch (e) {
      return null;
    }
  }

  bool _isAdjustingWidth = false;
  bool _isAdjustingHeight = false;

  void updateSelectedMaskWidth(double width) {
    final mask = selectedMask;
    if (mask == null) return;

    if (!_isAdjustingWidth) {
      _saveHistory();
      _isAdjustingWidth = true;
    }

    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.width = (width / 100).clamp(0.05, 1.0);
      maskList[index] = mask;
    }
  }

  void onWidthAdjustEnd() {
    _isAdjustingWidth = false;
  }

  void updateSelectedMaskHeight(double height) {
    final mask = selectedMask;
    if (mask == null) return;

    if (!_isAdjustingHeight) {
      _saveHistory();
      _isAdjustingHeight = true;
    }

    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.height = (height / 100).clamp(0.05, 1.0);
      maskList[index] = mask;
    }
  }

  void onHeightAdjustEnd() {
    _isAdjustingHeight = false;
  }

  bool _isAdjustingBorderRadius = false;

  void updateSelectedMaskBorderRadius(double radius) {
    final mask = selectedMask;
    if (mask == null) return;

    if (!_isAdjustingBorderRadius) {
      _saveHistory();
      _isAdjustingBorderRadius = true;
    }

    final index = maskList.indexWhere((m) => m.id == mask.id);
    if (index != -1) {
      mask.borderRadius = radius.clamp(0, 50);
      maskList[index] = mask;
    }
  }

  void onBorderRadiusAdjustEnd() {
    _isAdjustingBorderRadius = false;
  }

  Future<void> onSave() async {
    if (imageFile.value == null) {
      Utils.errorToast('Please select an image first');
      return;
    }

    if (maskList.isEmpty) {
      Utils.errorToast('Please add at least one mask');
      return;
    }

    MaskBarSaveDialog.show(
      onConfirm: (fileName) async {
        await _saveImageWithMasks(fileName);
      },
    );
  }

  Future<void> _saveImageWithMasks(String fileName) async {
    try {
      if (imageFile.value == null) return;

      selectedMaskId.value = null;

      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        Utils.errorToast('Failed to capture image');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Utils.errorToast('Failed to convert image');
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      final pngImage = img.decodeImage(pngBytes);
      if (pngImage == null) {
        Utils.errorToast('Failed to decode image');
        return;
      }

      final jpegBytes = img.encodeJpg(pngImage, quality: 90);
      final processedData = Uint8List.fromList(jpegBytes);

      final uniqueFileName = FileManager.generateUniqueFileName(
        extension: '.jpg',
        prefix: fileName,
      );

      final imagePath = await FileManager.saveImage(
        processedData,
        uniqueFileName,
      );

      final thumbnailPath = await FileManager.generateThumbnail(imagePath);

      final fileSize = await FileManager.getFileSize(imagePath);

      final history = EditHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: imagePath,
        thumbnail: thumbnailPath,
        functionType: 'mask',
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: fileSize,
      );

      await _database.insertHistory(history);

      Get.back();
      Utils.successToast('Masked image saved successfully');
    } catch (e) {
      Utils.errorToast('Failed to save: ${e.toString()}');
    }
  }
}
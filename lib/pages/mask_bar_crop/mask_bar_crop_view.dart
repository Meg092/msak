import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'mask_bar_crop_logic.dart';

class MaskBarCropPage extends GetView<MaskBarCropLogic> {
  const MaskBarCropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Crop', style: TextStyle(color: Colors.white)),
        actions: [

          Obx(
            () => IconButton(
              icon: Icon(
                Icons.undo,
                color: controller.canUndo ? Colors.white : Colors.grey,
              ),
              onPressed: controller.canUndo ? controller.undo : null,
            ),
          ),

          Obx(
            () => IconButton(
              icon: Icon(
                Icons.redo,
                color: controller.canRedo ? Colors.white : Colors.grey,
              ),
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: ElevatedButton(
              onPressed: controller.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              ),
              child: Text('Save', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [

          Expanded(
            child: Obx(
              () => controller.selectedImage.value != null
                  ? _buildCropArea()
                  : Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(controller.ratios.length, (index) {
                    final isSelected =
                        controller.selectedRatioIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.selectRatio(index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF007AFF)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF007AFF)
                                : Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          controller.ratios[index].name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    return Obx(() {
      final imageSize = controller.imageSize.value;
      if (imageSize == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {

          final containerWidth = constraints.maxWidth;
          final imageAspectRatio = imageSize.width / imageSize.height;
          final displayWidth = containerWidth;
          final displayHeight = containerWidth / imageAspectRatio;

          return SingleChildScrollView(
            child: SizedBox(
              width: displayWidth,
              height: displayHeight,
              child: Stack(
                children: [

                  Positioned(
                    top: 0,
                    left: 0,
                    width: displayWidth,
                    height: displayHeight,
                    child: Image.file(
                      controller.selectedImage.value!,
                      fit: BoxFit.fill,
                    ),
                  ),

                  Obx(() {
                    controller.cropRect.value;
                    return _buildCropOverlay(
                      displayWidth: displayWidth,
                      displayHeight: displayHeight,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCropOverlay({
    required double displayWidth,
    required double displayHeight,
  }) {
    final rect = controller.cropRect.value;

    final left = rect.left * displayWidth;
    final top = rect.top * displayHeight;
    final width = rect.width * displayWidth;
    final height = rect.height * displayHeight;

    return Stack(
      children: [

        CustomPaint(
          size: Size(displayWidth, displayHeight),
          painter: CropOverlayPainter(
            cropRect: Rect.fromLTWH(left, top, width, height),
          ),
        ),

        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: GestureDetector(
            onPanStart: (_) => controller.onDragStart(),
            onPanUpdate: (details) {

              final dx = details.delta.dx / displayWidth;
              final dy = details.delta.dy / displayHeight;
              controller.moveCropRect(Offset(dx, dy));
            },
            onPanEnd: (_) => controller.onDragEnd(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Stack(
                children: [

                  _buildCornerHandle(
                    Alignment.topLeft,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildCornerHandle(
                    Alignment.topRight,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildCornerHandle(
                    Alignment.bottomLeft,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildCornerHandle(
                    Alignment.bottomRight,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),

                  _buildEdgeHandle(
                    Alignment.topCenter,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildEdgeHandle(
                    Alignment.bottomCenter,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildEdgeHandle(
                    Alignment.centerLeft,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                  _buildEdgeHandle(
                    Alignment.centerRight,
                    displayWidth,
                    displayHeight,
                    rect,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerHandle(
    Alignment alignment,
    double displayWidth,
    double displayHeight,
    Rect rect,
  ) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanStart: (_) => controller.onDragStart(),
        onPanUpdate: (details) {
          _updateCropRectFromHandle(
            alignment,
            details.delta,
            displayWidth,
            displayHeight,
            rect,
          );
        },
        onPanEnd: (_) => controller.onDragEnd(),
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF007AFF), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle(
    Alignment alignment,
    double displayWidth,
    double displayHeight,
    Rect rect,
  ) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanStart: (_) => controller.onDragStart(),
        onPanUpdate: (details) {
          _updateCropRectFromHandle(
            alignment,
            details.delta,
            displayWidth,
            displayHeight,
            rect,
          );
        },
        onPanEnd: (_) => controller.onDragEnd(),
        child: Container(
          width:
              alignment == Alignment.centerLeft ||
                  alignment == Alignment.centerRight
              ? 15.w
              : 30.w,
          height:
              alignment == Alignment.topCenter ||
                  alignment == Alignment.bottomCenter
              ? 15.h
              : 30.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  void _updateCropRectFromHandle(
    Alignment alignment,
    Offset delta,
    double displayWidth,
    double displayHeight,
    Rect rect,
  ) {

    final dx = delta.dx / displayWidth;
    final dy = delta.dy / displayHeight;

    double left = rect.left;
    double top = rect.top;
    double width = rect.width;
    double height = rect.height;

    if (alignment == Alignment.topLeft) {
      left += dx;
      top += dy;
      width -= dx;
      height -= dy;
    } else if (alignment == Alignment.topRight) {
      top += dy;
      width += dx;
      height -= dy;
    } else if (alignment == Alignment.bottomLeft) {
      left += dx;
      width -= dx;
      height += dy;
    } else if (alignment == Alignment.bottomRight) {
      width += dx;
      height += dy;
    } else if (alignment == Alignment.topCenter) {
      top += dy;
      height -= dy;
    } else if (alignment == Alignment.bottomCenter) {
      height += dy;
    } else if (alignment == Alignment.centerLeft) {
      left += dx;
      width -= dx;
    } else if (alignment == Alignment.centerRight) {
      width += dx;
    }

    if (width < 0.2) width = 0.2;
    if (height < 0.2) height = 0.2;

    if (left < 0) {
      width += left;
      left = 0;
    }
    if (top < 0) {
      height += top;
      top = 0;
    }
    if (left + width > 1.0) width = 1.0 - left;
    if (top + height > 1.0) height = 1.0 - top;

    controller.updateCropRect(Rect.fromLTWH(left, top, width, height));
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), paint);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        cropRect.bottom,
        size.width,
        size.height - cropRect.bottom,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        cropRect.right,
        cropRect.top,
        size.width - cropRect.right,
        cropRect.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'mask_bar_stitch_logic.dart';

class MaskBarStitchPage extends GetView<MaskBarStitchLogic> {
  const MaskBarStitchPage({super.key});

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
        title: const Text('Stitch', style: TextStyle(color: Colors.white)),
        actions: [
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Obx(() => _buildCanvas()),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton.icon(
                  onPressed: controller.onAddImages,
                  icon: Icon(Icons.add_photo_alternate, size: 20.w),
                  label: Obx(
                    () => Text(
                      controller.selectedImages.isEmpty
                          ? 'Add Images (2)'
                          : '${controller.selectedImages.length} images selected',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            _buildImagePreviewList(),

            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'Select Layout',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    height: 60.h,
                    child: Obx(
                      () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: controller.layouts.length,
                        itemBuilder: (context, index) {
                          final layout = controller.layouts[index];
                          return Obx(() {
                            final isSelected =
                                controller.selectedLayoutIndex.value == index;
                            return GestureDetector(
                              onTap: () => controller.selectLayout(index),
                              child: Container(
                                margin: EdgeInsets.only(right: 14.w),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: layout.iconPath != null
                                          ? Image.asset(
                                              width: 46.w,
                                              height: 46.h,
                                              layout.iconPath!,
                                              fit: BoxFit.contain,
                                            )
                                          : SizedBox(
                                              width: 46.w,
                                              height: 46.h,
                                              child: _buildLayoutPreview(
                                                layout,
                                              ),
                                            ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 20.w,
                                          height: 20.w,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF007AFF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14.w,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    final layout = controller.currentLayout;
    if (layout == null) {
      return Center(
        child: Text(
          'No layout selected',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      );
    }

    final canvasWidth = Get.width;
    final canvasHeight = 400.h;

    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        children: layout.sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;

          return Positioned(
            left: section.x * canvasWidth,
            top: section.y * canvasHeight,
            width: section.width * canvasWidth,
            height: section.height * canvasHeight,
            child: Container(
              color: const Color(0xFF2A2A2A),
              child: controller.sectionImages.containsKey(index)
                  ? ClipRect(
                      child: FittedBox(
                        fit: BoxFit.none,
                        alignment: Alignment(
                          _calculateAlignment(section.x, section.width),
                          _calculateAlignment(section.y, section.height),
                        ),
                        child: SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: Image.file(
                            controller.sectionImages[index]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.add, color: Colors.white54, size: 30.w),
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return Obx(
      () => Container(
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: controller.selectedImages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 40.w,
                      color: const Color(0xFF666666),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No images selected',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.selectedImages[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () => _showImagePreview(image),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: DecorationImage(
                                image: FileImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8.w,
                            right: -8.w,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(index),
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showImagePreview(File image) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20.w),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(image),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 24.w),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black87,
    );
  }

  Widget _buildLayoutPreview(layout) {
    return CustomPaint(
      painter: LayoutPreviewPainter(layout),
      child: Container(),
    );
  }

  double _calculateAlignment(double position, double size) {
    final center = position + size / 2;
    return (center * 2) - 1;
  }
}

class LayoutPreviewPainter extends CustomPainter {
  final dynamic layout;

  LayoutPreviewPainter(this.layout);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var section in layout.sections) {
      final rect = Rect.fromLTWH(
        section.x * size.width,
        section.y * size.height,
        section.width * size.width,
        section.height * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

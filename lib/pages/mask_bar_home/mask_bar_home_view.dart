import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mask_bar/utils/index.dart';
import 'mask_bar_home_logic.dart';

class MaskBarHomePage extends GetView<MaskBarHomeLogic> {
  const MaskBarHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mask Bar Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Obx(() => _buildMaskPreview()),
                  SizedBox(height: 16.h),

                  Obx(
                    () => _buildSettingItem(
                      title: 'Mask Bar Style',
                      trailing: Text(
                        _getStyleName(controller.maskStyle.value),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      onTap: controller.onSelectMaskStyle,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _buildColorSettingItem(
                    title: 'Mask Bar Color',
                    onTap: controller.onSelectMaskColor,
                  ),
                  SizedBox(height: 12.h),

                  Obx(
                    () => _buildSettingItem(
                      title: 'Mask Bar Opacity',
                      trailing: Text(
                        '${controller.selectedOpacity.value}%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      onTap: controller.onSelectOpacity,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.onAddMaskBarTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      child: Text(
                        'Add Mask Bar',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tools',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildFunctionItem(
                    icon: Icons.block,
                    title: 'Masking',
                    onTap: () => Get.toNamed('/mask_bar_masking'),
                  ),
                  Divider(height: 1.h, color: const Color(0xFFF0F0F0)),
                  SizedBox(height: 12.h),
                  _buildFunctionItem(
                    icon: Icons.grid_view,
                    title: 'Stitch',
                    onTap: () => Get.toNamed('/mask_bar_stitch'),
                  ),
                  Divider(height: 1.h, color: const Color(0xFFF0F0F0)),
                  SizedBox(height: 12.h),
                  _buildFunctionItem(
                    icon: Icons.crop,
                    title: 'Crop',
                    onTap: () => Get.toNamed('/mask_bar_crop'),
                  ),
                  Divider(height: 1.h, color: const Color(0xFFF0F0F0)),
                  SizedBox(height: 12.h),
                  _buildFunctionItem(
                    icon: Icons.edit,
                    title: 'Edit',
                    onTap: () => Get.toNamed('/mask_bar_edit'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(vertical: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildSimpleItem(
                    title: 'Edit History',
                    onTap: () => Get.toNamed('/mask_bar_history'),
                  ),
                  Divider(height: 1.h, color: const Color(0xFFF0F0F0)),
                  _buildSimpleItem(
                    title: 'Mask Bar Records',
                    onTap: () => Get.toNamed('/mask_bar_record'),
                  ),
                  Divider(height: 1.h, color: const Color(0xFFF0F0F0)),
                  _buildSimpleItem(
                    title: 'App Version',
                    trailing: 'V1.00',
                    showArrow: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskPreview() {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade200,
                    Colors.purple.shade200,
                    Colors.pink.shade200,
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 18.h,
              child: _buildMaskBarByStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskBarByStyle() {
    final String style = controller.maskStyle.value;
    final Color baseColor = Utils.hexToColor(controller.maskColor.value);
    final double opacity = controller.selectedOpacity.value / 100;

    switch (style) {
      case 'solid':
        return Container(
          width: double.infinity,
          height: 24.h,
          color: baseColor.withOpacity(opacity),
        );
      case 'mosaic':
        return Container(
          width: double.infinity,
          height: 24.h,
          child: CustomPaint(
            painter: _MosaicPainter(baseColor: baseColor, opacity: opacity),
          ),
        );
      case 'blur':
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 24.h,
              color: baseColor.withOpacity(opacity * 0.4),
            ),
          ),
        );
      default:
        return Container(
          width: double.infinity,
          height: 24.h,
          color: baseColor.withOpacity(opacity),
        );
    }
  }

  String _getStyleName(String style) {
    switch (style) {
      case 'solid':
        return 'Solid Color';
      case 'mosaic':
        return 'Mosaic';
      case 'blur':
        return 'Blur';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSettingItem({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) trailing,
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right,
                  size: 20.w,
                  color: const Color(0xFFCCCCCC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSettingItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: Utils.hexToColor(controller.maskColor.value),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right,
                    size: 20.w,
                    color: const Color(0xFFCCCCCC),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24.w,
              color: const Color(0xFF007AFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleItem({
    required String title,
    String? trailing,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF333333)),
            ),
            Row(
              children: [
                if (trailing != null)
                  Text(
                    trailing,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                if (showArrow) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right,
                    size: 20.w,
                    color: const Color(0xFFCCCCCC),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MosaicPainter extends CustomPainter {
  final Color baseColor;
  final double opacity;

  _MosaicPainter({required this.baseColor, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = baseColor.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final blockSize = 6.0;
    final random = [0.7, 0.85, 0.6, 0.9, 0.75, 0.8, 0.65, 0.95];
    int colorIndex = 0;

    for (double y = 0; y < size.height; y += blockSize) {
      for (double x = 0; x < size.width; x += blockSize) {
        final blockPaint = Paint()
          ..color = baseColor.withOpacity(
            opacity * random[colorIndex % random.length],
          )
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(x, y, blockSize - 0.5, blockSize - 0.5),
          blockPaint,
        );
        colorIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(_MosaicPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.opacity != opacity;
  }
}

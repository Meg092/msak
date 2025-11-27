import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'mask_bar_edit_logic.dart';

class MaskBarEditPage extends GetView<MaskBarEditLogic> {
  const MaskBarEditPage({super.key});

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
        title: const Text('Edit', style: TextStyle(color: Colors.white)),
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
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Obx(
                    () => controller.selectedImage.value != null
                        ? _buildImagePreview()
                        : Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                  ),
                ),

                Positioned(
                  bottom: 30.h,
                  right: 30.w,
                  child: GestureDetector(
                    onLongPressStart: (_) => controller.showOriginal.value = true,
                    onLongPressEnd: (_) => controller.showOriginal.value = false,
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.compare,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          _buildAdjustmentControls(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.showOriginal.value) {
        return Image.file(
          controller.selectedImage.value!,
          fit: BoxFit.contain,
        );
      }

      return ColorFiltered(
        colorFilter: ColorFilter.matrix(_buildColorMatrix()),
        child: Image.file(
          controller.selectedImage.value!,
          fit: BoxFit.contain,
        ),
      );
    });
  }

  List<double> _buildColorMatrix() {

    final b = 1.0 + (controller.brightness.value / 100);
    final c = 1.0 + (controller.contrast.value / 100);
    final s = 1.0 + (controller.saturation.value / 100);

    return [
      c * s, 0, 0, 0, (b - 1) * 255,
      0, c * s, 0, 0, (b - 1) * 255,
      0, 0, c * s, 0, (b - 1) * 255,
      0, 0, 0, 1, 0,
    ];
  }

  Widget _buildAdjustmentControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => _buildSlider(
              label: 'Brightness',
              value: controller.brightness.value,
              min: -100,
              max: 100,
              onChanged: controller.updateBrightness,
            )),
            SizedBox(height: 16.h),
            Obx(() => _buildSlider(
              label: 'Contrast',
              value: controller.contrast.value,
              min: -100,
              max: 100,
              onChanged: controller.updateContrast,
            )),
            SizedBox(height: 16.h),
            Obx(() => _buildSlider(
              label: 'Saturation',
              value: controller.saturation.value,
              min: -100,
              max: 100,
              onChanged: controller.updateSaturation,
            )),
            SizedBox(height: 16.h),
            Obx(() => _buildSlider(
              label: 'Sharpness',
              value: controller.sharpness.value,
              min: 0,
              max: 100,
              onChanged: controller.updateSharpness,
            )),
            SizedBox(height: 16.h),
            Obx(() => _buildSlider(
              label: 'Temperature',
              value: controller.temperature.value,
              min: -100,
              max: 100,
              onChanged: controller.updateTemperature,
            )),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: controller.resetParameters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Reset', style: TextStyle(fontSize: 14.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.h,
              activeTrackColor: const Color(0xFF007AFF),
              inactiveTrackColor: const Color(0xFF666666),
              thumbColor: const Color(0xFF007AFF),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.w),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.w),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 40.w,
          child: Text(
            value.toInt().toString(),
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
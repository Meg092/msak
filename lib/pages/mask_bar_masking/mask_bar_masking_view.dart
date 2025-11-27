import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'mask_bar_masking_logic.dart';
import 'package:mask_bar/utils/index.dart';
import 'package:mask_bar/db_mask_bar/db_mask_bar_entity.dart';

class MaskBarMaskingView extends GetView<MaskBarMaskingLogic> {
  const MaskBarMaskingView({super.key});

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
        title: const Text('Masking', style: TextStyle(color: Colors.white)),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.undo,
                color: controller.canUndo.value ? Colors.white : Colors.grey,
              ),
              onPressed: controller.canUndo.value ? controller.undo : null,
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.redo,
                color: controller.canRedo.value ? Colors.white : Colors.grey,
              ),
              onPressed: controller.canRedo.value ? controller.redo : null,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () => controller.imageFile.value != null
                  ? _buildMaskingArea()
                  : Container(
                      width: double.infinity,
                      height: 300.h,
                      margin: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
            ),

            Obx(() {
              if (controller.imageFile.value == null ||
                  controller.maskBarConfigs.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildMaskConfigSection();
            }),

            Obx(() {
              if (controller.imageFile.value == null) {
                return const SizedBox.shrink();
              }
              return _buildControlPanel();
            }),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskingArea() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200.h),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF4A4A4A)),
      child: RepaintBoundary(
        key: controller.repaintBoundaryKey,
        child: ClipRRect(
          child: Stack(
            children: [

              Image.file(
                controller.imageFile.value!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),

              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Obx(() => _buildMasksOverlay(constraints));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasksOverlay(BoxConstraints constraints) {
    return Stack(
      children: controller.maskList.map((mask) {
        final isSelected = controller.selectedMaskId.value == mask.id;
        final maskColorObj = Utils.hexToColor(mask.color);
        final opacity = mask.opacity / 100.0;
        final style = mask.style;

        final left = mask.x * constraints.maxWidth;
        final top = mask.y * constraints.maxHeight;
        final width = mask.width * constraints.maxWidth;
        final height = mask.height * constraints.maxHeight;

        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: GestureDetector(
            onTap: () => controller.selectMask(mask.id),
            onPanUpdate: (details) {
              final dx = details.delta.dx / constraints.maxWidth;
              final dy = details.delta.dy / constraints.maxHeight;
              controller.updateMaskPosition(mask.id, dx, dy);
            },
            onPanEnd: (_) => controller.onDragEnd(),
            child: Container(
              decoration: _buildMaskDecoration(
                style,
                maskColorObj,
                opacity,
                isSelected,
                mask.borderRadius,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaskConfigSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mask Presets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.maskBarConfigs.length,
              itemBuilder: (context, index) {
                final config = controller.maskBarConfigs[index];
                return _buildConfigPresetCard(config, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPresetCard(MaskBarEntity config, int index) {
    final colorObj = Utils.hexToColor(config.color);
    final opacity = config.opacity / 100.0;

    return GestureDetector(
      onTap: () => controller.addMask(config),
      child: Container(
        width: 120.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF404040), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Center(
                child: Container(
                  width: 80.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: colorObj.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      config.style,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${config.color} - ${config.opacity}%',
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              height: 90.h,
              margin: EdgeInsets.only(bottom: 16.h),
              child: Obx(() {

                final selectedId = controller.selectedMaskId.value;
                if (controller.maskList.isEmpty) {
                  return Center(
                    child: Text(
                      'No masks added yet',
                      style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.maskList.length,
                  itemBuilder: (context, index) {
                    final mask = controller.maskList[index];
                    final isSelected = selectedId == mask.id;
                    return _buildMaskItem(mask, isSelected, index);
                  },
                );
              }),
            ),

            Obx(() {
              final mask = controller.selectedMask;
              if (mask == null) return const SizedBox.shrink();
              return Column(
                children: [
                  _buildSlider(
                    label: 'Width',
                    value: mask.width * 100,
                    min: 5,
                    max: 100,
                    onChanged: controller.updateSelectedMaskWidth,
                  ),
                  SizedBox(height: 16.h),
                  _buildSlider(
                    label: 'Height',
                    value: mask.height * 100,
                    min: 5,
                    max: 100,
                    onChanged: controller.updateSelectedMaskHeight,
                  ),
                  SizedBox(height: 16.h),
                  _buildSlider(
                    label: 'Border Radius',
                    value: mask.borderRadius,
                    min: 0,
                    max: 50,
                    onChanged: controller.updateSelectedMaskBorderRadius,
                  ),
                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    height: 45.h,
                    child: ElevatedButton(
                      onPressed: controller.removeSelectedMask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Delete Mask',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskItem(MaskItem mask, bool isSelected, int index) {
    final maskColorObj = Utils.hexToColor(mask.color);
    final opacity = mask.opacity / 100.0;

    return GestureDetector(
      onTap: () => controller.selectMask(mask.id),
      child: Container(
        width: 80.w,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF007AFF)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(
                child: Container(
                  width: 50.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: maskColorObj.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Mask ${index + 1}',
              style: TextStyle(
                color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          width: 60.w,
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
              onChangeEnd: (value) {

                if (label == 'Width') {
                  controller.onWidthAdjustEnd();
                } else if (label == 'Height') {
                  controller.onHeightAdjustEnd();
                } else if (label == 'Border Radius') {
                  controller.onBorderRadiusAdjustEnd();
                }
              },
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 30.w,
          child: Text(
            '${value.toInt()}%',
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildMaskDecoration(
    String style,
    Color color,
    double opacity,
    bool isSelected,
    double borderRadius,
  ) {
    Color finalColor = color.withOpacity(opacity);

    switch (style) {
      case 'mosaic':
        return BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: const Color(0xFF007AFF), width: 2)
              : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              finalColor,
              finalColor.withOpacity(opacity * 0.8),
              finalColor,
              finalColor.withOpacity(opacity * 0.8),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
            tileMode: TileMode.repeated,
          ),
        );
      case 'blur':
        return BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: const Color(0xFF007AFF), width: 2)
              : null,
        );
      case 'solid':
      default:
        return BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelected
              ? Border.all(color: const Color(0xFF007AFF), width: 2)
              : null,
        );
    }
  }
}
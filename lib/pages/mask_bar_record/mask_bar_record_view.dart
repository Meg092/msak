import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mask_bar/utils/index.dart';
import 'mask_bar_record_logic.dart';

class MaskBarRecordPage extends GetView<MaskBarRecordLogic> {
  const MaskBarRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: const Text('Mask Bar Records'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.maskBarList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.maskBarList.length,
          itemBuilder: (context, index) {
            final maskBar = controller.maskBarList[index];
            return _buildMaskBarItem(maskBar, index);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block_outlined,
            size: 80.w,
            color: const Color(0xFFCCCCCC),
          ),
          SizedBox(height: 16.h),
          Text(
            'No mask bar records yet',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF999999)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create mask bars to see them here',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFFCCCCCC)),
          ),
        ],
      ),
    );
  }

  Widget _buildMaskBarItem(dynamic maskBar, int index) {
    final String style = maskBar.style;
    final String color = maskBar.color;
    final int opacity = maskBar.opacity;
    final int createTime = maskBar.createTime;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(maskBar.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.delete, color: Colors.white, size: 24.w),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmDialog(maskBar.id);
        },
        onDismissed: (direction) {
          controller.deleteMaskBar(maskBar.id);
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [

              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
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
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20.w,
                      child: _buildMaskBarByStyle(style, color, opacity),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStyleName(style),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.palette,
                          size: 14.w,
                          color: const Color(0xFF999999),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          color,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF999999),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.opacity,
                          size: 14.w,
                          color: const Color(0xFF999999),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$opacity%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatTime(createTime),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 24.w),
                onPressed: () async {
                  final confirm = await _showDeleteConfirmDialog(maskBar.id);
                  if (confirm == true) {
                    controller.deleteMaskBar(maskBar.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaskBarByStyle(String style, String color, int opacity) {
    switch (style) {
      case 'solid':
        return Container(
          height: 16.h,
          color: Utils.hexToColor(color).withOpacity(opacity / 100),
        );
      case 'mosaic':
        return Container(
          height: 16.h,
          child: CustomPaint(
            painter: _MosaicPainter(
              baseColor: Utils.hexToColor(color),
              opacity: opacity / 100,
            ),
            child: Container(),
          ),
        );
      case 'blur':
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 16.h,
              color: Utils.hexToColor(color).withOpacity(opacity / 100 * 0.4),
            ),
          ),
        );
      default:
        return Container(
          height: 16.h,
          color: Utils.hexToColor(color).withOpacity(opacity / 100),
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

  String _formatTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<bool?> _showDeleteConfirmDialog(String id) {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this mask bar record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
    final random = [
      0.7,
      0.85,
      0.6,
      0.9,
      0.75,
      0.8,
      0.65,
      0.95,
    ];
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
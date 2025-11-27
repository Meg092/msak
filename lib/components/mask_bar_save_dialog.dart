import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MaskBarSaveDialog extends StatelessWidget {
  final Function(String)? onConfirm;

  const MaskBarSaveDialog({super.key, this.onConfirm});

  static void show({Function(String)? onConfirm}) {
    Get.dialog(
      MaskBarSaveDialog(onConfirm: onConfirm),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: '');

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  Text(
                    'Save Name',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 24.w,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: textController,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter name',
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFFCCCCCC),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    final name = textController.text.trim();
                    if (onConfirm != null) {
                      onConfirm!(name);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm',
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {
  static void successToast(String msg) {
    Get.snackbar(
      '',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      duration: const Duration(seconds: 1),
      titleText: const SizedBox.shrink(),
      messageText: Text(
        msg,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }

  static void errorToast(String msg) {
    Get.snackbar(
      '',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
      borderRadius: 8.r,
      duration: const Duration(seconds: 1),
      titleText: const SizedBox.shrink(),
      messageText: Text(
        msg,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
    );
  }

  static String formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
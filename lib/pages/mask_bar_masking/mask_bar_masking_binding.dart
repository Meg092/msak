import 'package:get/get.dart';
import 'mask_bar_masking_logic.dart';

class MaskBarMaskingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarMaskingLogic());
  }
}
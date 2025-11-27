import 'package:get/get.dart';
import 'mask_bar_crop_logic.dart';

class MaskBarCropBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarCropLogic());
  }
}
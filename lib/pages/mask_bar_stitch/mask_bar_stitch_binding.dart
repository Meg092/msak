import 'package:get/get.dart';
import 'mask_bar_stitch_logic.dart';

class MaskBarStitchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarStitchLogic());
  }
}
import 'package:get/get.dart';
import 'mask_bar_home_logic.dart';

class MaskBarHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarHomeLogic());
  }
}
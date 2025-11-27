import 'package:get/get.dart';
import 'mask_bar_edit_logic.dart';

class MaskBarEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarEditLogic());
  }
}
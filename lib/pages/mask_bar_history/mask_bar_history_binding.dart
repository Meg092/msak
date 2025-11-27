import 'package:get/get.dart';
import 'mask_bar_history_logic.dart';

class MaskBarHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarHistoryLogic());
  }
}
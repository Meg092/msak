import 'package:get/get.dart';
import 'mask_bar_record_logic.dart';

class MaskBarRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MaskBarRecordLogic());
  }
}
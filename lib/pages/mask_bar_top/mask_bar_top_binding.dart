import 'package:get/get.dart';

import 'mask_bar_top_logic.dart';

class MaskBarTopBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      MaskBarTopLogic(),
      permanent: true,
    );
  }
}

import 'package:get/get.dart';
import 'package:mask_bar/db_mask_bar/data.dart';
import 'package:mask_bar/db_mask_bar/db_mask_bar_entity.dart';
import 'package:mask_bar/utils/index.dart';

class MaskBarRecordLogic extends GetxController {
  final MaskBarDatabase _database = MaskBarDatabase();

  final RxList<MaskBarEntity> maskBarList = <MaskBarEntity>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMaskBarRecords();
  }

  Future<void> _loadMaskBarRecords() async {
    try {
      isLoading.value = true;
      final records = await _database.getMaskBarList(orderBy: 'time_desc');
      maskBarList.value = records;
    } catch (e) {
      Utils.errorToast('Failed to load records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMaskBar(String id) async {
    try {
      final result = await _database.deleteMaskBarById(id);
      if (result > 0) {
        maskBarList.removeWhere((item) => item.id == id);
        Utils.successToast('Deleted successfully');
      } else {
        Utils.errorToast('Failed to delete record');
      }
    } catch (e) {
      Utils.errorToast('Failed to delete: $e');
    }
  }
}
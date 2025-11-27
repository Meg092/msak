import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';

class MaskBarHistoryLogic extends GetxController {
  final historyList = <EditHistoryEntity>[].obs;

  final selectedType = 'all'.obs;
  final selectedTimeRange = 'all'.obs;
  final selectedSort = 'time_desc'.obs;

  final searchKeyword = ''.obs;
  final isSearching = false.obs;

  final isEditMode = false.obs;
  final selectedItems = <String>{}.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      isLoading.value = true;

      String? functionType = selectedType.value == 'all'
          ? null
          : selectedType.value;
      int? startTime;
      int? endTime = DateTime.now().millisecondsSinceEpoch;

      if (selectedTimeRange.value == 'today') {
        final today = DateTime.now();
        startTime = DateTime(
          today.year,
          today.month,
          today.day,
        ).millisecondsSinceEpoch;
      } else if (selectedTimeRange.value == 'week') {
        startTime = DateTime.now()
            .subtract(Duration(days: 7))
            .millisecondsSinceEpoch;
      } else if (selectedTimeRange.value == 'month') {
        startTime = DateTime.now()
            .subtract(Duration(days: 30))
            .millisecondsSinceEpoch;
      }

      final list = await MaskBarDatabase().getHistoryList(
        functionType: functionType,
        startTime: startTime,
        endTime: endTime,
        orderBy: selectedSort.value,
        searchKeyword: searchKeyword.value.isEmpty ? null : searchKeyword.value,
      );

      historyList.value = list;
    } catch (e) {
      Utils.errorToast('Failed to load history');
    } finally {
      isLoading.value = false;
    }
  }

  void selectType(String type) {
    selectedType.value = type;
    loadHistory();
  }

  void selectTimeRange(String range) {
    selectedTimeRange.value = range;
    loadHistory();
  }

  void selectSort(String sort) {
    selectedSort.value = sort;
    loadHistory();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchKeyword.value = '';
      loadHistory();
    }
  }

  void search(String keyword) {
    searchKeyword.value = keyword;
    loadHistory();
  }

  Future<void> deleteItem(EditHistoryEntity history) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Confirmation'),
        content: Text('Are you sure you want to delete "${history.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FileManager.deleteFile(history.filePath);
        await FileManager.deleteFile(history.thumbnail);

        await MaskBarDatabase().deleteHistoryById(history.id);

        Utils.successToast('Item deleted');
        await loadHistory();
      } catch (e) {
        Utils.errorToast('Failed to delete item');
      }
    }
  }

  Future<void> renameItem(EditHistoryEntity history) async {
    final TextEditingController controller = TextEditingController(
      text: history.fileName,
    );

    await Get.dialog(
      AlertDialog(
        title: Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                Utils.errorToast('Please enter a name');
                return;
              }

              try {
                history.fileName = name;
                await MaskBarDatabase().updateHistory(history);
                Get.back();
                Utils.successToast('Item renamed');
                await loadHistory();
              } catch (e) {
                Utils.errorToast('Failed to rename item');
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> saveToAlbum(EditHistoryEntity history) async {
    try {
      final file = File(history.filePath);
      if (!file.existsSync()) {
        Utils.errorToast('File not found');
        return;
      }

      final result = await ImageGallerySaver.saveFile(
        history.filePath,
        name: history.fileName,
      );

      if (result != null && result['isSuccess'] == true) {
        Utils.successToast('Saved to album');
      } else {
        Utils.errorToast('Failed to save to album');
      }
    } catch (e) {
      Utils.errorToast('Failed to save to album');
    }
  }

  Future<void> viewImage(EditHistoryEntity history) async {
    await Get.dialog(
      barrierColor: Colors.black.withOpacity(0.8),
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Image.file(File(history.filePath), fit: BoxFit.contain)],
        ),
      ),
    );
  }
}

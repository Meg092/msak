import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';
import 'mask_bar_history_logic.dart';

class MaskBarHistoryPage extends GetView<MaskBarHistoryLogic> {
  const MaskBarHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [

          Obx(
            () => controller.isSearching.value
                ? _buildSearchBar()
                : SizedBox.shrink(),
          ),

          _buildFilterSection(),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.historyList.isEmpty) {
                return _buildEmptyState();
              }

              return _buildHistoryList();
            }),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFF5F5F5),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text('Edit History', style: TextStyle(color: Colors.black)),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: controller.toggleSearch,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: TextField(
        autofocus: true,
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'Search by name...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.close),
            onPressed: controller.toggleSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [

          SizedBox(
            height: 36.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildFilterChip('All', 'all', controller.selectedType),
                _buildFilterChip('Mask', 'mask', controller.selectedType),
                _buildFilterChip('Stitch', 'stitch', controller.selectedType),
                _buildFilterChip('Crop', 'crop', controller.selectedType),
                _buildFilterChip('Edit', 'edit', controller.selectedType),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(child: _buildTimeDropdown()),
                SizedBox(width: 12.w),
                Expanded(child: _buildSortDropdown()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, RxString selected) {
    return Obx(() {
      final isSelected = selected.value == value;
      return GestureDetector(
        onTap: () => controller.selectType(value),
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF007AFF) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeDropdown() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedTimeRange.value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, size: 20.w),
            style: TextStyle(fontSize: 13.sp, color: Colors.black),
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Time')),
              DropdownMenuItem(value: 'today', child: Text('Today')),
              DropdownMenuItem(value: 'week', child: Text('Last 7 Days')),
              DropdownMenuItem(value: 'month', child: Text('Last 30 Days')),
            ],
            onChanged: (value) {
              if (value != null) controller.selectTimeRange(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedSort.value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, size: 20.w),
            style: TextStyle(fontSize: 13.sp, color: Colors.black),
            items: [
              DropdownMenuItem(value: 'time_desc', child: Text('Newest First')),
              DropdownMenuItem(value: 'time_asc', child: Text('Oldest First')),
              DropdownMenuItem(value: 'name', child: Text('By Name')),
            ],
            onChanged: (value) {
              if (value != null) controller.selectSort(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.historyList.length,
      itemBuilder: (context, index) {
        final item = controller.historyList[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(EditHistoryEntity item) {
    return Obx(() {
      final isSelected = controller.selectedItems.contains(item.id);
      return GestureDetector(
        onTap: () {
          controller.viewImage(item);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: controller.isEditMode.value && isSelected
                ? Border.all(color: Color(0xFF007AFF), width: 2)
                : null,
          ),
          child: Row(
            children: [

              if (controller.isEditMode.value) ...[
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Color(0xFF007AFF) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? Color(0xFF007AFF) : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.w)
                      : null,
                ),
                SizedBox(width: 12.w),
              ],

              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8.r),
                  image: File(item.thumbnail).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(item.thumbnail)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !File(item.thumbnail).existsSync()
                    ? Icon(Icons.broken_image, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    _buildTypeTag(item.functionType),
                    SizedBox(height: 6.h),
                    Text(
                      Utils.formatDateTime(item.createTime),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      FileManager.formatFileSize(item.fileSize),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      color: const Color(0xFF007AFF),
                      onPressed: () => controller.renameItem(item),
                    ),
                    SizedBox(height: 4.h),
                    _buildActionButton(
                      icon: Icons.download,
                      color: const Color(0xFF34C759),
                      onPressed: () => controller.saveToAlbum(item),
                    ),
                    SizedBox(height: 4.h),
                    _buildActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onPressed: () => controller.deleteItem(item),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, size: 18.w, color: color),
      ),
    );
  }

  Widget _buildTypeTag(String type) {
    Color color;
    String label;

    switch (type) {
      case 'mask':
        color = Colors.orange;
        label = 'Mask';
        break;
      case 'stitch':
        color = Colors.blue;
        label = 'Stitch';
        break;
      case 'crop':
        color = Colors.green;
        label = 'Crop';
        break;
      case 'edit':
        color = Colors.purple;
        label = 'Edit';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80.w, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No records found',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
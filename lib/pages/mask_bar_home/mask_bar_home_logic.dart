import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:mask_bar/db_mask_bar/index.dart';
import 'package:mask_bar/utils/index.dart';

class MaskBarHomeLogic extends GetxController {
  final maskStyle = 'solid'.obs;
  final maskColor = '#000000'.obs;
  final selectedOpacity = 80.obs;

  final _uuid = const Uuid();

  Future<void> onAddMaskBarTap() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maskBar = MaskBarEntity(
        id: _uuid.v4(),
        color: maskColor.value,
        opacity: selectedOpacity.value,
        style: maskStyle.value,
        createTime: now,
      );

      await MaskBarDatabase().insertMaskBar(maskBar);
      Utils.successToast('Mask bar added successfully');
    } catch (e) {
      Utils.errorToast('Failed to add mask bar');
    }
  }

  Future<void> onSelectMaskStyle() async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              'Select Mask Style',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _buildStyleOption('Solid Color', 'solid'),
            _buildStyleOption('Mosaic', 'mosaic'),
            _buildStyleOption('Blur', 'blur'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleOption(String title, String value) {
    return Obx(
      () => ListTile(
        title: Text(title),
        trailing: maskStyle.value == value
            ? Icon(Icons.check, color: Color(0xFF007AFF))
            : null,
        onTap: () async {
          Get.back();
          maskStyle.value = value;
        },
      ),
    );
  }

  Future<void> onSelectMaskColor() async {
    await Get.dialog(
      AlertDialog(
        title: Text('Select Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption('Black', '#000000'),
            _buildColorOption('White', '#FFFFFF'),
            _buildColorOption('Red', '#FF0000'),
            _buildColorOption('Green', '#00FF00'),
            _buildColorOption('Blue', '#0000FF'),
            _buildColorOption('Yellow', '#FFFF00'),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String name, String color) {
    return Obx(
      () => ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Utils.hexToColor(color),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        title: Text(name),
        trailing: maskColor.value == color
            ? Icon(Icons.check, color: Color(0xFF007AFF))
            : null,
        onTap: () async {
          Get.back();
          maskColor.value = color;
        },
      ),
    );
  }

  Future<void> onSelectOpacity() async {
    final tempOpacity = selectedOpacity.value.obs;
    await Get.dialog(
      AlertDialog(
        title: Text('Adjust Opacity'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: tempOpacity.value.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: '${tempOpacity.value}%',
                onChanged: (value) {
                  tempOpacity.value = value.toInt();
                },
              ),
              Text(
                '${tempOpacity.value}%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              selectedOpacity.value = tempOpacity.value;
              Get.back();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
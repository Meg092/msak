import 'db_mask_bar_entity.dart';

class FilterPresets {

  static List<FilterPresetEntity> getAllPresets() {
    return [

      FilterPresetEntity(
        id: 'original',
        name: 'Original',
        brightness: 0,
        contrast: 0,
        saturation: 0,
        sharpness: 0,
        temperature: 0,
      ),

      FilterPresetEntity(
        id: 'blackwhite',
        name: 'Black & White',
        brightness: 0,
        contrast: 0,
        saturation: -100,
        sharpness: 0,
        temperature: 0,
      ),

      FilterPresetEntity(
        id: 'vintage',
        name: 'Vintage',
        brightness: 0,
        contrast: 15,
        saturation: -20,
        sharpness: 0,
        temperature: 10,
      ),

      FilterPresetEntity(
        id: 'fresh',
        name: 'Fresh',
        brightness: 10,
        contrast: 5,
        saturation: 15,
        sharpness: 5,
        temperature: 0,
      ),

      FilterPresetEntity(
        id: 'cool',
        name: 'Cool Tone',
        brightness: 0,
        contrast: 10,
        saturation: 0,
        sharpness: 0,
        temperature: -30,
      ),

      FilterPresetEntity(
        id: 'warm',
        name: 'Warm Tone',
        brightness: 0,
        contrast: 0,
        saturation: 10,
        sharpness: 0,
        temperature: 30,
      ),
    ];
  }

  static FilterPresetEntity? getPresetById(String id) {
    try {
      return getAllPresets().firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  static int getPresetsCount() {
    return getAllPresets().length;
  }
}
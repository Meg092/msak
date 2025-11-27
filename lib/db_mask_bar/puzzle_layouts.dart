import 'db_mask_bar_entity.dart';

class PuzzleLayouts {

  static List<PuzzleLayoutEntity> getAllLayouts() {
    return [

      PuzzleLayoutEntity(
        typeId: 1,
        imageCount: 2,
        name: 'Top-Bottom Equal',
        iconPath: 'assets/puzzle_type/1.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 1, height: 0.5),
          LayoutSectionEntity(x: 0, y: 0.5, width: 1, height: 0.5),
        ],
      ),

      PuzzleLayoutEntity(
        typeId: 2,
        imageCount: 2,
        name: 'Left-Right Equal',
        iconPath: 'assets/puzzle_type/2.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 0.5, height: 1),
          LayoutSectionEntity(x: 0.5, y: 0, width: 0.5, height: 1),
        ],
      ),

      PuzzleLayoutEntity(
        typeId: 3,
        imageCount: 2,
        name: 'Top Large, Bottom Small',
        iconPath: 'assets/puzzle_type/3.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 1, height: 0.33),
          LayoutSectionEntity(x: 0, y: 0.33, width: 1, height: 0.67),
        ],
      ),

      PuzzleLayoutEntity(
        typeId: 4,
        imageCount: 2,
        name: 'Top Small, Bottom Large',
        iconPath: 'assets/puzzle_type/4.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 1, height: 0.67),
          LayoutSectionEntity(x: 0, y: 0.67, width: 1, height: 0.33),
        ],
      ),

      PuzzleLayoutEntity(
        typeId: 5,
        imageCount: 2,
        name: 'Left Large, Right Small',
        iconPath: 'assets/puzzle_type/5.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 0.33, height: 1),
          LayoutSectionEntity(x: 0.33, y: 0, width: 0.67, height: 1),
        ],
      ),

      PuzzleLayoutEntity(
        typeId: 6,
        imageCount: 2,
        name: 'Left Small, Right Large',
        iconPath: 'assets/puzzle_type/6.png',
        sections: [
          LayoutSectionEntity(x: 0, y: 0, width: 0.67, height: 1),
          LayoutSectionEntity(x: 0.67, y: 0, width: 0.33, height: 1),
        ],
      ),
    ];
  }

  static List<PuzzleLayoutEntity> getLayoutsByImageCount(int imageCount) {
    return getAllLayouts()
        .where((layout) => layout.imageCount == imageCount)
        .toList();
  }

  static PuzzleLayoutEntity? getLayoutById(int typeId) {
    try {
      return getAllLayouts().firstWhere((layout) => layout.typeId == typeId);
    } catch (e) {
      return null;
    }
  }

  static List<int> getSupportedImageCounts() {
    return [2];
  }

  static int getTotalLayoutsCount() {
    return getAllLayouts().length;
  }
}
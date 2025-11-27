
class MaskBarEntity {

  String id;

  String color;

  int opacity;

  String style;

  int createTime;

  MaskBarEntity({
    required this.id,
    required this.color,
    required this.opacity,
    required this.style,
    required this.createTime,
  });

  factory MaskBarEntity.fromMap(Map<String, dynamic> map) {
    return MaskBarEntity(
      id: map['id'] as String,
      color: map['color'] as String,
      opacity: map['opacity'] as int,
      style: map['style'] as String,
      createTime: map['create_time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color,
      'opacity': opacity,
      'style': style,
      'create_time': createTime,
    };
  }

  MaskBarEntity copyWith({
    String? id,
    String? color,
    int? opacity,
    String? style,
    int? createTime,
  }) {
    return MaskBarEntity(
      id: id ?? this.id,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      style: style ?? this.style,
      createTime: createTime ?? this.createTime,
    );
  }

  @override
  String toString() {
    return 'MaskBarEntity{id: $id, color: $color, opacity: $opacity, style: $style, createTime: $createTime}';
  }
}

class EditHistoryEntity {

  String id;

  String fileName;

  String filePath;

  String thumbnail;

  String functionType;

  int createTime;

  int fileSize;

  EditHistoryEntity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.thumbnail,
    required this.functionType,
    required this.createTime,
    required this.fileSize,
  });

  factory EditHistoryEntity.fromMap(Map<String, dynamic> map) {
    return EditHistoryEntity(
      id: map['id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      thumbnail: map['thumbnail'] as String,
      functionType: map['function_type'] as String,
      createTime: map['create_time'] as int,
      fileSize: map['file_size'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'thumbnail': thumbnail,
      'function_type': functionType,
      'create_time': createTime,
      'file_size': fileSize,
    };
  }

  EditHistoryEntity copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? thumbnail,
    String? functionType,
    int? createTime,
    int? fileSize,
  }) {
    return EditHistoryEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      thumbnail: thumbnail ?? this.thumbnail,
      functionType: functionType ?? this.functionType,
      createTime: createTime ?? this.createTime,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  String toString() {
    return 'EditHistoryEntity{id: $id, fileName: $fileName, functionType: $functionType, createTime: $createTime}';
  }
}

class FilterPresetEntity {

  String id;

  String name;

  double brightness;

  double contrast;

  double saturation;

  double sharpness;

  double temperature;

  FilterPresetEntity({
    required this.id,
    required this.name,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.sharpness,
    required this.temperature,
  });

  factory FilterPresetEntity.fromMap(Map<String, dynamic> map) {
    return FilterPresetEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      brightness: (map['brightness'] as num).toDouble(),
      contrast: (map['contrast'] as num).toDouble(),
      saturation: (map['saturation'] as num).toDouble(),
      sharpness: (map['sharpness'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'sharpness': sharpness,
      'temperature': temperature,
    };
  }

  @override
  String toString() {
    return 'FilterPresetEntity{id: $id, name: $name}';
  }
}

class LayoutSectionEntity {

  double x;

  double y;

  double width;

  double height;

  LayoutSectionEntity({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory LayoutSectionEntity.fromMap(Map<String, dynamic> map) {
    return LayoutSectionEntity(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }
}

class PuzzleLayoutEntity {

  int typeId;

  int imageCount;

  String name;

  String? iconPath;

  List<LayoutSectionEntity> sections;

  PuzzleLayoutEntity({
    required this.typeId,
    required this.imageCount,
    required this.name,
    this.iconPath,
    required this.sections,
  });

  factory PuzzleLayoutEntity.fromMap(Map<String, dynamic> map) {
    return PuzzleLayoutEntity(
      typeId: map['typeId'] as int,
      imageCount: map['imageCount'] as int,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String?,
      sections: (map['sections'] as List)
          .map((e) => LayoutSectionEntity.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'typeId': typeId,
      'imageCount': imageCount,
      'name': name,
      'iconPath': iconPath,
      'sections': sections.map((e) => e.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'PuzzleLayoutEntity{typeId: $typeId, name: $name, imageCount: $imageCount}';
  }
}
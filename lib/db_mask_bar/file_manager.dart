import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class FileManager {

  static Future<Directory> getAppDocDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> getAppCacheDirectory() async {
    return await getApplicationCacheDirectory();
  }

  static Future<Directory> getImageDirectory() async {
    final docDir = await getAppDocDirectory();
    final imageDir = Directory(path.join(docDir.path, 'MaskBar'));

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    return imageDir;
  }

  static Future<Directory> getThumbnailDirectory() async {
    final cacheDir = await getAppCacheDirectory();
    final thumbnailDir = Directory(path.join(cacheDir.path, 'thumbnails'));

    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }

    return thumbnailDir;
  }

  static Future<String> saveImage(Uint8List imageData, String fileName) async {
    final imageDir = await getImageDirectory();
    final filePath = path.join(imageDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(imageData);
    return filePath;
  }

  static Future<String> generateThumbnail(
    String imagePath, {
    int thumbnailSize = 120,
  }) async {
    try {

      final originalFile = File(imagePath);
      if (!await originalFile.exists()) {
        throw Exception('Original image file not found');
      }

      final imageData = await originalFile.readAsBytes();
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final thumbnail = img.copyResize(
        image,
        width: thumbnailSize,
        height: thumbnailSize,
        interpolation: img.Interpolation.linear,
      );

      final thumbnailDir = await getThumbnailDirectory();
      final fileName = path.basename(imagePath);
      final thumbnailFileName = 'thumb_$fileName';
      final thumbnailPath = path.join(thumbnailDir.path, thumbnailFileName);

      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 85));

      return thumbnailPath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      await deleteFile(filePath);
    }
  }

  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists() ? await file.length() : 0;
    } catch (e) {
      return 0;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String generateUniqueFileName({
    String extension = '.jpg',
    String prefix = '',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefixPart = prefix.isNotEmpty ? '${prefix}_' : '';
    return '$prefixPart$timestamp$extension';
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PersistenceService {
  PersistenceService._();
  static final PersistenceService instance = PersistenceService._();

  static const String _folderName = 'cache_data';

  Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _folderName);
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(path, '$fileName.json'));
  }

  Future<void> saveData(String key, dynamic data) async {
    try {
      final file = await _getFile(key);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error saving data to $key: $e');
    }
  }

  Future<dynamic> loadData(String key) async {
    try {
      final file = await _getFile(key);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      print('Error loading data from $key: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path, _folderName);
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

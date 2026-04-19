import 'dart:convert';
import 'package:core_storage/core_storage.dart';
import 'package:eval_bridge/eval_bridge.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import '../sources/sources.dart';

class DynamicSourceManager {
  final FilePickerUseCase _filePicker;
  final GetRootPathUseCase _rootPath;

  DynamicSourceManager(this._filePicker, this._rootPath);

  Future<SourceExternal?> importSource() async {
    final bytes = await _filePicker.execute(allowedExtensions: ['dart']);
    if (bytes == null) return null;

    final sourceCode = utf8.decode(bytes);
    
    try {
      final dynamicSource = EvalBridge.loadSource(sourceCode);
      
      // In a real app, we would save 'sourceCode' to a file in _rootPath.rootPath/providers/
      // and reload it on startup. For PoC, we just return the instance.
      
      Sources.values.add(dynamicSource);
      return dynamicSource;
    } catch (e) {
      print('Failed to load dynamic source: $e');
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AIModelService extends ChangeNotifier {
  // Singleton Pattern
  static final AIModelService instance = AIModelService._internal();
  factory AIModelService() => instance;
  AIModelService._internal();

  // State variables
  bool _isDownloaded = false;
  String? _modelPath;
  
  // Constants
  static const String _fileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';

  // Getters
  bool get isDownloaded => _isDownloaded;
  String? get modelPath => _modelPath;

  /// Call this in your main.dart before running the app
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${dir.path}/models');
      
      // Ensure directory exists
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      
      _modelPath = '${modelDir.path}/$_fileName';

      // Check if file exists
      if (await File(_modelPath!).exists()) {
        _isDownloaded = true;
      } else {
        _isDownloaded = false;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing AI Service: $e");
    }
  }

  /// Returns the full target path for the download
  Future<String> getTargetFilePath() async {
    if (_modelPath != null) return _modelPath!;
    // Fallback initialization if needed
    await init();
    return _modelPath!;
  }

  void setDownloadComplete() {
    _isDownloaded = true;
    notifyListeners();
  }

  void setDeleted() {
    _isDownloaded = false;
    notifyListeners();
  }
}
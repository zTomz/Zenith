import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'ai_model_service.dart';

class LocalLLMService {
  LlamaController? _llama;
  bool _isModelLoaded = false;

  bool get isLoaded => _isModelLoaded;

  /// Loads the model using llama_flutter_android
  Future<void> loadModel() async {
    final path = AIModelService.instance.modelPath;

    if (path == null || path.isEmpty) {
      throw Exception("Model path is empty. Please download the model first.");
    }

    try {
      _llama = LlamaController();

      // Load the model
      await _llama?.loadModel(modelPath: path);

      _isModelLoaded = true;
      debugPrint("✅ Local LLM loaded successfully.");
    } catch (e) {
      debugPrint("❌ Error loading LLM: $e");
      _isModelLoaded = false;
      rethrow;
    }
  }

  void dispose() {
    _llama?.dispose();
    _llama = null;
    _isModelLoaded = false;
    debugPrint("🗑️ Local LLM disposed.");
  }

  // ===========================================================================
  // USE CASES
  // ===========================================================================

  Stream<String> streamAsk(String question, {String? context}) {
    final systemPrompt =
        "You are a helpful, concise, and intelligent assistant for a notes app.${context != null ? '\n\nContext:\n$context' : ''}";
    return _generateStream(systemPrompt, question);
  }

  Stream<String> streamSummarize(String text) {
    const systemPrompt =
        "You are an expert summarizer. "
        "Read the following text and create a concise summary using bullet points. "
        "Focus on the key facts and ignore filler words. "
        "Do not include an intro or outro, just the summary.";
    return _generateStream(systemPrompt, text);
  }

  Stream<String> streamRewrite(
    String text, {
    String style = "professional and clear",
  }) {
    final systemPrompt =
        "You are a professional editor. "
        "Rewrite the user's text to be more $style. "
        "Fix any grammar or spelling mistakes. "
        "Keep the original meaning but make it flow better.";
    return _generateStream(systemPrompt, text);
  }

  Stream<String> streamBrainDump(String chaoticText) {
    const systemPrompt =
        "You are an organizational expert. "
        "The user will provide a 'brain dump' of unstructured thoughts, tasks, and ideas. "
        "Your job is to structure this into a clear, logical format. "
        "Group related items, extract actionable tasks, and give it a clean structure.";
    return _generateStream(systemPrompt, chaoticText);
  }

  Stream<String> streamGenerateTitle(String noteContent) {
    const systemPrompt =
        "You are a title generation expert. "
        "Read the user's note content and generate a concise, descriptive title. "
        "The title should be 3-7 words maximum, capture the main topic or purpose, "
        "and be clear and direct. Do not use quotes, prefixes like 'Title:', or any special formatting. "
        "Just output the title text itself.";
    return _generateStream(systemPrompt, noteContent);
  }

  // ===========================================================================
  // INTERNAL HELPER
  // ===========================================================================

  Stream<String> _generateStream(String systemRole, String userMessage) async* {
    if (_llama == null || !_isModelLoaded) {
      yield "⚠️ Error: Model not loaded.";
      return;
    }

    // ChatML Format
    final formattedPrompt =
        "<|im_start|>system\n$systemRole<|im_end|>\n"
        "<|im_start|>user\n$userMessage<|im_end|>\n"
        "<|im_start|>assistant\n";

    try {
      // generate returns a Stream<String>
      final stream = _llama?.generate(prompt: formattedPrompt);

      if (stream != null) {
        yield* stream;
      }
    } catch (e) {
      yield "Error generating response: $e";
    }
  }
}

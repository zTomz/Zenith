import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:zenith/services/ai_model_service.dart';
import 'package:zenith/services/local_llm_service.dart';

/// Horizontal scrolling list of AI action buttons
class AiActionButtons extends StatelessWidget {
  final LocalLLMService llmService;
  final VoidCallback onSummarize;
  final VoidCallback onAsk;
  final VoidCallback onRewrite;
  final VoidCallback onBrainDump;
  final VoidCallback onGenerateTitle;

  const AiActionButtons({
    super.key,
    required this.llmService,
    required this.onSummarize,
    required this.onAsk,
    required this.onRewrite,
    required this.onBrainDump,
    required this.onGenerateTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isModelDownloaded = AIModelService.instance.isDownloaded;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FButton(
            onPress: isModelDownloaded ? onSummarize : null,
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.scanText),
            child: const Text('Summarize'),
          ),
          const SizedBox(width: 8),
          FButton(
            onPress: isModelDownloaded ? onAsk : null,
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.fileQuestionMark),
            child: const Text('Ask'),
          ),
          const SizedBox(width: 8),
          FButton(
            onPress: isModelDownloaded ? onRewrite : null,
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.wandSparkles),
            child: const Text('Rewrite'),
          ),
          const SizedBox(width: 8),
          FButton(
            onPress: isModelDownloaded ? onBrainDump : null,
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.mic),
            child: const Text('Brain Dump'),
          ),
          const SizedBox(width: 8),
          FButton(
            onPress: isModelDownloaded ? onGenerateTitle : null,
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.sparkles),
            child: const Text('Generate Title'),
          ),
        ],
      ),
    );
  }
}

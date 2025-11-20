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
  final bool isEnabled;

  const AiActionButtons({
    super.key,
    required this.llmService,
    required this.onSummarize,
    required this.onAsk,
    required this.onRewrite,
    required this.onBrainDump,
    required this.onGenerateTitle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isModelDownloaded = AIModelService.instance.isDownloaded;

    return Wrap(
      direction: .horizontal,
      alignment: .start,
      runSpacing: 8,
      spacing: 8,
      children: [
        FButton(
          onPress: isModelDownloaded && isEnabled ? onSummarize : null,
          mainAxisSize: .min,
          style: FButtonStyle.outline(),
          prefix: Icon(FIcons.scanText),
          child: const Text('Summarize'),
        ),
        FButton(
          onPress: isModelDownloaded && isEnabled ? onAsk : null,
          mainAxisSize: .min,
          style: FButtonStyle.outline(),
          prefix: Icon(FIcons.fileQuestionMark),
          child: const Text('Ask'),
        ),
        FButton(
          onPress: isModelDownloaded && isEnabled ? onRewrite : null,
          mainAxisSize: .min,
          style: FButtonStyle.outline(),
          prefix: Icon(FIcons.wandSparkles),
          child: const Text('Rewrite'),
        ),
        FButton(
          onPress: isModelDownloaded && isEnabled ? onBrainDump : null,
          mainAxisSize: .min,
          style: FButtonStyle.outline(),
          prefix: Icon(FIcons.mic),
          child: const Text('Brain Dump'),
        ),
        FButton(
          onPress: isModelDownloaded && isEnabled ? onGenerateTitle : null,
          mainAxisSize: .min,
          style: FButtonStyle.outline(),
          prefix: Icon(FIcons.sparkles),
          child: const Text('Generate Title'),
        ),
      ],
    );
  }
}

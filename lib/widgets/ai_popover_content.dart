import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:zenith/widgets/ai_action_buttons.dart';
import 'package:zenith/services/ai_model_service.dart';
import 'package:zenith/services/local_llm_service.dart';

/// Content widget for the AI popover
class AiPopoverContent extends StatelessWidget {
  final LocalLLMService llmService;
  final bool isModelLoaded;
  final String generatedText;
  final bool isGenerating;
  final String statusMessage;
  final VoidCallback onSummarize;
  final VoidCallback onAsk;
  final VoidCallback onRewrite;
  final VoidCallback onBrainDump;
  final VoidCallback onGenerateTitle;

  const AiPopoverContent({
    super.key,
    required this.llmService,
    required this.isModelLoaded,
    required this.generatedText,
    required this.isGenerating,
    required this.statusMessage,
    required this.onSummarize,
    required this.onAsk,
    required this.onRewrite,
    required this.onBrainDump,
    required this.onGenerateTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      width: 400,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // AI action buttons
          AiActionButtons(
            llmService: llmService,
            onSummarize: onSummarize,
            onAsk: onAsk,
            onRewrite: onRewrite,
            onBrainDump: onBrainDump,
            onGenerateTitle: onGenerateTitle,
            isEnabled: isModelLoaded,
          ),

          // Loading indicator
          if (isGenerating)
            Row(
              children: [
                const SizedBox(width: 8),
                FCircularProgress.loader(),
                const SizedBox(width: 8),
                Text(statusMessage),
              ],
            ),

          // Model download alert
          if (!AIModelService.instance.isDownloaded)
            FAlert(
              title: const Text('Heads Up!'),
              subtitle: const Text(
                'You need to download the Zenith AI local model to use AI features. Go to Settings to download it.',
              ),
            )
          else if (!isModelLoaded)
            FAlert(
              title: const Text('Model Loading...'),
              subtitle: const Text(
                'Please wait while the AI model initializes. This may take a moment.',
              ),
            ),

          // Generated text result
          if (generatedText.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: FCard(
                title: const Text('AI Result'),
                child: Text(generatedText),
              ),
            ),
        ],
      ),
    );
  }
}

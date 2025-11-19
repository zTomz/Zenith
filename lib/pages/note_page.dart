import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/services/ai_model_service.dart';
import 'package:zenith/services/local_llm_service.dart';

class NotePage extends StatefulWidget {
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  late final QuillController _controller;
  late final TextEditingController _titleController;

  final _llmService = LocalLLMService();
  final ValueNotifier<String> _generatedText = ValueNotifier("");
  final ValueNotifier<bool> _isGenerating = ValueNotifier(false);
  bool _isModelReady = false;
  final ValueNotifier<String> _statusMessage = ValueNotifier(
    "Initializing AI Model...",
  );

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    if (widget.note != null) {
      // If a note is passed, load its content into the controller.
      // Assuming content is a JSON string.
      final doc = Document.fromJson(jsonDecode(widget.note!.content));
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      // Otherwise, create a new empty controller.
      _controller = QuillController.basic();
    }

    _initModel();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    _llmService.dispose();
    _generatedText.dispose();
    _isGenerating.dispose();
    _statusMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(_generatedText.value);

    return FScaffold(
      header: FHeader.nested(
        title: Text(widget.note != null ? "Edit Note" : "Create Note"),
        prefixes: [
          FHeaderAction.back(
            onPress: () async {
              if (_controller.document.toPlainText().trim().isEmpty &&
                  _titleController.text.trim().isEmpty) {
                log("Note is empty, not saving.");

                if (context.mounted) {
                  context.pop();
                }
                return;
              }

              Note note;

              if (widget.note != null) {
                // Update existing note
                note = widget.note!;
                note.title = _titleController.text.trim().isEmpty
                    ? null
                    : _titleController.text.trim();
                note.content = jsonEncode(
                  _controller.document.toDelta().toJson(),
                );
              } else {
                // Create new note
                note = .create(
                  title: _titleController.text.trim().isEmpty
                      ? null
                      : _titleController.text.trim(),
                  content: jsonEncode(_controller.document.toDelta().toJson()),
                );
              }

              await notesBox.put(note.id, note);

              if (context.mounted) {
                context.pop();
              }
            },
          ),
        ],
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.search),
            onPress: () async {
              await showDialog<String>(
                context: context,
                builder: (_) =>
                    QuillToolbarSearchDialog(controller: _controller),
              );
            },
          ),
          FPopover(
            popoverBuilder: (context, controller) => ValueListenableBuilder(
              valueListenable: _generatedText,
              builder: (context, generatedText, _) => ValueListenableBuilder(
                valueListenable: _isGenerating,
                builder: (context, isGenerating, _) => ValueListenableBuilder(
                  valueListenable: _statusMessage,
                  builder: (context, statusMessage, _) => Container(
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
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              FButton(
                                onPress: AIModelService.instance.isDownloaded
                                    ? () => _runAiTask(
                                        _llmService.streamSummarize,
                                      )
                                    : null,
                                style: FButtonStyle.outline(),
                                prefix: Icon(FIcons.scanText),
                                child: const Text('Summarize'),
                              ),
                              const SizedBox(width: 8),
                              FButton(
                                onPress: AIModelService.instance.isDownloaded
                                    ? _showAskDialog
                                    : null,
                                style: FButtonStyle.outline(),
                                prefix: Icon(FIcons.fileQuestionMark),
                                child: const Text('Ask'),
                              ),
                              const SizedBox(width: 8),
                              FButton(
                                onPress: AIModelService.instance.isDownloaded
                                    ? () => _runAiTask(
                                        (text) =>
                                            _llmService.streamRewrite(text),
                                      )
                                    : null,
                                style: FButtonStyle.outline(),
                                prefix: Icon(FIcons.wandSparkles),
                                child: const Text('Rewrite'),
                              ),
                              const SizedBox(width: 8),
                              FButton(
                                onPress: AIModelService.instance.isDownloaded
                                    ? () => _runAiTask(
                                        _llmService.streamBrainDump,
                                      )
                                    : null,
                                style: FButtonStyle.outline(),
                                prefix: Icon(FIcons.mic),
                                child: const Text('Brain Dump'),
                              ),
                            ],
                          ),
                        ),
                        if (isGenerating)
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              FCircularProgress.loader(),
                              const SizedBox(width: 8),
                              Text(statusMessage),
                            ],
                          ),
                        if (!AIModelService.instance.isDownloaded)
                          FAlert(
                            title: const Text('Heads Up!'),
                            subtitle: const Text(
                              'You need to download the Zenith AI local model to use AI features. Go to Settings to download it.',
                            ),
                          ),

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
                  ),
                ),
              ),
            ),
            builder: (context, controller, _) => FHeaderAction(
              icon: Icon(FIcons.bot),
              onPress: () async {
                controller.toggle();
              },
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            // TODO: Maybe make them configurable in the settings
            config: const QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
              showFontSize: false,
              showFontFamily: false,
              showBackgroundColorButton: false,
              showCodeBlock: false,
              showInlineCode: false,
              showAlignmentButtons: false,
              showCenterAlignment: false,
              showQuote: false,
              showIndent: false,
              showUndo: false,
              showRedo: false,
              // showColorButton: false,
              showSearchButton: false,
              showStrikeThrough: false,
              showSubscript: false,
              showSuperscript: false,
              showClearFormat: false,
              showItalicButton: false,
              showUnderLineButton: false,
            ),
          ),
          Material(
            child: TextField(
              controller: _titleController,
              style: context.theme.cardStyle.contentStyle.titleTextStyle,
              decoration: InputDecoration.collapsed(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: context.theme.cardStyle.contentStyle.titleTextStyle
                    .copyWith(
                      color: context.theme.textFieldStyle.hintTextStyle.resolve(
                        {WidgetState.hovered},
                      ).color,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              config: const QuillEditorConfig(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initModel() async {
    try {
      await _llmService.loadModel();
      if (mounted) setState(() => _isModelReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler: $e")));
      }
    }
  }

  /// Executes the selected AI task on the note content
  void _runAiTask(Stream<String> Function(String) taskFunction) {
    // Prevent running if already busy or model not ready
    if (_isGenerating.value || !_isModelReady) return;

    setState(() {
      _isGenerating.value = true;
      _generatedText.value = ""; // Clear previous result
      _statusMessage.value = "Thinking...";
    });

    // Start the stream
    taskFunction(_controller.document.toPlainText()).listen(
      (token) {
        if (mounted) {
          setState(() {
            _generatedText.value += token;
            _statusMessage.value = "Generating...";
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isGenerating.value = false;
            _statusMessage.value = "Finished";
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _statusMessage.value = "Error: $e";
            _isGenerating.value = false;
          });
        }
      },
    );
  }

  /// Helper method to copy generated text to clipboard
  // void _copyToClipboard() {
  //   if (_generatedText.isNotEmpty) {
  //     Clipboard.setData(ClipboardData(text: _generatedText));
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Copied result to clipboard")),
  //     );
  //   }
  // }

  Future<void> _showAskDialog() async {
    final questionController = TextEditingController();
    final question = await showDialog<String>(
      context: context,
      builder: (context) => FDialog(
        title: const Text("Ask AI"),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ask a question about this note:"),
            const SizedBox(height: 10),
            FTextField(
              controller: questionController,
              hint: "What is the main topic?",
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          FButton(
            onPress: () => Navigator.pop(context),
            style: FButtonStyle.outline(),
            child: const Text("Cancel"),
          ),
          FButton(
            onPress: () => Navigator.pop(context, questionController.text),
            child: const Text("Ask"),
          ),
        ],
      ),
    );

    if (question != null && question.isNotEmpty) {
      _runAiTask(
        (content) => _llmService.streamAsk(question, context: content),
      );
    }
  }
}

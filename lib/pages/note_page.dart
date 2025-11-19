import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/widgets/ai_popover_content.dart';
import 'package:zenith/services/local_llm_service.dart';

class NotePage extends StatefulWidget {
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  // ========================================
  // Controllers
  // ========================================
  late final QuillController _controller;
  late final TextEditingController _titleController;

  // ========================================
  // AI State Management
  // ========================================
  final _llmService = LocalLLMService();
  final ValueNotifier<String> _generatedText = ValueNotifier("");
  final ValueNotifier<bool> _isGenerating = ValueNotifier(false);
  final ValueNotifier<String> _statusMessage = ValueNotifier(
    "Initializing AI Model...",
  );
  bool _isModelReady = false;

  // ========================================
  // Lifecycle Methods
  // ========================================
  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    if (widget.note != null) {
      // Load existing note content
      final doc = Document.fromJson(jsonDecode(widget.note!.content));
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      // Create new empty note
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

  // ========================================
  // Build Method
  // ========================================
  @override
  Widget build(BuildContext context) {
    return FScaffold(header: _buildHeader(), child: _buildBody());
  }

  /// Builds the header with navigation and actions
  FHeader _buildHeader() {
    return FHeader.nested(
      title: Text(widget.note != null ? "Edit Note" : "Create Note"),
      prefixes: [FHeaderAction.back(onPress: _handleBackAction)],
      suffixes: [_buildSearchAction(), _buildAiPopover()],
    );
  }

  /// Builds the search action button
  FHeaderAction _buildSearchAction() {
    return FHeaderAction(
      icon: Icon(FIcons.search),
      onPress: () async {
        await showDialog<String>(
          context: context,
          builder: (_) => QuillToolbarSearchDialog(controller: _controller),
        );
      },
    );
  }

  /// Builds the AI popover with all AI features
  Widget _buildAiPopover() {
    return FPopover(
      popoverBuilder: (context, controller) => ValueListenableBuilder(
        valueListenable: _generatedText,
        builder: (context, generatedText, _) => ValueListenableBuilder(
          valueListenable: _isGenerating,
          builder: (context, isGenerating, _) => ValueListenableBuilder(
            valueListenable: _statusMessage,
            builder: (context, statusMessage, _) => AiPopoverContent(
              llmService: _llmService,
              generatedText: generatedText,
              isGenerating: isGenerating,
              statusMessage: statusMessage,
              onSummarize: () => _runAiTask(_llmService.streamSummarize),
              onAsk: _showAskDialog,
              onRewrite: () =>
                  _runAiTask((text) => _llmService.streamRewrite(text)),
              onBrainDump: () => _runAiTask(_llmService.streamBrainDump),
              onGenerateTitle: _generateTitle,
            ),
          ),
        ),
      ),
      builder: (context, controller, _) =>
          FHeaderAction(icon: Icon(FIcons.bot), onPress: controller.toggle),
    );
  }

  /// Builds the main body with toolbar and editor
  Widget _buildBody() {
    return Column(
      children: [
        _buildToolbar(),
        _buildTitleField(),
        const SizedBox(height: 8),
        _buildEditor(),
      ],
    );
  }

  /// Builds the Quill toolbar
  Widget _buildToolbar() {
    return QuillSimpleToolbar(
      controller: _controller,
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
        showSearchButton: false,
        showStrikeThrough: false,
        showSubscript: false,
        showSuperscript: false,
        showClearFormat: false,
        showItalicButton: false,
        showUnderLineButton: false,
      ),
    );
  }

  /// Builds the title text field
  Widget _buildTitleField() {
    return Material(
      child: TextField(
        controller: _titleController,
        style: context.theme.cardStyle.contentStyle.titleTextStyle,
        decoration: InputDecoration.collapsed(
          hintText: 'Title',
          border: InputBorder.none,
          hintStyle: context.theme.cardStyle.contentStyle.titleTextStyle
              .copyWith(
                color: context.theme.textFieldStyle.hintTextStyle.resolve({
                  WidgetState.hovered,
                }).color,
              ),
        ),
      ),
    );
  }

  /// Builds the Quill editor
  Widget _buildEditor() {
    return Expanded(
      child: QuillEditor.basic(
        controller: _controller,
        config: const QuillEditorConfig(),
      ),
    );
  }

  // ========================================
  // Note Management Methods
  // ========================================

  /// Handles the back button action - saves the note if not empty
  Future<void> _handleBackAction() async {
    if (_controller.document.toPlainText().trim().isEmpty &&
        _titleController.text.trim().isEmpty) {
      log("Note is empty, not saving.");
      if (context.mounted) context.pop();
      return;
    }

    Note note;

    if (widget.note != null) {
      // Update existing note
      note = widget.note!;
      note.title = _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim();
      note.content = jsonEncode(_controller.document.toDelta().toJson());
    } else {
      // Create new note
      note = Note.create(
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        content: jsonEncode(_controller.document.toDelta().toJson()),
      );
    }

    await notesBox.put(note.id, note);

    if (context.mounted) context.pop();
  }

  // ========================================
  // AI Methods
  // ========================================

  /// Initializes the AI model
  Future<void> _initModel() async {
    try {
      await _llmService.loadModel();
      if (mounted) setState(() => _isModelReady = true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// Executes the selected AI task on the note content
  void _runAiTask(Stream<String> Function(String) taskFunction) {
    // Prevent running if already busy or model not ready
    if (_isGenerating.value || !_isModelReady) return;

    setState(() {
      _isGenerating.value = true;
      _generatedText.value = "";
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

  /// Shows a dialog to ask the AI a question about the note
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

  /// Generates a title for the note based on its content
  void _generateTitle() {
    // Prevent running if already busy or model not ready
    if (_isGenerating.value || !_isModelReady) return;

    final noteContent = _controller.document.toPlainText().trim();
    if (noteContent.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Note content is empty")));
      return;
    }

    setState(() {
      _isGenerating.value = true;
      _statusMessage.value = "Generating title...";
    });

    // Clear the current generated text (not showing it for title generation)
    String generatedTitle = "";

    // Start the stream
    _llmService
        .streamGenerateTitle(noteContent)
        .listen(
          (token) {
            if (mounted) {
              generatedTitle += token;
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                // Set the generated title in the title field
                _titleController.text = generatedTitle.trim();
                _isGenerating.value = false;
                _statusMessage.value = "Title generated";
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
}

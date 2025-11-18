import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/services/ai_model_service.dart';

class NotePage extends StatefulWidget {
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  late final QuillController _controller;
  late final TextEditingController _titleController;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            popoverBuilder: (context, controller) => Container(
              width: 300,
              padding: .all(8),
              child: Column(
                spacing: 8,
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: .horizontal,
                      children: [
                        FButton(
                          onPress: AIModelService.instance.isDownloaded ? () {} : null,
                          style: FButtonStyle.outline(),
                          prefix: Icon(FIcons.scanText),
                          child: const Text('Summarize'),
                        ),
                        const SizedBox(width: 8),
                        FButton(
                          onPress: AIModelService.instance.isDownloaded ? () {} : null,
                          style: FButtonStyle.outline(),
                          prefix: Icon(FIcons.fileQuestionMark),
                          child: const Text('Ask'),
                        ),
                        const SizedBox(width: 8),
                        FButton(
                          onPress: AIModelService.instance.isDownloaded ? () {} : null,
                          style: FButtonStyle.outline(),
                          prefix: Icon(FIcons.wandSparkles),
                          child: const Text('Rewrite'),
                        ),
                        const SizedBox(width: 8),
                        FButton(
                          onPress: AIModelService.instance.isDownloaded ? () {} : null,
                          style: FButtonStyle.outline(),
                          prefix: Icon(FIcons.mic),
                          child: const Text('Brain Dump'),
                        ),
                      ],
                    ),
                  ),
                  if (!AIModelService.instance.isDownloaded)
                    FAlert(
                      title: const Text('Heads Up!'),
                      subtitle: const Text(
                        'You need to download the Zenith AI local model to use AI features. Go to Settings to download it.',
                      ),
                    ),
                ],
              ),
            ),
            // popoverBuilder: (context, controller) => Padding(
            //   padding: const EdgeInsets.only(
            //     left: 20,
            //     top: 14,
            //     right: 20,
            //     bottom: 10,
            //   ),
            //   child: SizedBox(
            //     width: 288,
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         FTileGroup(
            //           label: const Text('Zenith AI'),
            //           children: [
            //             FTile(
            //               prefix: Icon(FIcons.scanText),
            //               title: const Text('Summarize'),
            //               onPress: () {},
            //             ),
            //             FTile(
            //               prefix: Icon(FIcons.wandSparkles),
            //               title: const Text('Rewrite'),
            //               onPress: () {},
            //             ),
            //             FTile(
            //               prefix: Icon(FIcons.mic),
            //               title: const Text('Brain Dump'),
            //               onPress: () {},
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
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
}

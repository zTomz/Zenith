import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:zenith/models/note.dart';

class NotePage extends StatefulWidget {
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // If a note is passed, load its content into the controller.
      // Assuming content is a JSON string.
      final doc = Document.fromJson(jsonDecode(widget.note!.content));
      _controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
    } else {
      // Otherwise, create a new empty controller.
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text(widget.note != null ? "Edit Note" : "Create Note"),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.search),
            onPress: () async {
              // TODO: Implement search button
              await showDialog<String>(
                context: context,
                builder: (_) =>
                    QuillToolbarSearchDialog(controller: _controller),
              );
            },
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
              // TODO: Implement search button
              showSearchButton: false,
              showStrikeThrough: false,
              showSubscript: false,
              showSuperscript: false,
              showClearFormat: false,
              showItalicButton: false,
              showUnderLineButton: false,
            ),
          ),
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

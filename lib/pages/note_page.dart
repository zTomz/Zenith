import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class NotePage extends StatefulWidget {
  final String? noteId;

  const NotePage({super.key, this.noteId});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const FTextField(hint: "Title"),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [FHeaderAction(icon: Icon(FIcons.info), onPress: () {})],
      ),
      child: Text(
        "Note Page${widget.noteId != null ? ' - ${widget.noteId}' : ''}",
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/widgets/note_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    // Add some sample notes with varying lengths to demonstrate dynamic heights
    notes.addAll(<Note>[
      .create(
        title: "Meeting notes",
        content:
            "Meeting notes:\n- Discuss roadmap\n- Assign tasks\n- Follow up on PRs",
      ),
      .create(content: "I need to go for a walk today"),
      .create(content: "I need to go for a walk today"),
      .create(content: "I need to go for a walk today", title: "Walk notes"),
    ]);
  }

  void _addNote() {
    final newNote = Note(
      id: const Uuid().v4(),
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() => notes.insert(0, newNote));
    // Optionally navigate to edit the note
    context.pushNamed('note', extra: newNote);
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Your Notes'),
        suffixes: [
          FButton.icon(
            onPress: () {
              // Implement search functionality
            },
            style: FButtonStyle.ghost(),
            child: Icon(FIcons.search),
          ),
          FButton.icon(
            onPress: () {
              // Implement filter functionality
            },
            style: FButtonStyle.ghost(),
            child: Icon(FIcons.listFilter),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () => context.pushNamed('note', extra: note),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FButton(
              onPress: _addNote,
              style: FButtonStyle.outline(),
              prefix: Icon(FIcons.plus),
              child: Text("Add note"),
            ),
          ),
        ],
      ),
    );
  }
}

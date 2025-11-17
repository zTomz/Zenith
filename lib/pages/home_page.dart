import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zenith/hive/boxes.dart';
import 'package:zenith/widgets/note_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            child: StreamBuilder(
              initialData: notesBox.values.toList(),
              stream: notesBox.watch(),
              builder: (context, asyncSnapshot) {
                // if (asyncSnapshot.connectionState == ConnectionState.active) {
                //   log("Loading notes...");

                //   return Column(
                //     crossAxisAlignment: .center,
                //     mainAxisAlignment: .center,
                //     spacing: 4,
                //     children: [
                //       FCircularProgress.loader(),
                //       Text(
                //         "Loading notes...",
                //         style: context
                //             .theme
                //             .cardStyle
                //             .contentStyle
                //             .subtitleTextStyle,
                //       ),
                //     ],
                //   );
                // }

                if (asyncSnapshot.hasError) {
                  log("Error loading notes: ${asyncSnapshot.error}");

                  return Center(
                    child: FAlert(
                      title: const Text('Heads Up!'),
                      subtitle: const Text(
                        'There was an error loading your notes. Please try again by reopening the app.',
                      ),
                      style: FAlertStyle.destructive(),
                    ),
                  );
                }

                final notes = notesBox.values.toList();

                return MasonryGridView.count(
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FButton(
              onPress: () => context.pushNamed('note'),
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

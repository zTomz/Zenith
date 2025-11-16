import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          Expanded(child: Text("Home Page")),
          FButton(
            onPress: () {
              // Generate a new note ID and navigate to NotePage
              const uuid = Uuid();
              final noteId = uuid.v4();
              context.push('/note?noteId=$noteId');
            },
            style: FButtonStyle.outline(),
            prefix: Icon(FIcons.plus),
            child: Text("Add note"),
          ),
        ],
      ),
    );
  }
}

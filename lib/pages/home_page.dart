import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

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
              // Create a new note and navigate to NotePage

              context.pushNamed('note', extra: null);
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

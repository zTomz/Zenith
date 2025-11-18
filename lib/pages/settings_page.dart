import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zenith/widgets/download_ai_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(title: Text("Settings")),
      child: Align(
        alignment: .topCenter,
        child: FTileGroup(
          children: [
            DownloadAiTile(),
            FTile(
              prefix: Icon(FIcons.eraser),
              title: const Text('Delete Everything'),
              onPress: () async {
                final appDocDir = await getApplicationDocumentsDirectory();

                appDocDir
                    .delete(recursive: true)
                    .then((_) {
                      log("Application documents directory deleted.");
                    })
                    .catchError((error) {
                      log(
                        "Error deleting application documents directory: $error",
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}

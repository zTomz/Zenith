import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zenith/services/settings_service.dart';
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
              prefix: const Icon(FIcons.moon),
              title: const Text('Appearance'),
              subtitle: ValueListenableBuilder<ThemeMode>(
                valueListenable: SettingsService.instance.themeMode,
                builder: (context, mode, child) {
                  switch (mode) {
                    case ThemeMode.light:
                      return const Text('Light');
                    case ThemeMode.dark:
                      return const Text('Dark');
                    case ThemeMode.system:
                      return const Text('System');
                  }
                },
              ),
              onPress: () {
                showDialog(
                  context: context,
                  builder: (context) => FDialog(
                    title: const Text('Select Appearance'),
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final mode in ThemeMode.values)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FButton(
                              onPress: () {
                                SettingsService.instance.setThemeMode(mode);
                                Navigator.pop(context);
                              },
                              style:
                                  SettingsService.instance.themeMode.value ==
                                      mode
                                  ? FButtonStyle.primary()
                                  : FButtonStyle.outline(),
                              prefix:
                                  SettingsService.instance.themeMode.value ==
                                      mode
                                  ? const Icon(FIcons.check)
                                  : null,
                              child: Text(
                                mode.name[0].toUpperCase() +
                                    mode.name.substring(1),
                              ),
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      FButton(
                        onPress: () => Navigator.pop(context),
                        style: FButtonStyle.outline(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
            ),
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

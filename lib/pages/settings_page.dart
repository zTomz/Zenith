import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

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
            FTile(
              prefix: Icon(FIcons.brainCog),
              title: const Text('AI Model'),
              details: const Text('Download Zenith AI'),
              onPress: () {},
            ),
            // FTile(
            //   prefix: Icon(FIcons.wifi),
            //   title: const Text('WiFi'),
            //   details: const Text('Forus Labs (5G)'),
            //   suffix: Icon(FIcons.chevronRight),
            //   onPress: () {},
            // ),
          ],
        ),
      ),
    );
  }
}

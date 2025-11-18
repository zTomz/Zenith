import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:zenith/hive/hive_adapters.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/router/app_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zenith/services/ai_model_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AIModelService.instance.init();

  await Hive.initFlutter("boxes");
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');

  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FThemes.zinc.dark;

    return MaterialApp.router(
      // TODO: replace with your application's supported locales.
      supportedLocales: FLocalizations.supportedLocales,
      // TODO: add your application's localizations delegates.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      routerConfig: router,
    );
  }
}

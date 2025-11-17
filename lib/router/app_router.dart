import 'package:go_router/go_router.dart';
import 'package:zenith/models/note.dart';
import 'package:zenith/pages/home_page.dart';
import 'package:zenith/pages/note_page.dart';
import 'package:zenith/pages/navigation_page.dart';
import 'package:zenith/pages/settings_page.dart';

// Define route names as constants for easy reference
class RouteName {
  static const String home = '/';
  static const String note = '/note';
  static const String settings = '/settings';
}

// Create the router
final router = GoRouter(
  initialLocation: RouteName.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteName.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: RouteName.note,
                  name: 'note',
                  builder: (context, state) {
                    final note = state.extra as Note?;
                    return NotePage(note: note);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteName.settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Simple settings page for now

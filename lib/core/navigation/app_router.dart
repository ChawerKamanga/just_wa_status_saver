import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/saved/presentation/pages/saved_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String saved = '/saved';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const FeedScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Fade transition for home
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: saved,
        name: 'saved',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SavedScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Fade transition for saved screen
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCirc,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // Slide transition from right to left
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
    ],
  );
}

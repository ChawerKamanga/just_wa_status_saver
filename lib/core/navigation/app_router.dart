import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/saved/presentation/pages/saved_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String saved = '/saved';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: saved,
        name: 'saved',
        builder: (context, state) => const SavedScreen(),
      ),
    ],
  );
}

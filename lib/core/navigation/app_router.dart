import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String search = '/search';
  static const String add = '/add';
  static const String messages = '/messages';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Search Screen'))),
      ),
      GoRoute(
        path: add,
        name: 'add',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Add Screen'))),
      ),
      GoRoute(
        path: messages,
        name: 'messages',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Messages Screen'))),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile Screen'))),
      ),
    ],
  );
}

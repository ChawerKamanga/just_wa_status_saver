import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final int selectedNavIndex;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.selectedNavIndex = 0,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: appBar,
      body: body,
      bottomNavigationBar: BottomNavBar(selectedIndex: selectedNavIndex),
      floatingActionButton: floatingActionButton,
    );
  }
}

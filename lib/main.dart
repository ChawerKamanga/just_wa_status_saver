import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(const WaStatusSaverApp());
}

class WaStatusSaverApp extends StatelessWidget {
  const WaStatusSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

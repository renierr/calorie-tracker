import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/app_state.dart';
import 'widgets/responsive_layout.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create and initialize the app state provider (restores SharedPreferences & DB caches)
  final appState = AppState();
  await appState.init();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ResponsiveLayout(),
    );
  }
}

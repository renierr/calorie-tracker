import 'dart:io';
import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'theme/theme.dart';
import 'providers/app_state.dart';
import 'widgets/responsive_layout.dart';
import 'l10n/app_localizations.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FATAL] FlutterError: ${details.exception}');
    debugPrint('[FATAL] Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[FATAL] PlatformDispatcher Error: $error');
    debugPrint('[FATAL] Stack: $stack');
    return true;
  };

  await runZonedGuarded(
    () async {
      final appState = AppState();
      await appState.init();

      if (args.isNotEmpty &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        final String filePath = args[0];
        final File file = File(filePath);
        if (await file.exists()) {
          try {
            final bytes = await file.readAsBytes();
            await appState.handleIncomingImageBytes(bytes);
          } catch (e) {
            debugPrint("Error loading image from CLI argument: $e");
          }
        }
      }

      runApp(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MyApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      debugPrint('[FATAL] Uncaught async error in runZonedGuarded: $error');
      debugPrint('[FATAL] Stack: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((AppState a) => a.themeMode);
    final locale = context.select((AppState a) => a.locale);
    return MaterialApp(
      title: 'NutriScan Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShareIntentListener(child: ResponsiveLayout()),
    );
  }
}

class ShareIntentListener extends StatefulWidget {
  final Widget child;
  const ShareIntentListener({super.key, required this.child});

  @override
  State<ShareIntentListener> createState() => _ShareIntentListenerState();
}

class _ShareIntentListenerState extends State<ShareIntentListener> {
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _intentDataStreamSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen((List<SharedMediaFile> value) {
            _processSharedFiles(value);
          }, onError: (err) => debugPrint("getIntentDataStream error: $err"));

      ReceiveSharingIntent.instance.getInitialMedia().then((
        List<SharedMediaFile> value,
      ) {
        _processSharedFiles(value);
      });
    }
  }

  void _processSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;
    final file = files.first;
    if (file.path.isNotEmpty) {
      try {
        final bytes = await File(file.path).readAsBytes();
        if (mounted) {
          final appState = context.read<AppState>();
          await appState.handleIncomingImageBytes(bytes);
        }
      } catch (e) {
        debugPrint("Error processing shared file: $e");
      }
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

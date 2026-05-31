import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:calorie_tracker/layout/app_adaptive_layout.dart';
import 'package:calorie_tracker/providers/app_state.dart';
import 'package:calorie_tracker/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAppState extends AppState {
  int _tab = 0;

  @override
  int get selectedTabIndex => _tab;

  @override
  void selectTab(int index) {
    _tab = index;
    notifyListeners();
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> loadSettings() async {}

  @override
  Future<void> loadMeals() async {}
}

void main() {
  testWidgets('AppAdaptiveLayout back button test', (
    WidgetTester tester,
  ) async {
    // Set screen size to mobile so that the bottom navigation bar is rendered
    tester.view.physicalSize = const Size(750, 1000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockState = MockAppState();
    mockState.selectTab(1); // Set tab to Scan (non-dashboard)

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: mockState,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('de')],
          home: const AppAdaptiveLayout(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initially on tab 1
    expect(mockState.selectedTabIndex, 1);

    // Simulate system back button press
    final handled = await tester.binding.handlePopRoute();

    // It should have intercepted (handled == true) and updated the selected index to 0
    expect(handled, isTrue);
    expect(mockState.selectedTabIndex, 0);

    // Pump widget to rebuild UI under new state
    await tester.pumpAndSettle();

    // Press back again (now on tab 0 - Dashboard)
    final handledSecondTime = await tester.binding.handlePopRoute();

    // On tab 0, it should not intercept (handledSecondTime == false) so the app can close
    expect(handledSecondTime, isFalse);
  });
}

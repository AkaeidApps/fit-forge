// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fit_forge/screens/features_screen.dart';
import 'package:fit_forge/screens/home_screen.dart';
import 'package:fit_forge/screens/login_screen.dart';
import 'package:fit_forge/screens/main_dashboard.dart';
import 'package:fit_forge/screens/nutrition_screen.dart';
import 'package:fit_forge/screens/onboarding_screen.dart';
import 'package:fit_forge/screens/profile_screen.dart';
import 'package:fit_forge/screens/progress_screen.dart';
import 'package:fit_forge/screens/signup_screen.dart';
import 'package:fit_forge/screens/splash_screen.dart';
import 'package:fit_forge/screens/workout_screen.dart';
import 'package:fit_forge/main.dart';
import 'package:fit_forge/core/theme.dart';
import 'package:fit_forge/core/gym_store.dart';

void main() {
  setUp(() => GymStore.instance.resetDemoData());

  testWidgets('FitForge app opens on the splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitForceApp());

    expect(find.text('FITFORGE'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('feature cards fit on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(222, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: FeaturesScreen()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('all screens fit phone, landscape, tablet, and desktop sizes', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final screens = <String, Widget Function()>{
      'splash': () => const SplashScreen(),
      'onboarding': () => const OnboardingScreen(),
      'features': () => const FeaturesScreen(),
      'login': () => const LoginScreen(),
      'signup': () => const SignupScreen(),
      'dashboard': () => const MainDashboard(),
      'home': () => const HomeScreen(),
      'workout': () => const WorkoutScreen(),
      'nutrition': () => const NutritionScreen(),
      'progress': () => const ProgressScreen(),
      'profile': () => const ProfileScreen(),
    };
    const viewports = [
      Size(320, 568),
      Size(568, 320),
      Size(800, 1024),
      Size(1440, 900),
    ];

    for (final viewport in viewports) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      for (final screen in screens.entries) {
        await tester.pumpWidget(MaterialApp(home: screen.value()));
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.key} should fit in $viewport',
        );
      }
    }
  });

  testWidgets('app bars use the primary green theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const WorkoutScreen()),
    );

    final theme = Theme.of(tester.element(find.byType(AppBar)));
    expect(theme.appBarTheme.backgroundColor, AppTheme.primaryGreen);
    expect(theme.appBarTheme.foregroundColor, Colors.black);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.labelColor, Colors.black);
    expect(tabBar.unselectedLabelColor, Colors.black);
    expect(tabBar.indicatorColor, Colors.black);
  });

  testWidgets('workout controls update workout completion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WorkoutScreen()));
    expect(find.byType(Image), findsWidgets);

    await tester.tap(find.text('Start workout'));
    await tester.pump();
    expect(find.text('Workout started'), findsOneWidget);

    await tester.tap(find.text('Set 1').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '60');
    await tester.enterText(find.byType(TextFormField).at(1), '8');
    await tester.tap(find.text('Log set'));
    await tester.pumpAndSettle();
    expect(find.text('1 sets logged'), findsOneWidget);
    expect(GymStore.instance.activeSetLogs.single.weightKg, 60);
    expect(GymStore.instance.activeSetLogs.single.reps, 8);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await tester.pump();

    await tester.tap(find.text('Finish'));
    await tester.pump();
    expect(GymStore.instance.workoutHistory, hasLength(1));

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('Push Day'), findsWidgets);
    await tester.tap(find.text('Push Day').last);
    await tester.pumpAndSettle();
    expect(find.text('Barbell Bench Press · Set 1'), findsOneWidget);
  });

  testWidgets('adding a meal updates the calorie total', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NutritionScreen()));

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byTooltip('Add Chicken & rice to today’s log'));
    await tester.pump();

    expect(find.text('520'), findsOneWidget);
    expect(find.text('Chicken & rice added to today’s log'), findsOneWidget);
    expect(find.textContaining('42g protein'), findsOneWidget);
  });

  testWidgets('home notification and workout buttons respond', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pump();
    expect(find.text('You are all caught up!'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Workout'), findsOneWidget);
  });

  testWidgets('demo login opens the dashboard without credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Continue as demo'));
    await tester.pumpAndSettle();

    expect(find.byType(MainDashboard), findsOneWidget);
    expect(find.text("Today's Workout"), findsOneWidget);
  });

  testWidgets('login validates required credentials before navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Sign In'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'athlete@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'strongpass');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.byType(MainDashboard), findsOneWidget);
  });

  testWidgets('signup flow validates fields and completes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.text("Don't have an account? Sign Up"));
    await tester.tap(find.text("Don't have an account? Sign Up"));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Athlete');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'alex@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'strongpass');
    await tester.enterText(find.byType(TextFormField).at(3), 'strongpass');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Account details validated successfully'), findsOneWidget);
  });

  testWidgets('profile menu controls open and close details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    await tester.tap(find.text('My Goals'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Review your targets'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('My Goals'), findsOneWidget);
  });

  testWidgets('four bottom navigation buttons switch dashboard pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const MainDashboard()),
    );

    expect(find.text("Today's Workout"), findsOneWidget);

    await tester.tap(find.text('Workout').last);
    await tester.pumpAndSettle();
    expect(find.text('Exercises (5)'), findsOneWidget);

    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('75.5 kg'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Jacob Jones'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text("Today's Workout"), findsOneWidget);

    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets('nutrition remains accessible from Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('Nutrition details'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionScreen), findsOneWidget);
  });

  testWidgets('custom plans can be created from the plan builder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WorkoutScreen()));
    await tester.tap(find.byTooltip('Create a training plan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Arms Day');
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump();
    await tester.tap(find.text('Create plan'));
    await tester.pumpAndSettle();

    expect(find.text('Arms Day created'), findsOneWidget);
    expect(GymStore.instance.activePlanName, 'Arms Day');
    expect(GymStore.instance.activePlan.exercises, hasLength(1));
  });

  testWidgets('progress measurements and profile reminders are interactive', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProgressScreen()));
    await tester.tap(find.byTooltip('Add measurement'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '74.8');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('74.8 kg'), findsWidgets);

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    final reminder = find.byType(SwitchListTile).first;
    await tester.ensureVisible(reminder);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(reminder).value, isTrue);
    await tester.tap(reminder);
    await tester.pump();
    expect(GymStore.instance.reminders['Workout reminder'], isFalse);
  });
}

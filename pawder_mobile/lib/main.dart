import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'providers/bluetooth_repository_provider.dart';
import 'ui/activity/activity_screen.dart';
import 'ui/activity/activity_view_model.dart';
import 'ui/auth/auth_view_model.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/home/home_screen.dart';
import 'ui/login/login_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/settings/settings_view_model.dart';
import 'ui/splash/splash_screen.dart';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Background task: $task");

    switch (task) {
      case "bluetoothBackgroundTask":
        // バックグラウンドでのBluetooth処理
        // 注意: 実際のBluetoothアクセスはプラットフォームの制限により制限される場合があります
        print("Bluetooth background task executed");
        break;
    }

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Workmanager初期化
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(const PawderApp());
}

class PawderApp extends StatelessWidget {
  const PawderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = AuthViewModel();

    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return RootShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/activity',
                  name: 'activity',
                  builder: (context, state) => const ActivityScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  name: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(create: (_) => BluetoothRepositoryProvider()),
        ChangeNotifierProvider(create: (_) => ActivityViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp.router(
        title: 'Pawder',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    );
  }
}

class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF007AFF),
          unselectedItemColor: Colors.black45,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'アクティビティ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/core/theme/app_theme.dart';
import 'ui/home/home_view_model.dart';
import 'ui/home/home_screen.dart';
import 'ui/walk/walk_view_model.dart';
import 'ui/walk/walk_screen.dart';
import 'ui/settings/settings_view_model.dart';
import 'ui/settings/settings_screen.dart';

void main() {
  runApp(const PawderApp());
}

class PawderApp extends StatelessWidget {
  const PawderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => WalkViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp(
        title: 'Pawder',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootNavigatorPage(),
      ),
    );
  }
}

enum RootTab { walk, home, settings }

class RootNavigatorPage extends StatefulWidget {
  const RootNavigatorPage({super.key});

  @override
  State<RootNavigatorPage> createState() => _RootNavigatorPageState();
}

class _RootNavigatorPageState extends State<RootNavigatorPage> {
  RootTab _currentTab = RootTab.home;

  final _navigatorKeys = {
    RootTab.walk: GlobalKey<NavigatorState>(),
    RootTab.home: GlobalKey<NavigatorState>(),
    RootTab.settings: GlobalKey<NavigatorState>(),
  };

  void _onTap(int index) {
    final selected = RootTab.values[index];
    if (_currentTab == selected) {
      _navigatorKeys[selected]!
          .currentState
          ?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentTab = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final navigator = _navigatorKeys[_currentTab]!.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: RootTab.values.map((tab) {
            return _buildOffstageNavigator(tab);
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab.index,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_walk),
              label: '散歩',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(RootTab tab) {
    return Offstage(
      offstage: _currentTab != tab,
      child: Navigator(
        key: _navigatorKeys[tab],
        onGenerateRoute: (settings) {
          Widget page;
          switch (tab) {
            case RootTab.walk:
              page = const WalkScreen();
              break;
            case RootTab.home:
              page = const HomeScreen();
              break;
            case RootTab.settings:
              page = const SettingsScreen();
              break;
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }
}



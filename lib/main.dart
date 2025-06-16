import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'my_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  bool _showRegister = false;

  void _onLogin() {
    setState(() {
      _loggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _loggedIn = false;
      _showRegister = false;
    });
  }

  void _onShowRegister() {
    setState(() {
      _showRegister = true;
    });
  }

  void _onShowLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) {
      if (_showRegister) {
        return MaterialApp(
          home: RegisterPage(onLoginTap: _onShowLogin, onRegister: _onLogin),
          debugShowCheckedModeBanner: false,
        );
      } else {
        return MaterialApp(
          home: LoginPage(onRegisterTap: _onShowRegister, onLogin: _onLogin),
          debugShowCheckedModeBanner: false,
        );
      }
    }

    return MaterialApp(
      home: MainTabs(onLogout: _onLogout),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabs extends StatefulWidget {
  final VoidCallback onLogout;
  const MainTabs({super.key, required this.onLogout});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      const HomePage(),
      const MyEventsPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'My Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

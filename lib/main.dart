import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'my_events.dart';
import 'models/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

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
        );
      } else {
        return MaterialApp(
          home: LoginPage(onRegisterTap: _onShowRegister, onLogin: _onLogin),
        );
      }
    }

    return MaterialApp(
      home: MainTabs(onLogout: _onLogout),
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
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'My Events'), // ✅ Tambah ini
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

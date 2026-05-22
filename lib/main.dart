import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/music_provider.dart';
import 'providers/audio_recorder_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/home_page.dart';
import 'pages/player_page.dart';
import 'pages/library_page.dart';
import 'pages/record_page.dart';
import 'pages/settings_page.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => AudioRecorderProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const PteromyiniApp(),
    ),
  );
}

class PteromyiniApp extends StatelessWidget {
  const PteromyiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '鼯鼠音乐',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LibraryPage(),
    RecordPage(),
    SettingsPage(),
  ];

  void navigateToPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlayerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C5CE7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: '音乐库'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: '录音'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: '设置'),
        ],
      ),
    );
  }
}

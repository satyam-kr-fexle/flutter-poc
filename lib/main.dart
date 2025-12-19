import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:learningday1/provider/count_provider.dart';
import 'package:learningday1/provider/expense_provider.dart';
import 'package:learningday1/provider/favourite_provider.dart';
import 'package:learningday1/provider/theme_provider.dart';
import 'package:learningday1/provider/user_provider.dart';
import 'package:learningday1/screen/component_flutter.dart';
import 'package:learningday1/screen/expenses_screen.dart';
import 'package:learningday1/screen/favourite_list.dart';
import 'package:learningday1/screen/favourite_screen.dart';
import 'package:learningday1/screen/splash_screen.dart';
import 'package:learningday1/screen/users_screen.dart';
import 'package:learningday1/services/user_sync_service.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screen/home_body.dart';
import 'screen/custom_page.dart';
import 'screen/count_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize background sync service (only on mobile)
  if (!kIsWeb) {
    await UserSyncService.initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => CountProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/splash', // Changed to /splash
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.deepPurple,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                type: BottomNavigationBarType.fixed,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.grey[900],
                selectedItemColor: Colors.deepPurpleAccent,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
              ),
            ),
            routes: {
              '/splash': (context) => const SplashScreen(), // New Route
              '/': (context) => const MainPage(selectedIndex: 0),
              '/home': (context) => const MainPage(selectedIndex: 1),
              '/favourite': (context) => const MainPage(selectedIndex: 2),
              '/counter': (context) => const MainPage(selectedIndex: 4),
              '/expenses': (context) => const MainPage(selectedIndex: 0),
              '/flutter-tab': (context) => const MainPage(selectedIndex: 3),
              '/favourite-list': (context) => const FavouriteList(),
            },
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final int selectedIndex;
  const MainPage({super.key, this.selectedIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  void Function(BuildContext)? _showAddUserDialog;
  final List<String> _pageTitles = [
    'Expenses',
    'Home',
    'Favourite',
    'Flutter Tab',
    'Counter',
  ];
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pages.add(const ExpensesScreen()); // 0
    _pages.add(
      HomeBody(onDialogCallback: (callback) => _showAddUserDialog = callback),
    ); // 1
    _pages.add(const FavouriteScreen()); // 2
    _pages.add(const FlutterComponent()); // 3
    _pages.add(const CounterScreen()); // 4
    _pages.add(const UsersScreen()); // 5
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for index
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      // appBar header handled inside screens now
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddUserDialog?.call(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.tab), label: 'Tab'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Counter'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }
}

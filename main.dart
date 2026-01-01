import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/user_module/screens/user_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userType = prefs.getString('userType'); // 'user' or 'company'
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  Widget initialScreen;
  if (isLoggedIn) {
    if (userType == 'User') {
      initialScreen = UserNavigation();
    } else {
      initialScreen = LoginScreen();
    }
  } else {
    initialScreen = LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking Management App',
      theme: AppTheme.lightTheme,
      home: initialScreen,
    );
  }
}

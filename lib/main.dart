import 'package:batuaa/presentation/screens/auth/login_screen.dart';
import 'package:batuaa/presentation/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'batuaa_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeSwitch(),
      builder: (context, _) {
        final themeSwitch = Provider.of<ThemeSwitch>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeSwitch.themeMode,
          theme: batuaaThemes.lightTheme,
          darkTheme: batuaaThemes.darkTheme,
          home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const BottomNav();
                }

                return const LoginScreen();
              }),
        );
      },
    );
  }
}

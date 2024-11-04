import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/screens/user/LoginScreen.dart';
import 'package:star23sharp/screens/user/SignUpScreen.dart';
import 'package:star23sharp/screens/StartListScreen.dart';
import 'package:star23sharp/widgets/index.dart';

//TODO - 카카오 연결
//TODO - 카메라 연결

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: ThemeData(
        primaryColor: themeProvider.backgroundColor,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MainLayout(child: HomeScreen()),
        '/signin': (context) => const MainLayout(child: LoginScreen()),
        '/signup': (context) => const MainLayout(child: SignUpScreen()),
        '/starlist' : (context) => MainLayout(child: StarListScreen())
        // '/loading': (context) => const MainLayout(child: LoadingScreen()),
      },
    );
  }
}

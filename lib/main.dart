import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/layouts/MainLayout.dart';

//TODO - 카카오 연결
//TODO - 카메라 연결

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
        // '/loading': (context) => const MainLayout(child: LoadingScreen()),
      },
    );
  }
}

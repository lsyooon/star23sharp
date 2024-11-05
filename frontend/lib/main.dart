import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:provider/provider.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';

//TODO - 카카오 연결
//TODO - 카메라 연결

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/env/.env");

  final appKey = dotenv.env['APP_KEY'] ?? '';
  AuthRepository.initialize(
    appKey: appKey,
  );

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
        '/map': (context) => const MainLayout(child: MapScreen()),
        // '/loading': (context) => const MainLayout(child: LoadingScreen()),
      },
    );
  }
}

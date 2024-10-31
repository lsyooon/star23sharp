import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/providers/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    void onLoginPressed() {
      // 로그인 로직
    }

    void onSignupPressed() {
      // 회원가입 로직
    }
    final List<Map<String, dynamic>> buttons = [
      {
        'text': '로그인',
        'onPressed': onLoginPressed,
      },
      {
        'text': '회원가입',
        'onPressed': onSignupPressed,
      },
    ];
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            child: Image.asset(
              'assets/img/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Logo(),
              const SizedBox(height: 20),
              // 로그인 여부에 따른 UI 변경
              authProvider.isLoggedIn
                  ? const Text(
                      "Welcome",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : Column(
                      children: buttons.map((button) {
                        return Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * 0.5,
                                    50),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: button['onPressed'],
                              child: Text(
                                button['text'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

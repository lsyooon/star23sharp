import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/providers/index.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double bottomNavHeight = MediaQuery.of(context).size.height * 0.2;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: child,
          ),
          IgnorePointer(
            ignoring: true,
            child: Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(themeProvider.backgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              themeProvider.bottomNavigationImage, // 여기에 이미지 경로를 넣으세요.
              fit: BoxFit.fill,
            ),
          ),
          // BottomNavigationBar
          SizedBox(
            height: bottomNavHeight,
            child: BottomAppBar(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 왼쪽 Column의 배경 이미지 추가
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // 배경 이미지
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Positioned.fill(
                          child: Image.asset(
                            'assets/img/blackTheme/black_button_circle.png', // 왼쪽 Column 배경 이미지 경로
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      // Column 내용
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 28.0,
                            icon: const Icon(Icons.notifications_outlined),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/notification');
                            },
                          ),
                          IconButton(
                            iconSize: 28.0,
                            icon: const Icon(Icons.mail_outline),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/starstorage');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 가운데 버튼
                  IconButton(
                    iconSize: 50.0,
                    icon: Image.asset('assets/img/blackTheme/black_center_button.png'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/map');
                    },
                  ),
                  // 오른쪽 Column의 배경 이미지 추가
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Positioned.fill(
                          child: Image.asset(
                            'assets/img/blackTheme/black_button_circle.png', // 오른쪽 Column 배경 이미지 경로
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      // Column 내용
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 28.0,
                            icon: const Icon(Icons.account_circle_outlined),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/profile');
                            },
                          ),
                          IconButton(
                            iconSize: 28.0,
                            icon: Transform.rotate(
                              angle: pi / 2, // 90도 회전 (오른쪽으로)
                              child: const Icon(Icons.u_turn_left),
                            ),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context); // 화면이 있다면 뒤로가기
                              } else {
                                SystemNavigator.pop();  // 뒤로 갈 화면이 없다면 앱 종료
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

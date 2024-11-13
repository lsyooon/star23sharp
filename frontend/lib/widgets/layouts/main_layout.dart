import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;

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
            child: Image.asset(
              themeProvider.backgroundImage,
              fit: BoxFit.fill,
              width: UIhelper.deviceWidth(context),
              height: UIhelper.deviceHeight(context),
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
                        child: Image.asset(
                          'assets/img/blackTheme/black_button_circle.png', // 왼쪽 Column 배경 이미지 경로
                          fit: BoxFit.fill,
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
                              if (!isLoggedIn) {
                                ErrorSnackbar.show("로그인 해주세요!");
                                return;
                              }
                              Navigator.pushNamed(context, '/notification')
                                  .then((_) {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/home', (Route<dynamic> route) => false);
                              });
                            },
                          ),
                          IconButton(
                            iconSize: 28.0,
                            icon: const Icon(Icons.mail_outline),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              if (!isLoggedIn) {
                                ErrorSnackbar.show("로그인 해주세요!");
                                return;
                              }
                              Navigator.pushNamed(context, '/starstorage')
                                  .then((_) {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/home', (Route<dynamic> route) => false);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 가운데 버튼
                  IconButton(
                    iconSize: 50.0,
                    icon: Image.asset('assets/img/blackTheme/compass.png'),
                    onPressed: () {
                      if (!isLoggedIn) {
                        ErrorSnackbar.show("로그인 하신 후 사용하실 수 있습니다!");
                        return;
                      }
                      Navigator.pushNamed(context, '/map').then((_) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (Route<dynamic> route) => false);
                      });
                    },
                  ),
                  // 오른쪽 Column의 배경 이미지 추가
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Image.asset(
                          'assets/img/blackTheme/black_button_circle.png', // 오른쪽 Column 배경 이미지 경로
                          fit: BoxFit.fill,
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
                              if (!isLoggedIn) {
                                ErrorSnackbar.show("로그인 해주세요!");
                                return;
                              }
                              Navigator.pushNamed(context, '/profile')
                                  .then((_) {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/home', (Route<dynamic> route) => false);
                              });
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
                                SystemNavigator.pop(); // 뒤로 갈 화면이 없다면 앱 종료
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/star_write_type_modal.dart';
import 'package:star23sharp/providers/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenScreenState();
}

class _HomeScreenScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    void onLoginPressed() {
      // 로그인 로직
      Navigator.pushNamed(context, '/signin');
    }

    void onSignupPressed() {
      // 회원가입 로직
      Navigator.pushNamed(context, '/signup');
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
    final List<Map<String, dynamic>> menuList = [
      {
        'text': '별 보관함',
        'goto': '/starstorage',
        'img': 'assets/img/planet/planet1.png',
      },
      {
        'text': '별 숨기기',
        'goto': '/starwriteform',
        'img': 'assets/img/planet/planet2.png',
      },
      {
        'text': '내 정보',
        'goto': '/profile',
        'img': 'assets/img/planet/planet3.png',
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
              !authProvider.isLoggedIn
                  ? Column(
                      children: [
                        // menuList 표시
                        ...menuList.map((menu) {
                          return GestureDetector(
                            onTap: () {
                              String url = menu['goto'];
                              if (menu['text'] == "별 숨기기") {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return const CustomModal();
                                  },
                                ).then((selectedUrl) {
                                  if (selectedUrl != null) {
                                    url = selectedUrl;
                                    Navigator.pushNamed(context, url);
                                  }
                                });
                              } else {
                                Navigator.pushNamed(context, url);
                              }
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  menu['img'],
                                  width: 60,
                                ),
                                Text(
                                  menu['text'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        }),
                        // 하단 메시지
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Text(
                                "모든 별을 확인했어요.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "새로운 별을 전달해 보는건 어떨까요?",
                                style: TextStyle(
                                    color: Colors.yellow, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
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

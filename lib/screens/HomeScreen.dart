import 'package:flutter/material.dart';

import 'package:star23sharp/widgets/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.626,
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
              // 로그인 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(UIhelper.deviceWidth(context) * 0.5, 50),

                  backgroundColor: Colors.white.withOpacity(0.2), // 반투명한 배경색
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // 로그인 버튼 기능 추가
                },
                child: const Text(
                  "로그인",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              // 회원가입 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(UIhelper.deviceWidth(context) * 0.5, 50),
                  backgroundColor: Colors.white.withOpacity(0.2), // 반투명한 배경색
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // 회원가입 버튼 기능 추가
                },
                child: const Text(
                  "회원가입",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

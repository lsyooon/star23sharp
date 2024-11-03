import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 회원가입 타이틀과 입력 폼을 묶는 Column
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 회원가입 타이틀
              const Text(
                "회원가입",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // 아이디, 닉네임, 비밀번호, 비밀번호 확인 입력 필드와 회원가입 버튼을 포함하는 컨테이너
              Container(
                height: MediaQuery.of(context).size.height *
                    0.5, // 전체 화면의 60%로 높이 설정
                padding: const EdgeInsets.all(20),
                width: UIhelper.deviceWidth(context) * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  // 스크롤 가능하도록 설정
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아이디 입력 필드
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          "아이디",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFA292EC).withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      // 닉네임 입력 필드
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          "닉네임",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFA292EC).withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                      ),
                      // 비밀번호 입력 필드
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          "비밀번호",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFA292EC).withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                      ),
                      // 비밀번호 확인 입력 필드
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFA292EC).withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 회원가입 버튼
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFA292EC).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // 회원가입 버튼 클릭 시 처리
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              '회원가입',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

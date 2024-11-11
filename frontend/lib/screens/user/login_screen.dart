import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TextEditingController를 생성하여 아이디와 비밀번호 필드의 입력 값을 관리
    final TextEditingController memberIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
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
        // 로그인 타이틀과 입력 폼을 묶는 Column
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로그인 타이틀
              const Text(
                "로그인",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.title,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // 아이디, 비밀번호 입력 필드와 로그인 버튼을 포함하는 컨테이너
              Container(
                padding: const EdgeInsets.all(20),
                width: UIhelper.deviceWidth(context) * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
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
                          fontSize: FontSizes.label,
                        ),
                      ),
                    ),
                    TextField(
                      controller: memberIdController,
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
                          fontSize: FontSizes.label,
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
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
                    const SizedBox(height: 20),
                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFA292EC).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            String memberId = memberIdController.text.trim();
                            String password = passwordController.text.trim();

                            if (memberId.isEmpty || password.isEmpty) {
                              ErrorSnackbar.show("아이디 및 비밀번호를 입력해주세요.");
                            } else {
                              logger.d("id: $memberId, pwd: $password");
                              Map<String, String>? loginResponse =
                                  await UserService.login(memberId, password);
                              if (loginResponse != null) {
                                await Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .setToken(loginResponse['access']!,
                                        loginResponse['refresh']!);

                                // 내 정보 provider에 저장
                                Map<String, dynamic> user =
                                    await UserService.getMemberInfo();
                                logger.d(user);
                                userProvider.setUserDetails(
                                    id: user['memberId'],
                                    name: user['nickname'],
                                    isPushEnabled:
                                        user['pushNotificationEnabled']);
                                if (userProvider.getPushNotificationEnabled !=
                                        null &&
                                    userProvider.getPushNotificationEnabled ==
                                        true) {
                                  await NotificationService.updateDeviceToken();
                                }

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home', // 네임드 라우트 사용
                                  (Route<dynamic> route) =>
                                      false, // 모든 이전 화면 제거
                                );
                              } else {
                                // 로그인 실패 UI 처리
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                                fontSize: FontSizes.label, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

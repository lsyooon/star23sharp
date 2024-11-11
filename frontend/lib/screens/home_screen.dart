import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/star_write_type_modal.dart';
import 'package:star23sharp/providers/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BoxDecoration _commonContainerDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12), // 둥근 모서리
    );
  }

  bool isunRead = false;

  // 비동기 초기화 작업을 위한 별도 메서드
  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await loadAccessToken(authProvider); // Secure Storage에서 토큰 불러오기
    if (authProvider.accessToken != null && authProvider.refreshToken != null) {
      // 회원정보
      Map<String, dynamic> user = await UserService.getMemberInfo();
      logger.d(user);
      Provider.of<UserProvider>(AppGlobal.navigatorKey.currentContext!,
              listen: false)
          .setUserDetails(
              id: user['memberId'],
              name: user['nickname'],
              isPushEnabled: user['pushNotificationEnabled']);
      isunRead = await StarService.getIsUnreadMessage();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

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
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.65,
          UIhelper.deviceHeight(context) * -0.09,
        ),
        'img': 'assets/img/planet/planet1.png',
      },
      {
        'text': '별 숨기기',
        'goto': '/starform',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.15,
          UIhelper.deviceHeight(context) * 0.0,
        ),
        'img': 'assets/img/planet/planet2.png',
      },
      {
        'text': '내 정보',
        'goto': '/profile',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.6, // 너비의 60%
          UIhelper.deviceHeight(context) * 0.1, // 높이의 50%
        ),
        'img': 'assets/img/planet/planet3.png',
      },
    ];

    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.9,
            height: UIhelper.deviceHeight(context) * 0.7,
            child: Image.asset(
              'assets/img/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Logo(),
            // 로그인 여부에 따른 UI 변경
            authProvider.isLoggedIn
                ? Expanded(
                    child: IgnorePointer(
                      ignoring: false,
                      child: Stack(
                        clipBehavior: Clip.none, // Overflow를 허용

                        children: [
                          ...menuList.map((menu) {
                            return Positioned(
                              left: menu['position'].dx,
                              top: menu['position'].dy,
                              child: GestureDetector(
                                onTap: () async {
                                  String url = menu['goto'];
                                  if (menu['text'] == "별 숨기기") {
                                    final selectedUrl =
                                        await showModalBottomSheet<String>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (BuildContext context) {
                                        return const StarWriteTypeModal();
                                      },
                                    );

                                    // 선택된 URL이 null이 아닌 경우 페이지 이동
                                    if (selectedUrl != null) {
                                      url = selectedUrl;
                                      Provider.of<MessageFormProvider>(context,
                                              listen: false)
                                          .setMessageFormType(type: url);
                                      Navigator.pushNamed(context, url);
                                    }
                                  } else {
                                    Navigator.pushNamed(context, url);
                                  }
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      menu['img'],
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      decoration: _commonContainerDecoration(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        menu['text'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: FontSizes.label),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          // 하단 메시지
                          Positioned(
                            bottom: 50,
                            left: 20,
                            right: 20,
                            child: Column(
                              children: [
                                Container(
                                  decoration: _commonContainerDecoration(),
                                  padding: const EdgeInsets.all(8),
                                  child: isunRead
                                      ? const Column(
                                          children: [
                                            Text(
                                              "알림함을 확인해 보세요!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "새로운 쪽지가 기다리고 있어요.",
                                              style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        )
                                      : const Column(
                                          children: [
                                            Text(
                                              "모든 쪽지를 확인했어요",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "쪽지를 전달해 보는건 어떨까요?",
                                              style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: buttons.map((button) {
                      return Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.5, 50),
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
                                  color: Colors.white,
                                  fontSize: FontSizes.label),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
          ],
        ),
      ],
    );
  }
}

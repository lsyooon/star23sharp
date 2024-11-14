import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/widgets/index.dart';
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

  Future<bool> checkNetworkConnectivity() async {
    // Check network connection status
    var connectivityResult = await Connectivity().checkConnectivity();
    // No network connection
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    } else {
      return true;
    }
  }

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

  // 네트워크 연결 실패 화면
  Widget buildErrorScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              child: Image.asset(
                'assets/img/no_data.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "일시적으로 데이터를 불러올 수 없습니다.\n네트워크 환경을 확인하거나\n페이지를 새로고침해주세요.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isConnected =
                    await checkNetworkConnectivity(); // 네트워크 상태 재확인
                if (isConnected) {
                  // 네트워크 연결이 복구되었을 경우 상태 업데이트
                  setState(() {
                    // 상태를 변경하면 FutureBuilder가 다시 빌드됨
                  });
                } else {
                  // 네트워크 연결이 여전히 없는 경우 사용자에게 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("네트워크 연결이 없습니다.")),
                  );
                }
              },
              child: const Text("다시 불러오기"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHomeScreen(BuildContext context) {
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
        'text': '친구 목록',
        'goto': '/nickbooks',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.65,
          UIhelper.deviceHeight(context) * -0.08,
        ),
        'img': 'assets/img/planet/planet4.png',
      },
      {
        'text': '일반 쪽지',
        'goto': '/starwriteform',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.15,
          UIhelper.deviceHeight(context) * 0.0,
        ),
        'img': 'assets/img/planet/planet1.png',
      },
      {
        'text': '보물 쪽지',
        'goto': '/hidestar',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.6, // 너비의 60%
          UIhelper.deviceHeight(context) * 0.125, // 높이의 50%
        ),
        'img': 'assets/img/planet/planet2.png',
      },
      {
        'text': '쪽지 보관함',
        'goto': '/starstorage',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.1, // 너비의 60%
          UIhelper.deviceHeight(context) * 0.2, // 높이의 50%
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
            const IgnorePointer(ignoring: true, child: Logo()),
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
                                  Navigator.pushNamed(context, url);
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Image.asset(
                                          menu['img'],
                                        ),
                                        if (menu['text'] == '쪽지 보관함' &&
                                            isunRead)
                                          Positioned(
                                            top: -10,
                                            right: -10,
                                            child: Image.asset(
                                              'assets/img/exclamation_mark.png',
                                            ),
                                          ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkNetworkConnectivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || (snapshot.data == false)) {
          return buildErrorScreen(context);
        } else {
          return buildHomeScreen(context);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:star23sharp/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = true; // 로딩 상태를 위한 플래그
  bool isunRead = false;

  BoxDecoration _commonContainerDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    );
  }

  Future<bool> checkNetworkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    await loadAccessToken(authProvider);
    if (authProvider.accessToken != null && authProvider.refreshToken != null) {
      Map<String, dynamic>? user = await UserService.getMemberInfo();
      if (user != null) {
        Provider.of<UserProvider>(AppGlobal.navigatorKey.currentContext!,
                listen: false)
            .setUserDetails(
                id: user['memberId'],
                name: user['nickname'],
                isPushEnabled: user['pushNotificationEnabled']);
      }
      isunRead = await StarService.getIsUnreadMessage();
    }

    String? theme = await storage.read(key: 'theme');
    if (theme == 'AppTheme.blue') {
      themeProvider.setTheme(AppTheme.blue);
    } else if (theme == 'AppTheme.red') {
      themeProvider.setTheme(AppTheme.red);
    } else {
      themeProvider.setTheme(AppTheme.black);
    }

    bool hasLocationPermission = await requestLocationPermission(context);
    if (!hasLocationPermission) {
      showPermissionDialog(context);
    }

    // 로딩 완료 처리
    if (mounted) {
      setState(() {
        isLoading = false; // 로딩 상태 종료
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Widget buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/img/logo/loading_logo.gif",
              height: UIhelper.deviceHeight(context) * 0.3,
            ),
            const Text(
              "잠시만 기다려 주세요...",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

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
                bool isConnected = await checkNetworkConnectivity();
                if (isConnected) {
                  setState(() {}); // 상태를 변경하면 FutureBuilder가 다시 빌드됨
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
        'text': '즐겨찾기',
        'goto': '/nickbooks',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.6,
          UIhelper.deviceHeight(context) * 0.25,
        ),
        'img': 'assets/img/planet/planet4.png',
      },
      {
        'text': '일반 쪽지',
        'goto': '/starwriteform',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.15,
          UIhelper.deviceHeight(context) * 0.3,
        ),
        'img': 'assets/img/planet/planet1.png',
      },
      {
        'text': '보물 쪽지',
        'goto': '/hidestar',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.57,
          UIhelper.deviceHeight(context) * 0.46,
        ),
        'img': 'assets/img/planet/planet2.png',
      },
      {
        'text': '쪽지 보관함',
        'goto': '/starstorage',
        'position': Offset(
          UIhelper.deviceWidth(context) * 0.16,
          UIhelper.deviceHeight(context) * 0.5,
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
              themeProvider.mainBg,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Stack(
          children: [
            const Positioned(
              top: 30,
              left: 0,
              // right: UIhelper.deviceWidth(context) * 0.3,
              child: Logo(),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

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
                                        if (menu['text'] == "일반 쪽지") {
                                          Provider.of<MessageFormProvider>(
                                                  context,
                                                  listen: false)
                                              .isTeasureStar = false;
                                        }
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
                                                  top: -6, // -10, 85
                                                  right: -5, // -10, -10, 0
                                                  child: Lottie.asset(
                                                    'assets/icon/alert.json',
                                                    width: 25,
                                                    height: 25,
                                                  ),
                                                  // top: -10,
                                                  // right: -10,
                                                  // child: Image.asset(
                                                  //   'assets/img/exclamation_mark.png',
                                                  // ),
                                                ),
                                              const SizedBox(height: 5),
                                            ],
                                          ),
                                          Container(
                                            decoration:
                                                _commonContainerDecoration(),
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
                          children: [
                            const SizedBox(height: 100),
                            ...buttons.asMap().map((index, button) {
                              return MapEntry(
                                index,
                                Column(
                                  children: [
                                    Container(
                                      width:
                                          UIhelper.deviceWidth(context) * 0.5,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: button['onPressed'],
                                        splashColor: Colors.white
                                            .withOpacity(0.3), // 클릭 시 효과
                                        borderRadius: BorderRadius.circular(10),
                                        child: Center(
                                          child: Text(
                                            button['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: FontSizes.label,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 마지막 아이템이 아닐 경우에만 SizedBox 추가
                                    if (index < buttons.length - 1)
                                      const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            }).values
                          ],
                        ),
                  TextButton(
                    onPressed: () async {
                      final Uri uri =
                          Uri.parse("https://k11b104.p.ssafy.io/manual");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("페이지를 이동할 수 없습니다.")),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, // 버튼 패딩 제거
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline, // 물음표 아이콘
                          color: Colors.white, // 아이콘 색상
                          size: 20, // 아이콘 크기
                        ),
                        Text(
                          " 사용법 보러가기",
                          style: TextStyle(
                            color: Colors.white, // 텍스트 색상
                            fontSize: 18.0, // 텍스트 크기
                            // decoration: TextDecoration.underline, // 밑줄 추가
                            // decorationColor: Colors.white, // 밑줄 색상
                            // decorationThickness: 1.5, // 밑줄 두께 조정
                            height: 3, // 텍스트 높이를 늘려 간격 확보
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        if (isLoading) {
          return buildLoadingScreen(); // 초기 로딩 화면
        }
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

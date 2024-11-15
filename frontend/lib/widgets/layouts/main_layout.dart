import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  void navigateToScreen(BuildContext context, String routeName) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn;

    // 로그인 여부 확인
    if (!isLoggedIn) {
      ErrorSnackbar.show("로그인 후 사용 가능합니다.");
      return;
    }

    // 현재 화면과 이동하려는 화면이 다를 때만 이동
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushNamed(context, routeName).then((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', (Route<dynamic> route) => false);
      });
    }
  }

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
                          themeProvider.sideButtonContainer,
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Column 내용
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 30.0,
                            icon: Image.asset(
                              'assets/img/blackTheme/bell.png',
                              width: 30.0,
                              height: 30.0,
                            ),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              navigateToScreen(context, "/notification");
                            },
                          ),
                          IconButton(
                            iconSize: 30.0,
                            icon: Image.asset(
                              'assets/img/blackTheme/mailbox.png',
                              width: 30.0,
                              height: 30.0,
                            ),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              navigateToScreen(context, "/starstorage");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(themeProvider.centerButton), 
                        fit: BoxFit.fill, 
                      ),
                    ),
                    // 정해지는
                    child: IconButton(
                      iconSize: 20.0,
                      icon: Image.asset('assets/img/blackTheme/compass.png'),
                      onPressed: () {
                        navigateToScreen(context, "/map");
                      },
                    ),
                  ),
                  //  IconButton(
                  //   iconSize: 50.0,
                  //   icon: Image.asset('assets/img/blackTheme/compass.png'),
                  //   onPressed: () {
                  //     navigateToScreen(context, "/map");
                  //   },
                  // ),
                  // 오른쪽 Column의 배경 이미지 추가
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Image.asset(
                          themeProvider.sideButtonContainer,
                          fit: BoxFit.fill,
                          ),
                      ),
                      // Column 내용
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 35.0,
                            icon: Image.asset(
                              'assets/img/blackTheme/profile.png',
                              width: 35.0,
                              height: 35.0,
                            ),
                            color: const Color(0xFF868686),
                            onPressed: () {
                              navigateToScreen(context, "/profile");
                            },
                          ),
                          IconButton(
                            iconSize: 30.0,
                            icon: Image.asset(
                              'assets/img/blackTheme/back.png',
                              width: 30.0,
                              height: 30.0,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/app_global.dart';
import 'package:star23sharp/widgets/index.dart';

class ModifyProfileScreen extends StatelessWidget {
  const ModifyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
   

    return Stack(
      children: [
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
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "내 정보",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.title, 
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                // padding: const EdgeInsets.all(20),
                width: UIhelper.deviceWidth(context) * 0.8,
                height: UIhelper.deviceHeight(context) * 0.3,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E1E1).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("화면")
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: UIhelper.deviceWidth(context) * 0.5, // 너비 50%
                child: ElevatedButton(
                  onPressed: () async {
                    var refresh = Provider.of<AuthProvider>(context, listen: false).refreshToken;
                    bool response = await UserService.logout(refresh!);
                    if(response){
                      Provider.of<AuthProvider>(AppGlobal.navigatorKey.currentContext!, listen: false).clearTokens();
                      Navigator.pushNamed(AppGlobal.navigatorKey.currentContext!, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA292EC).withOpacity(0.4), // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게 설정
                    ),
                  ),
                  child: const Text("로그아웃", style: TextStyle(fontSize: FontSizes.body, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

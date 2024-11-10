import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(
            UIhelper.deviceWidth(context) * 0.1, // 디바이스 너비의 10% 만큼 오른쪽으로 이동
            -UIhelper.deviceHeight(context) * 0.02, // 디바이스 높이의 2% 만큼 위로 이동
          ),
          child: Transform.rotate(
            angle: -0.7,
            child: Image.asset(
              "assets/img/logo/star_logo.GIF",
              // width: UIhelper.deviceWidth(context) * 0.4, // 별 로고 너비
              height: UIhelper.deviceHeight(context) * 0.3, // 별 로고 높이
            ),
          ),
        ),
        // 텍스트 로고
        Transform.translate(
          offset: Offset(
            -UIhelper.deviceWidth(context) * 0.15, // 디바이스 너비의 15% 만큼 왼쪽으로 이동
            0,
          ),
          child: Image.asset(
            'assets/img/logo/text_logo.png', // 텍스트 로고 이미지 경로
            height: UIhelper.deviceHeight(context) * 0.15, // 텍스트 로고 높이
          ),
        ),
      ],
    );
  }
}

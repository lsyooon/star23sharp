import 'package:flutter/material.dart';

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
          offset: const Offset(50, -15),
          child: Transform.rotate(
            angle: -0.7,
            child: Image.asset(
              "assets/img/logo/star_logo.GIF",
              width: 200, // 필요에 따라 크기 조정
              height: 200,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-100, 0),
          child: Image.asset(
            'assets/img/logo/text_logo.png', // 텍스트 로고 이미지 경로
            height: 150, // 필요에 따라 크기 조정
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:star23sharp/widgets/index.dart';

class ShowLocationPermission extends StatelessWidget {
  final String title;
  final String content;

  const ShowLocationPermission({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final deviceHeight = UIhelper.deviceHeight(context);
    final deviceWidth = UIhelper.deviceWidth(context);
    return Stack(
      children: [
        Positioned(
          top: deviceHeight * 0.25,
          left: deviceWidth * 0.1,
          right: deviceWidth * 0.1,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(content),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context); // 화면이 있다면 뒤로가기
                          } 
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          // 앱 세팅 호출
                          openAppSettings();
                          Navigator.pop(context);
                        },
                        child: const Text("설정으로 이동"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const ShowLocationPermission(
      title: "권한 필요",
      content: "위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.",
    ),
  );
}

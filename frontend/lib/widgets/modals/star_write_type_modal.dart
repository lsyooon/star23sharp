import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';

class StarWriteTypeModal extends StatelessWidget {
  const StarWriteTypeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: UIhelper.deviceHeight(context) * 0.2,
        width: UIhelper.deviceWidth(context),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width:
                  UIhelper.deviceWidth(context) * 0.9, // 너비를 디바이스 너비의 80%로 설정
              height:
                  UIhelper.deviceHeight(context) * 0.08, // 너비를 디바이스 너비의 80%로 설정
              child: ElevatedButton(
                onPressed: () {
                  // 보물 편지 버튼 클릭 시 동작
                  Navigator.pop(context, '/map'); // 모달 닫고 데이터 전달
                },
                child: const Text("보물 편지 보내기"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width:
                  UIhelper.deviceWidth(context) * 0.9, // 너비를 디바이스 너비의 80%로 설정
              height:
                  UIhelper.deviceHeight(context) * 0.08, // 너비를 디바이스 너비의 80%로 설정
              child: ElevatedButton(
                onPressed: () {
                  // 일반 편지 버튼 클릭 시 동작
                  Provider.of<MessageFormProvider>(context, listen: false)
                      .isTeasureStar = false;
                  Navigator.pop(context, '/starwriteform'); // 모달 닫고 데이터 전달
                },
                child: const Text("일반 편지 보내기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

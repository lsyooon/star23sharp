import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  const CustomModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // 모달의 높이 설정
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // 보물 편지 버튼 클릭 시 동작
              Navigator.pop(context, 'treasure_letter_url'); // 모달 닫고 데이터 전달
            },
            child: const Text("보물 편지 보내기"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // 일반 편지 버튼 클릭 시 동작
              Navigator.pop(context, 'normal_letter_url'); // 모달 닫고 데이터 전달
            },
            child: const Text("일반 편지 보내기"),
          ),
        ],
      ),
    );
  }
}

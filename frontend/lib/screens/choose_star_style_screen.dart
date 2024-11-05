import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class ChooseStarStyleScreen extends StatelessWidget {
  const ChooseStarStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String title = '별 문체 바꾸기';
    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white, // 배경색 추가

        child: Column(
          // 커스텀 헤더
          children: [
            Container(
              color: const Color(0xFFA292EC),
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Container(
                width: UIhelper.deviceWidth(context) * 0.85,
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.arrow_back, color: Colors.black),
                Text(
                  '문체 명',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.black),
              ],
            ),
            const SizedBox(height: 20.0),
            // 본문 내용
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  '사용자가 입력한 내용의 문체를 ChatGPT를 사용해서 변환하고 그 내용을 보여줍니다.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 버튼 클릭 시 동작 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA292EC),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    '별 전달하기',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

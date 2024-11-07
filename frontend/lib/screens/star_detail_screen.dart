import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class StarDetailScreen extends StatelessWidget {
  const StarDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 상세 화면에서 데이터 받는 방법
    // final String receivedData = ModalRoute.of(context)!.settings.arguments as String;

    // final String title, senderNickname, createdDate;
    // final int messageId, receiverType;
    // final bool kind;
    String senderNickname = "전영ㅇ주";
    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // 커스텀 헤더
          children: [
            Container(
              color: const Color(0xFFA292EC),
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              child: Container(
                width: UIhelper.deviceWidth(context) * 0.85,
                alignment: Alignment.centerLeft,
                child: Text(
                  senderNickname,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "이거 찾아봐",
                    style: TextStyle(
                      fontSize: FontSizes.label,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 본문 내용
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: UIhelper.deviceWidth(context) * 0.8,
                      maxHeight: UIhelper.deviceHeight(context) * 0.44, // 고정된 최대 높이 설정
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child:  Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                             Image.asset(
                              'assets/img/main_bg.png',
                              fit: BoxFit.cover,
                              height: 150,
                              width: 200,
                            ),
                            const SizedBox(height: 10,),
                            const Text(
                              "사용자가 입력한 내용의 문체를 chat gpt를 사용해서 변환하고 그 내용을 보여합니다.사용자가 입력한 내용의 문체를 chat gpt를 사용해서 변환하고 그 내용을 보여합니다.사용자가 입력한 내요의 문체를 chat gpt를 사용해서 변환하고 그 내용을 보여합니다..",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(left: 5.0, bottom: 2),
              child: Text("2024/11/06 오후 12:55"),
            ),
          ],
        ),
      ),
    );
  }
}
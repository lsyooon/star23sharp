import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';

import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/models/enums/star/writing_style.dart';

class ChooseStarStyleScreen extends StatefulWidget {
  const ChooseStarStyleScreen({super.key});

  @override
  State<ChooseStarStyleScreen> createState() => _ChooseStarStyleScreenState();
}

class _ChooseStarStyleScreenState extends State<ChooseStarStyleScreen> {
  WritingStyle currentStyle = WritingStyle.basic;
  final Map<WritingStyle, String?> changedMessages = {
    WritingStyle.basic: null,
    WritingStyle.cute: null,
    WritingStyle.didItStyle: null,
    WritingStyle.haoche: null,
    WritingStyle.humanKorean: null,
    WritingStyle.otaku: null,
    WritingStyle.middleSchool: null,
  };

// 문체 이름 반환 함수
  String getStyleName(WritingStyle style) {
    switch (style) {
      case WritingStyle.basic:
        return '기본';
      case WritingStyle.cute:
        return '귀여니체';
      case WritingStyle.didItStyle:
        return '했삼체';
      case WritingStyle.haoche:
        return '하오체';
      case WritingStyle.humanKorean:
        return '휴먼급식체';
      case WritingStyle.otaku:
        return '오덕체';
      case WritingStyle.middleSchool:
        return '중2병체';
      default:
        return '기본';
    }
  }

  Future<void> _handleArrowButtonPress(
      bool isNext, MessageFormProvider messageProvider) async {
    setState(() {
      currentStyle = isNext
          ? WritingStyle
              .values[(currentStyle.index + 1) % WritingStyle.values.length]
          : WritingStyle.values[
              (currentStyle.index - 1 + WritingStyle.values.length) %
                  WritingStyle.values.length];
    });

    // API 호출 후 변환된 메시지를 저장
    if ((changedMessages[currentStyle] == null ||
            changedMessages[currentStyle] == '문체 변환 중 오류가 발생했습니다.') &&
        currentStyle != WritingStyle.basic) {
      String result = await OpenAIService.instance
          .fetchStyledMessage(messageProvider.message, currentStyle);
      setState(() {
        changedMessages[currentStyle] = result;
      });
    }
  }

  void _onSendButtonPressed() {
    //TODO - 쪽지 전송 api
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageFormProvider>(context);
    String title = '별 문체 바꾸기';
    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () =>
                      _handleArrowButtonPress(false, messageProvider),
                ),
                Text(
                  currentStyle.name,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.black),
                  onPressed: () =>
                      _handleArrowButtonPress(true, messageProvider),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // 본문 내용
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: UIhelper.deviceWidth(context) * 0.8,
                  minHeight: UIhelper.deviceHeight(context) * 0.33,
                ),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    currentStyle == WritingStyle.basic
                        ? messageProvider.message
                        : (changedMessages[currentStyle] ?? '변환 중입니다...'),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                      height: 1.5,
                    ),
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
                  onPressed: _onSendButtonPressed,
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

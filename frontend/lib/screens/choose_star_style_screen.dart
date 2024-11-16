import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/screens/index.dart';

import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/enums/index.dart';

class ChooseStarStyleScreen extends StatefulWidget {
  const ChooseStarStyleScreen({super.key});

  @override
  State<ChooseStarStyleScreen> createState() => _ChooseStarStyleScreenState();
}

class _ChooseStarStyleScreenState extends State<ChooseStarStyleScreen> {
  bool isLoading = false; // 로딩 상태

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
    String content = messageProvider.content ?? '';

    // API 호출 후 변환된 메시지를 저장
    if ((changedMessages[currentStyle] == null ||
            changedMessages[currentStyle] == '문체 변환 중 오류가 발생했습니다.') &&
        currentStyle != WritingStyle.basic) {
      String result = await OpenAIService.instance
          .fetchStyledMessage(content, currentStyle);
      if (result.length > 100) {
        result = result.substring(0, 100);
      }
      setState(() {
        changedMessages[currentStyle] = result;
      });
    }
  }

  void _onSendButtonPressed(BuildContext context) async {
    final messageProvider =
        Provider.of<MessageFormProvider>(context, listen: false);

    try {
      setState(() {
        isLoading = true; // 로딩 시작
      });
      // `isTeasureStar`에 따라 데이터 가져오기
      final isTreasureStar = messageProvider.isTeasureStar;

      if (currentStyle != WritingStyle.basic) {
        logger.d("문체 변경 $currentStyle");
        messageProvider.saveMessageData(content: changedMessages[currentStyle]);
      }
      final data = messageProvider.messageData;
      // 데이터가 없는 경우 처리
      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지를 입력해주세요.')),
        );
        return;
      }
      logger.d(data.toString());
      // API 호출
      bool response = await StarService.sendMessage(
        isTreasureStar: isTreasureStar,
        data: data,
      );
      if (response) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('별 전송 완료!')),
        );
      }

        Navigator.pushNamed(context, isTreasureStar ? '/map' : '/starstorage').then((_) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
        });
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 실패: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageFormProvider>(context);
    String? content = messageProvider.content;

    return Stack(
      children: [
        Center(
          child: Container(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            color: Colors.white,
            child: Column(
              children: [
                // 커스텀 헤더
                Container(
                  color: themeProvider.mainColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                  child: Container(
                    width: UIhelper.deviceWidth(context) * 0.85,
                    alignment: Alignment.center,
                    child: const Text(
                      '문체 바꾸기',
                      style: TextStyle(
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
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.black),
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
                      minHeight: UIhelper.deviceHeight(context) * 0.3,
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
                            ? (content ?? '')
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

                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onSendButtonPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '별 전달하기',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8), // 불투명 하얀 배경
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFA292EC), // 스피너 색상
                ),
              ),
            ),
          ),
      ],
    );
  }
}

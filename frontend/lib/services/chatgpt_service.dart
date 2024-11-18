import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/utilities/enums/star/writing_style.dart';

class OpenAIService {
  OpenAIService._internal();
// Singleton instance
  static final OpenAIService instance = OpenAIService._internal();

  Future<String> fetchStyledMessage(
      String originalMessage, WritingStyle style) async {
    OpenAI.apiKey = dotenv.env['OPEN_AI_API_KEY'].toString();

    try {
      final String prompt = '''
     문체: ${style.name}
     예시:${style.example}
     이런 느낌으로 '$originalMessage'의 문체를 바꿔주는데, 90자 이하로 해야해.응답은 반드시 결과 값 만 반환해주세요. ''';
      // 시스템 메시지 설정
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '응답은 반드시 결과 값 만 반환해주세요.',
          ),
        ],
        role: OpenAIChatMessageRole.assistant,
      );

      // 사용자 요청 메시지 설정
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [
        systemMessage,
        userMessage,
      ];
      // ChatGPT API 호출
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-4o",
        messages: requestMessages,
        temperature: 0.2,
        maxTokens: 500,
      );
      // content에서 첫 번째 텍스트 메시지 추출
      final response = chatCompletion.choices.first.message.content![0].text;
      logger.d(response);

      // 응답이 JSON 형식인지 검사 후 디코딩
      if (response != null) {
        return response.trim();
      } else {
        logger.e('JSON 형식 오류: $response');
        return '문체 변환 중 오류가 발생했습니다.';
      }
    } catch (e) {
      logger.e('Error: $e');
      return '문체 변환 중 오류가 발생했습니다.';
    }
  }
}

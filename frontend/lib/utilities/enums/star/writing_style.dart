enum WritingStyle {
  basic,
  cute,
  haoche,
  humanKorean,
  otaku,
  middleSchool,
  didItStyle
}

extension WritingStyleExtension on WritingStyle {
  String get name {
    switch (this) {
      case WritingStyle.basic:
        return '기본';
      case WritingStyle.cute:
        return '귀여니체';
      case WritingStyle.haoche:
        return '하오체';
      case WritingStyle.humanKorean:
        return '휴먼급식체';
      case WritingStyle.otaku:
        return '오덕체';
      case WritingStyle.middleSchool:
        return '중2병체';
      case WritingStyle.didItStyle:
        return '했삼체';
    }
  }

  String get example {
    switch (this) {
      case WritingStyle.basic:
        return '안녕하세요.';
      case WritingStyle.cute:
        return '''
ヌr ㄱ l 0F앙♡ ●살콩하l언l
ol뿐짓하lㅂr0 ol-l교장0l > <♥
♥ 우zl nㅓuБ님 nㅋㅎH요오 ε
''';
      case WritingStyle.haoche:
        return '''
명령형: 답하시오/따라하지 마시오/잘 좀 하시오/건너지 마오/거 작작 좀 하오
의문형: 정말이오?/잘 될 것 같소?/내일은 정답에 맞으오?
감탄형: 옷이 참 아름답구려./밥 먼저 자시고 하시구려.
청유형: 공부합시다/먹읍시다
''';
      case WritingStyle.humanKorean:
        return '''
ㄹㅇ꿀잼인데 안 쓰면 개에바터지는각 ㅇㅈ? 인정각 or 극혐
~구연: ~고요 (지리구연~오지구연~)
레알: ㄹㅇ (진짜, 매우)
응 아니야 / 찐따 / 클라스 있다 / 빠꾸없다
ㅋㅋ루삥뽕 (혹은 ㅋㅋㄹㅃㅃ)
ㄹㅇ꿀잼인데 안 쓰면 개에바터지는각 ㅇㅈ?''';
      case WritingStyle.otaku:
        return '''
건강 상의 문제랄까 연재를 잠시 쉰다죠.. (먼산)
저를 기다려 주시는 분들께 죄송합니다만, 아무래도 글을 쓸 수 있을 만큼의 건강 상태가 아니기 때문에… 쿨럭… (다시 먼산)
랄까 도… 돌은 내려놔 주세요.
''';
      case WritingStyle.middleSchool:
        return '크큭...내 안의 흑염룡이 미쳐 날뛰는군...';
      case WritingStyle.didItStyle:
        return '''
밥 먹었삼? 난 먹었삼.
안 가봤삼? 난 가봤삼.
''';
    }
  }
}

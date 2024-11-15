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
예시:
ヌr ㄱ l 0F앙♡ ●살콩하l언l
ol뿐짓하lㅂr0 ol-l교장0l > <♥
♥ 우zl nㅓuБ님 nㅋㅎH요오 ε
번역: 자기야~ 사랑해요~
 이쁜 짓 해봐, 애교쟁이야~
 우리 서방님! 사랑해요~
예시:
LH□r음 알면 L┤ュzㅓ면 안도l는 ㄱㅓ잖Oㅏ ‥ ㄴHㄱr ‥LH ㄱr 널 잊Oㅓㄱrヱ 있c-ㅣl ‥ ㄴr0ㅓ떻ㄱㅓl [ ¿ ? ]ュn z点0 l ㄴ 무 좋은c-ll LH ュn z点 우lㅎHn 뭘 ㅎH주ヱ 싶은ㄷㅓl‥ LHㄱr ュn z点을 우lㅎH ㅎH줄水 있는건 ュ달l 떠Lr는ㄱㅓ 뿐 0l ℉ ‥ Lㅏ 진심으로 ュ오ㅃㅏ n zБㅎH ‥ ♥ ュ런cㅔ ュ 오빤 LH맘 몰zr주는 ur보 ℉‥ ュzHnㅓ 온Hㅈl cㅓ 끌zl는 LHㄱr cㅓ ㅂr보같oH ‥〃 nrzБ한단말 ‥ ュ렇ㄱㅓl 쉽ㄱㅓ1 던ダl는 Lㅔㄱr □ l워
번역:내 마음 알면 너 그러면 안 되는 거잖아 ‥ 내가 ‥ 내가 널 잊어가고 있데.. 나 어떻게? 그 사람이 너무 좋은데 내가 그 사람 위해서 뭘 해주고 싶은데 내가 그 사람을 위해 해줄 수 있는 건 그댈 떠나는 거뿐이야‥ 나 진심으로 그 오빠 사랑해 그런데 그 오빤 내 맘 몰라주는 바보야 그래서 왠지 더 끌리는 내가 더 바보 같아 사랑한단 말... 그렇게 쉽게 던지는 네가 미워!
웃음: ^^ ^.^ ^-^ ^_^ ^3^ ^0^
화남: ㅡㅡ ㅡㅡ^ -_- =_= -3- -0- ㅡ,ㅡ
멀뚱,놀람: ㅇ_ㅇ
흥분: +_+ *-*
당황: 상황에 맞게 위의 이모티콘에 ;; 땀표시를 붙인다
ex)^^; ㅇ_ㅇ;;
좌절: OTL
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
사스가 : 역시
응 삼성 스타일러

''';
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

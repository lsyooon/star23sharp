import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // 아이디 및 닉네임 중복 여부 상태 변수
  bool isIdAvailable = false;
  bool isNicknameAvailable = false;

  Future<void> checkIdAvailability() async {
    // 아이디 중복 검사 로직 구현
    bool response =
        await UserService.checkDuplicateId(0, idController.text.trim());
    if(response){
      ErrorSnackbar.show("아이디가 중복됩니다. 다른 아이디를 입력하세요.");
    }
    setState(() {
      isIdAvailable = !response;
    });
  }

  Future<void> checkNicknameAvailability() async {
    // 닉네임 중복 검사 로직 구현
    bool response =
        await UserService.checkDuplicateId(1, nicknameController.text.trim());
    if(response){
      ErrorSnackbar.show("닉네임이 중복됩니다. 다른 닉네임을 입력하세요.");
    }
    setState(() {
      isNicknameAvailable = !response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.68,
            child: Image.asset(
              themeProvider.subBg,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "회원가입",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.title,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSignUpForm(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(20),
      width: UIhelper.deviceWidth(context) * 0.8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextFieldWithBtn(
                "아이디", "영어, 숫자(3~16자)", idController, isIdAvailable, checkIdAvailability),
            _buildTextFieldWithBtn("닉네임", "영어, 숫자, 한글 (2~16자)", nicknameController,
                isNicknameAvailable, checkNicknameAvailability),
            _buildTextField("비밀번호", "영어, 숫자(6~16자)", passwordController, obscureText: true),
            _buildTextField("비밀번호 확인", "영어, 숫자(6~16자)", confirmPasswordController,
                obscureText: true),
            const SizedBox(height: 20),
            _buildSignUpButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithBtn(String label, String hintText, TextEditingController controller,
      bool isAvailable, Function onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: FontSizes.label,
                ),
              ),
              if (isAvailable) // 중복 검사 결과에 따라 체크 아이콘 표시
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Image.asset(
                    'assets/icon/check.png',
                    fit: BoxFit.cover,
                    width: 15,
                    height: 15
                  ),
                ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontSize: 20, // 텍스트 크기 설정
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => onPressed(), // 중복 검사 함수 호출
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "확인",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hintText, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: FontSizes.label,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: const TextStyle(
                  fontSize: 20, // 텍스트 크기 설정
                ),
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          onPressed: () async {
            // 회원가입 처리 로직 추가
            String memberId = idController.text.trim();
            String nickname = nicknameController.text.trim();
            String password = passwordController.text.trim();
            String confirmPassword = confirmPasswordController.text.trim();
            
            final RegExp idRegex = RegExp(r'^(?=.*[a-z0-9])[a-z0-9]{3,16}$');
            final RegExp nicknameRegex = RegExp(r'^(?=.*[a-z0-9가-힣])[a-z0-9가-힣]{2,16}$');
            final RegExp pwdRegex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z])[a-zA-Z0-9!@#$%^&*()._-]{6,16}$');
            
            bool isValidId = idRegex.hasMatch(memberId);
            bool isValidNickname = nicknameRegex.hasMatch(nickname);
            bool isValidPwd = pwdRegex.hasMatch(password);
            logger.d("$memberId $nickname $password");
            logger.d("$isValidId $isValidNickname $isValidPwd");
            if(!isValidId){
              ErrorSnackbar.show("아이디는 3자 이상 16자 이하, 영어(소문자) 또는 숫자로 이루어져야 합니다.");
              setState(() {
                isIdAvailable = false;
              });
            }
            if(!isValidNickname){
              ErrorSnackbar.show("닉네임은 2자 이상 16자 이하, 영어, 숫자 또는 한글로 이루어져야 합니다.");
              setState(() {
                isNicknameAvailable = false;
              });
            }
            if(!isValidPwd){
              ErrorSnackbar.show("비밀번호는 6자 이상 16자 이하, 영어와 숫자로 이루어져야 합니다.");
            }

            if (memberId.isEmpty ||
                nickname.isEmpty ||
                password.isEmpty ||
                confirmPassword.isEmpty) {
              ErrorSnackbar.show("모든 필드를 입력해야 합니다.");
              logger.d("필드입력");
              return;
            }

            if (!isIdAvailable) {
              logger.d("아이디 입력");
              // ErrorSnackbar.show("아이디를 다시 확인해주세요.");
              setState(() {
                isIdAvailable = false;
              });
              return;
            }

            if (!isNicknameAvailable) {
              // ErrorSnackbar.show("닉네임을 다시 확인해주세요.");
              logger.d("닉네임 입력");
              setState(() {
                isNicknameAvailable = false;
              });
              return;
            }

            if (password != confirmPassword ) {
              ErrorSnackbar.show("비밀번호가 일치하지 않습니다.");
              logger.d("비번 입력");
              return;
            }

            bool response =
                await UserService.signup(memberId, password, nickname);
            if (response) {
              // 회원가입 완료
              ErrorSnackbar.show("회원가입이 완료되었습니다!", textColor: Colors.white);
              Navigator.pushNamed(context, '/home');
            } else {
              // 회원가입 실패
              ErrorSnackbar.show("회원가입에 실패했습니다. 다시 시도해주세요.");
              logger.d("실패");
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            '회원가입',
            style: TextStyle(fontSize: FontSizes.label, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

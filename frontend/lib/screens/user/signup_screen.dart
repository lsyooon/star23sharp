import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 배경 이미지
        Center(
          child: SizedBox(
            width: UIhelper.deviceWidth(context) * 0.85,
            height: UIhelper.deviceHeight(context) * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
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
                        fontWeight: FontWeight.bold),
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
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController nicknameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // 아이디 및 닉네임 중복 여부를 저장할 변수
    bool isUsernameAvailable = false;
    bool isNicknameAvailable = false;

    void checkIdAvailability() {
      // 아이디 중복 검사 로직 구현
      print("아이디 중복 검사 실행");
      // isUsernameAvailable = true; // 예시
    }

    void checkNicknameAvailability() {
      // 닉네임 중복 검사 로직 구현
      print("닉네임 중복 검사 실행");
      // isNicknameAvailable = true; // 예시
    }

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
            _buildTextFieldWithBtn("아이디", usernameController, isAvailable: () {
              checkIdAvailability();
            }),
            _buildTextFieldWithBtn("닉네임", nicknameController, isAvailable: () {
              checkNicknameAvailability();
            }),
            _buildTextField("비밀번호", passwordController, obscureText: true),
            _buildTextField("비밀번호 확인", confirmPasswordController, obscureText: true),
            const SizedBox(height: 20),
            _buildSignUpButton(context, usernameController, nicknameController, passwordController, confirmPasswordController, isUsernameAvailable, isNicknameAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithBtn(String label, TextEditingController controller, {bool obscureText = false, required Function isAvailable}) {
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFA292EC).withOpacity(0.4),
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
            ),
            const SizedBox(width: 10), // TextField와 버튼 사이의 간격
            TextButton(
              onPressed: () {
                isAvailable(); // 중복 검사 함수 호출
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFA292EC).withOpacity(0.4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "확인",
                style: TextStyle(color: Colors.white, fontSize: FontSizes.body),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
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
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFA292EC).withOpacity(0.4),
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

  Widget _buildSignUpButton(BuildContext context, TextEditingController usernameController, TextEditingController nicknameController, TextEditingController passwordController, TextEditingController confirmPasswordController, bool isUsernameAvailable, bool isNicknameAvailable) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA292EC).withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          onPressed: () {
            // 유효성 검사
            String username = usernameController.text.trim();
            String nickname = nicknameController.text.trim();
            String password = passwordController.text.trim();
            String confirmPassword = confirmPasswordController.text.trim();

            if (username.isEmpty || nickname.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
              _showErrorDialog(context, '모든 필드를 입력해야 합니다.');
              return;
            }

            if (!isUsernameAvailable) {
              _showErrorDialog(context, '아이디가 중복됩니다. 다른 아이디를 입력하세요.');
              return;
            }

            if (!isNicknameAvailable) {
              _showErrorDialog(context, '닉네임이 중복됩니다. 다른 닉네임을 입력하세요.');
              return;
            }

            if (password != confirmPassword) {
              _showErrorDialog(context, '비밀번호가 일치하지 않습니다.');
              return;
            }

            // 회원가입 처리 로직 추가
            // 예: API 호출
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류', style: TextStyle(fontSize: 20,),),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

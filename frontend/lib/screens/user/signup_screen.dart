import 'package:flutter/material.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // 아이디 및 닉네임 중복 여부 상태 변수
  bool isIdAvailable = false;
  bool isNicknameAvailable = false;

  Future<void> checkIdAvailability() async {
    // 아이디 중복 검사 로직 구현
    bool response = await UserService.checkDuplicateId(0, idController.text.trim());
    setState(() {
      isIdAvailable = !response;
    });
  }

  Future<void> checkNicknameAvailability() async {
    // 닉네임 중복 검사 로직 구현
    bool response = await UserService.checkDuplicateId(1, nicknameController.text.trim());
    setState(() {
      isNicknameAvailable = !response;
    });
  }

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
            _buildTextFieldWithBtn("아이디", idController, isIdAvailable, checkIdAvailability),
            _buildTextFieldWithBtn("닉네임", nicknameController, isNicknameAvailable, checkNicknameAvailability),
            _buildTextField("비밀번호", passwordController, obscureText: true),
            _buildTextField("비밀번호 확인", confirmPasswordController, obscureText: true),
            const SizedBox(height: 20),
            _buildSignUpButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithBtn(String label, TextEditingController controller, bool isAvailable, Function onPressed) {
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
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFA292EC).withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => onPressed(), // 중복 검사 함수 호출
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFA292EC).withOpacity(0.4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildTextField(String label, TextEditingController controller,
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

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA292EC).withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          onPressed: () async {
            // 회원가입 처리 로직 추가
            String memberId = idController.text.trim();
            String nickname = nicknameController.text.trim();
            String password = passwordController.text.trim();
            String confirmPassword = confirmPasswordController.text.trim();

            if (memberId.isEmpty ||
                nickname.isEmpty ||
                password.isEmpty ||
                confirmPassword.isEmpty) {
              // _showErrorDialog(context, '모든 필드를 입력해야 합니다.');
              logger.d("필드입력");
              return;
            }

            if (!isIdAvailable) {
              // _showErrorDialog(context, '아이디가 중복됩니다. 다른 아이디를 입력하세요.');
              logger.d("아이디 입력");
              return;
            }

            if (!isNicknameAvailable) {
              // _showErrorDialog(context, '닉네임이 중복됩니다. 다른 닉네임을 입력하세요.');
              logger.d("니네임 입력");
              return;
            }

            if (password != confirmPassword) {
              // _showErrorDialog(context, '비밀번호가 일치하지 않습니다.');
              logger.d("비번 입력");
              return;
            }

            bool response = await UserService.signup(memberId, password, nickname);
            if(response){
              // 회원가입 완료
              Navigator.pushNamed(context, '/home');
            }else{
              // 회원가입 실패
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

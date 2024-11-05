import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:star23sharp/widgets/index.dart';

class StarFormScreen extends StatefulWidget {
  const StarFormScreen({super.key});

  @override
  _StarFormScreenState createState() => _StarFormScreenState();
}

class _StarFormScreenState extends State<StarFormScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode(); // 메시지 입력에 대한 FocusNode 추가

  final List<String> _recipients = [];
  File? _selectedImage; // 선택된 이미지를 저장할 변수
  final ImagePicker _picker = ImagePicker(); // ImagePicker 인스턴스

  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  int maxCharacters = 100;
  final int maxRecipients = 5; // 최대 받는 사람 수 제한

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _validateNickname(String nickname) {
    // 정규식: 영어, 숫자, 한글로 구성된 2자 이상 16자 이하
    final nicknameRegExp = RegExp(r'^(?=.*[a-z0-9가-힣])[a-z0-9가-힣]{2,16}$');
    return nicknameRegExp.hasMatch(nickname);
  }

  @override
  void initState() {
    super.initState();

    // 메시지 입력 창에 포커스가 들어올 때 스크롤을 제일 아래로 내림
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _addRecipient(String nickname) {
    if (nickname.isNotEmpty && !_recipients.contains(nickname)) {
      if (_validateNickname(nickname)) {
        if (_recipients.length < maxRecipients) {
          setState(() {
            _recipients.add(nickname);
          });
          _nicknameController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('받는 사람은 최대 $maxRecipients명까지 추가할 수 있습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  '닉네임은 2자 이상 16자 이하, 영어/숫자/한글만 가능합니다. 한글 초성 및 모음은 허용되지 않습니다.')),
        );
      }
    }
  }

  void _removeRecipient(String nickname) {
    setState(() {
      _recipients.remove(nickname);
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 선택한 이미지를 _selectedImage에 저장
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null; // 이미지를 삭제
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white, // 배경색 추가

        child: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    color: const Color(0xffA292EC),
                    child: const Text("별 만들기"),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: Stack(
                        children: [
                          if (_selectedImage != null)
                            Positioned.fill(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (_selectedImage != null)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red[700],
                                ),
                                onPressed: _removeImage,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.white38),
                                ),
                              ),
                            )
                          else
                            const Center(child: Icon(Icons.add)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 받는 사람 입력
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: '받는 사람',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_nicknameController.text.isNotEmpty) {
                            _addRecipient(_nicknameController.text);
                          }
                        },
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return '받는 사람의 닉네임을 입력해주세요.';
                      // }
                      if (!(value == null || value.isEmpty) &&
                          !_validateNickname(value)) {
                        return '닉네임은 2자 이상 16자 이하, 영어/숫자/한글만 가능합니다.';
                      }
                      if (_recipients.contains(value)) {
                        return '이미 추가된 닉네임입니다.';
                      }
                      return null;
                    },
                    onFieldSubmitted: _addRecipient,
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: _recipients.map((nickname) {
                      return Chip(
                        label: Text(nickname),
                        onDeleted: () => _removeRecipient(nickname),
                      );
                    }).toList(),
                  ),
                  // 제목 입력
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '제목을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 메시지 입력
                  TextFormField(
                    controller: _messageController,
                    focusNode: _messageFocusNode, // 포커스 노드 설정

                    maxLines: 5,
                    maxLength: maxCharacters,
                    decoration: InputDecoration(
                      labelText: '메시지를 입력해주세요',
                      floatingLabelBehavior: _messageController.text.isEmpty
                          ? FloatingLabelBehavior.always
                          : FloatingLabelBehavior.never,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '메시지를 입력해주세요.';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _messageController.text.length > maxCharacters
                          ? '최대 글자수를 초과했습니다.'
                          : '남은 글자 수: ${maxCharacters - _messageController.text.length}',
                      style: TextStyle(
                        color: _messageController.text.length > maxCharacters
                            ? const Color.fromARGB(255, 174, 57, 49)
                            : Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // 버튼

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: SizedBox(
                      width: UIhelper.deviceWidth(context) * 0.85,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // 유효성 검사 통과 시 전송 로직 추가
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(162, 146, 236, 40),
                        ),
                        child: const Text('다음'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

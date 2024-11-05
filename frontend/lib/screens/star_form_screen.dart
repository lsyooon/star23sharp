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
  final List<String> _recipients = [];
  File? _selectedImage; // 선택된 이미지를 저장할 변수
  final ImagePicker _picker = ImagePicker(); // ImagePicker 인스턴스

  int maxCharacters = 100;
  final int maxRecipients = 5; // 최대 받는 사람 수 제한

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addRecipient(String nickname) {
    if (nickname.isNotEmpty && !_recipients.contains(nickname)) {
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white, // 배경색 추가

        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 이미지 업로드 버튼
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.add),
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
                    if (value == null || value.isEmpty) {
                      return '받는 사람의 닉네임을 입력해주세요.';
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
                const Divider(),
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
                  maxLines: 5,
                  maxLength: maxCharacters,
                  decoration: const InputDecoration(
                    labelText: '메시지를 입력해주세요',
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
                      '남은 글자 수: ${maxCharacters - _messageController.text.length}'),
                ),
                const SizedBox(height: 16),
                // 버튼
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 유효성 검사 통과 시 전송 로직 추가
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                  ),
                  child: const Text('별꾸미기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

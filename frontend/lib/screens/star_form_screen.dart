import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';

import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/services/index.dart';

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
  List<dynamic> nicBook = [];
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

  bool _sendToAll = false; // "모든 사용자에게 보내기" 체크박스 상태
  @override
  void initState() {
    super.initState();

    // 메시지 입력 창에 포커스가 들어올 때 스크롤을 제일 아래로 내림
    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
    fetchNicbooks();
  }

  Future<void> fetchNicbooks() async {
    try {
      // API 호출
      final response = await UserService.getNicbook();
      if (response != null) {
        setState(() {
          nicBook = response.map((item) {
            return {
              "nickname": item["nickname"],
              "name": item["name"],
              "id": item["id"],
            };
          }).toList();
        });
      }
    } catch (e) {
      logger.e("Error in fetchNicbooks $e");
    }
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

  void _addRecipient(String nickname) async {
    if (nickname.isNotEmpty) {
      final userNickname = Provider.of<UserProvider>(
              AppGlobal.navigatorKey.currentContext!,
              listen: false)
          .getNickname;
      if (!_recipients.contains(nickname) && userNickname != nickname) {
        if (_validateNickname(nickname)) {
          // 닉네임 중복 검사
          logger.d("닉네임 : $nickname");
          logger.d("닉네임controller : ${_nicknameController.text}");
          bool isDuplicate = await UserService.checkDuplicateId(1, nickname);
          // 최대 인원수 제한 확인 후 추가
          if (_recipients.length < maxRecipients) {
            if (isDuplicate) {
              setState(() {
                _recipients.add(nickname);
                _nicknameController.clear();
              });
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('존재하지 않는 닉네임입니다. 닉네임을 확인해주세요.')),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('받는 사람은 최대 $maxRecipients명까지 추가할 수 있습니다.')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      '닉네임은 2자 이상 16자 이하, 영어/숫자/한글만 가능합니다. 한글 초성 및 모음은 허용되지 않습니다.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('추가할 수 없는 닉네임입니다.')),
          );
        }
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

  void _saveMessage() {
    if (_formKey.currentState!.validate()) {
      logger.d(_recipients);
      int receiverType = 0;
      if (_sendToAll) {
        receiverType = 3;
      } else if (_recipients.length > 1) {
        receiverType = 1;
      } else {
        receiverType = 0;
      }

      //TODO - group 지정
      Provider.of<MessageFormProvider>(context, listen: false).saveMessageData(
        title: _titleController.text,
        content: _messageController.text,
        receivers: _recipients,
        contentImage: _selectedImage,
        receiverType: receiverType,
      );

      Navigator.pushNamed(context, '/message_style_editor'); // 문체 변경 페이지로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    String? nickname = ModalRoute.of(context)!.settings.arguments as String?;
    if(nickname != null){
      _recipients.add(nickname);
    }
    final isTreasureStar =
        Provider.of<MessageFormProvider>(context, listen: false).isTeasureStar;
    final messageProvider =
        Provider.of<MessageFormProvider>(context, listen: false);

    return Center(
      child: Container(
        width: UIhelper.deviceWidth(context) * 0.85,
        height: UIhelper.deviceHeight(context) * 0.67,
        color: Colors.white, // 배경색 추가

        child: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                    color: const Color(0xFFA292EC),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    child: Container(
                      width: UIhelper.deviceWidth(context) * 0.85,
                      alignment: Alignment.center,
                      child: const Text(
                        '쪽지 보내기',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!, width: 1), // 테두리 색과 두께 설정
                            borderRadius: BorderRadius.circular(12), // 둥근 테두리 설정
                          ),
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
                      // "모든 사용자에게 보내기" 체크박스
                      if (isTreasureStar)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _sendToAll,
                              onChanged: (bool? value) {
                                setState(() {
                                  _sendToAll = value ?? false;
                                  if (_sendToAll) {
                                    _nicknameController.clear();
                                  }
                                });
                              },
                            ),
                            const Text('모든 사용자에게 보내기'),
                          ],
                        ),
                      Row(
                        children: [
                          const Text("받는 사람", style: TextStyle(fontSize: FontSizes.body, color: Color(0xff747474)),),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: Tooltip(
                              message: '''받는 사람의 닉네임을 입력하세요.
                친구 목록에 닉네임을 추가하면 좀 더 쉽게 닉네임을 검색할 수 있습니다!
                              ''',
                              showDuration: const Duration(seconds: 3),
                              margin: const EdgeInsets.only(left: 90),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              triggerMode: TooltipTriggerMode.tap,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              textStyle: const TextStyle(
                                  color: Colors.white), // 툴팁 텍스트 스타일
                
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.grey[500]!,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return nicBook.where((option) {
                              return !_recipients.contains(option['nickname']);
                            }).cast<Map<String, dynamic>>();
                          }
                
                          return nicBook.where((option) {
                            final nickname =
                                option['nickname']?.toLowerCase() ?? '';
                            final name = option['name']?.toLowerCase() ?? '';
                            final input = textEditingValue.text.toLowerCase();
                
                            return (!_recipients.contains(option['nickname'])) &&
                                (nickname.contains(input) || name.contains(input));
                          }).cast<Map<String, dynamic>>();
                        },
                        displayStringForOption: (option) => option['nickname'],
                        onSelected: (Map<String, dynamic> selection) {
                          if (!_recipients.contains(selection['nickname'])) {
                            logger.d(
                                "Autocomplete 선택된 닉네임: ${selection['nickname']}");
                            _addRecipient(selection['nickname'].trim());
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _nicknameController.text = ''; // 입력 필드 초기화
                            });
                          }
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          // 동기화: 컨트롤러 내용을 수정
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_nicknameController != textEditingController) {
                              textEditingController.text = _nicknameController.text;
                            }
                          });
                
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            enabled: !_sendToAll,
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty &&
                                  !_recipients.contains(value)) {
                                logger.d("TextFormField 입력된 값 추가: $value");
                                _addRecipient(value.trim());
                                textEditingController.clear();
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), // 둥근 테두리
                                borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 연한 회색 테두리
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[500]!, width: 1), // 포커스 상태에서의 테두리 색상
                              ),
                              // 활성화 상태에서 테두리 설정
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 활성화 상태에서의 테두리 색상
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      if (textEditingController.text.isNotEmpty &&
                                          !_recipients.contains(
                                              textEditingController.text)) {
                                        logger.d(
                                            "TextFormField 추가: ${textEditingController.text.trim()}");
                                        _addRecipient(
                                            textEditingController.text.trim());
                                        textEditingController.clear();
                                      }
                                    },
                                  ),
                                  
                                ],
                              ),
                            ),
                            validator: (value) {
                              if (_recipients.isEmpty && !_sendToAll) {
                                return '받는 사람은 한명 이상이어야 합니다.';
                              }
                              return null;
                            },
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<Map<String, dynamic>> onSelected,
                            Iterable<Map<String, dynamic>> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: UIhelper.deviceWidth(context) * 0.7,
                                  maxHeight: options.isNotEmpty
                                      ? (options.length * 67.0)
                                          .clamp(0.0, 240.0) // 동적 높이 설정
                                      : 0.0,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option['nickname']),
                                      subtitle: Text(
                                        option['name'],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
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
                      const SizedBox(height: 5,),
                      // 제목 입력
                      const Text("제목", style: TextStyle(fontSize: FontSizes.body, color: Color(0xff747474)),),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // 둥근 테두리
                            borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 연한 회색 테두리
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[500]!, width: 1), // 포커스 상태에서의 테두리 색상
                          ),
                          // 활성화 상태에서 테두리 설정
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 활성화 상태에서의 테두리 색상
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '제목을 입력해주세요.';
                          }
                
                          if (value.length > 15) {
                            return '제목은 15자 이하로 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 5),
                      // 메시지 입력
                      const Text("내용", style: TextStyle(fontSize: FontSizes.body, color: Color(0xff747474)),),
                      TextFormField(
                        controller: _messageController,
                        focusNode: _messageFocusNode, // 포커스 노드 설정
                        maxLines: 5,
                        maxLength: maxCharacters,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력해주세요',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // 둥근 테두리
                            borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 연한 회색 테두리
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[500]!, width: 1), // 포커스 상태에서의 테두리 색상
                          ),
                          // 활성화 상태에서 테두리 설정
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:  BorderSide(color: Colors.grey[300]!, width: 1), // 활성화 상태에서의 테두리 색상
                          ),
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
                            onPressed: _saveMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA292EC),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              '다음',
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

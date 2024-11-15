import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';

import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class NickbookScreen extends StatefulWidget {
  const NickbookScreen({super.key});

  @override
  NickbookScreenState createState() => NickbookScreenState();
}

class NickbookScreenState extends State<NickbookScreen> {
  List<dynamic> nicbooks = [];
  bool showButton = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNicbooks();
  }

  Future<void> fetchNicbooks() async {
    try {
      // API 호출
      final response = await UserService.getNicbook();
      if (response != null) {
        setState(() {
          nicbooks = response.map((item) {
            return {
              "nickname": item["nickname"],
              "name": item["name"],
              "id": item["id"],
            };
          }).toList();
          isLoading = false;
          showButton = nicbooks.isEmpty;
        });
      }
    } catch (e) {
      logger.e("Error in fetchNicbooks $e");
    }
  }

  void showAddOrEditDialog(Map<String, dynamic>? nickbooks) {
    TextEditingController nameController =
        TextEditingController(text: nickbooks?['name']);
    TextEditingController nicknameController =
        TextEditingController(text: nickbooks?['nickname']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nickbooks == null ? "닉네임 추가" : "닉네임 편집"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "별칭"),
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: "닉네임"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    nicknameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("입력을 확인해주세요")),
                  );
                  return;
                }
                // 중복 닉네임 확인
                final duplicate = nicbooks.any((item) =>
                    item['nickname'] == nicknameController.text &&
                    item != nickbooks);

                if (duplicate) {
                  ErrorSnackbar.show("이미 추가된 닉네임입니다");

                  return;
                }
                bool response = await UserService.checkDuplicateId(
                    1, nicknameController.text);
                if (!response) {
                  ErrorSnackbar.show("존재하지 않는 닉네임입니다");
                  return;
                }

                if (nickbooks == null) {
                  // 닉네임 추가
                  try {
                    final newNickbook = {
                      "name": nameController.text.trim(),
                      "nickname": nicknameController.text.trim(),
                    };
                    final addedNickbook =
                        await UserService.addNicbook(newNickbook);
                    setState(() {
                      nicbooks.add(addedNickbook);
                      showButton = nicbooks.isEmpty;
                    });
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("닉네임이 추가되었습니다.")),
                    // );
                  } catch (e) {}
                } else {
                  // 닉네임 수정
                  try {
                    final updatedNickbook = {
                      "name": nameController.text,
                      "nickname": nicknameController.text,
                    };
                    await UserService.updateNicbook(
                        nickbooks['id'], updatedNickbook);
                    setState(() {
                      nickbooks['name'] = nameController.text;
                      nickbooks['nickname'] = nicknameController.text;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("닉네임이 수정되었습니다.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("수정 실패: $e")),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text(nickbooks == null ? "추가" : "저장"),
            ),
          ],
        );
      },
    );
  }

  void deleteNickname(Map<String, dynamic> nickbooks) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${nickbooks["nickname"]} 즐겨찾기 해제"),
          content: const Text("즐겨찾기를 하면 쪽지 쓰기에서 편리하게 상대방 닉네임을 적을 수 있어요!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await UserService.deleteNicbook(nickbooks['id']);
                  setState(() {
                    nicbooks.remove(nickbooks);
                    showButton = nicbooks.isEmpty;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("닉네임이 삭제되었습니다.")),
                  );
                } catch (e) {}
                Navigator.pop(context);
              },
              child: const Text("해제"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "닉네임 즐겨찾기",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSizes.title,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: UIhelper.deviceWidth(context) * 0.8,
                height: UIhelper.deviceHeight(context) * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E1E1).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: showButton
                    ? Center(
                        child: ElevatedButton(
                          onPressed: () => showAddOrEditDialog(null),
                          child: const Text("닉네임 추가"),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: nicbooks.length,
                          itemBuilder: (context, index) {
                            final nic = nicbooks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                tileColor: Colors.transparent,
                                title: Text(nic['name']),
                                subtitle: Text(nic['nickname']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => showAddOrEditDialog(nic),
                                      child: Image.asset(
                                        'assets/icon/edit_icon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    InkWell(
                                      onTap: () => deleteNickname(nic),
                                      child: Image.asset(
                                        'assets/icon/delete_icon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
              )
            ],
          ),
        ),
        if (!showButton)
          Positioned(
            bottom: 70,
            right: 40,
            child: FloatingActionButton(
              onPressed: () => showAddOrEditDialog(null),
              child: const Icon(Icons.person_add_alt_rounded),
            ),
          ),
      ],
    );
  }
}

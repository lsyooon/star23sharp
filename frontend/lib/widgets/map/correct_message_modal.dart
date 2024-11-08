import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class CorrectMessageModal extends StatelessWidget {
  final VoidCallback onNoteButtonPressed;
  final Map<String, dynamic> markerData;

  const CorrectMessageModal({
    required this.onNoteButtonPressed,
    required this.markerData,
    super.key,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onNoteButtonPressed,
    required Map<String, dynamic> markerData,
  }) {
    showDialog(
      context: context,
      builder: (_) => CorrectMessageModal(
        onNoteButtonPressed: onNoteButtonPressed,
        markerData: markerData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);

    return Stack(
      children: [
        Positioned(
          top: deviceHeight * 0.1,
          left: deviceWidth * 0.01,
          right: deviceWidth * 0.01,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: deviceWidth,
              height: deviceHeight * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF9588E7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // 오른쪽 상단 닫기 버튼
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 32,
                        ),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text(
                                    "정답입니다!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  if (markerData['hint_image_first'] != null)
                                    Center(
                                      child: SizedBox(
                                        width: 320,
                                        height: 200,
                                        child: markerData["hint_image_first"] !=
                                                null
                                            ? Image.network(
                                                markerData[
                                                    "hint_image_first"], // hint_image_first URL을 네트워크 이미지로 표시
                                                fit: BoxFit
                                                    .cover, // 이미지가 컨테이너에 맞게 조정되도록 설정
                                              )
                                            : const Icon(
                                                Icons
                                                    .image, // 이미지를 표시할 수 없을 때 대체 아이콘
                                                color: Colors.grey,
                                                size: 50,
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 쪽지 확인하러 가기 버튼
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              onNoteButtonPressed();
                            },
                            child: const Text(
                              "쪽지 확인하러 가기",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
      ],
    );
  }
}

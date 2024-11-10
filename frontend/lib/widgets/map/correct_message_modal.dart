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

  void _showImageModal(BuildContext context, String imageUrl) {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    height: deviceHeight * 0.35,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "확인",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                          height: 24,
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
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (markerData['hint_image_first'] !=
                                          null) {
                                        _showImageModal(
                                          context,
                                          markerData['hint_image_first'],
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: deviceWidth * 0.65,
                                      height: deviceHeight * 0.28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const Text(
                                                "정답 사진 :",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              if (markerData[
                                                      'hint_image_first'] !=
                                                  null)
                                                Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: SizedBox(
                                                      width: deviceWidth * 0.5,
                                                      height:
                                                          deviceWidth * 0.35,
                                                      child: markerData[
                                                                  "hint_image_first"] !=
                                                              null
                                                          ? Image.network(
                                                              markerData[
                                                                  "hint_image_first"],
                                                              fit: BoxFit.cover,
                                                            )
                                                          : const Icon(
                                                              Icons.image,
                                                              color:
                                                                  Colors.grey,
                                                              size: 50,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              const Center(
                                                child: Text(
                                                  "사진을 누르면 크게 볼 수 있어요!",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              onNoteButtonPressed();
                            },
                            child: const Text(
                              "쪽지 확인",
                              style: TextStyle(
                                fontSize: 24,
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

import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class IncorrectMessageModal extends StatelessWidget {
  final VoidCallback onRetry;
  final Map<String, dynamic> markerData;

  const IncorrectMessageModal({
    required this.onRetry,
    required this.markerData,
    super.key,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onRetry,
    required Map<String, dynamic> markerData,
  }) {
    showDialog(
      context: context,
      builder: (_) => IncorrectMessageModal(
        onRetry: onRetry,
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
                                  const Text(
                                    "틀렸습니다",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: 270,
                                      height: 150,
                                      child:
                                          markerData["dot_hint_image"] != null
                                              ? Image.network(
                                                  markerData["dot_hint_image"],
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                  size: 50,
                                                ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text(
                                    "다시 시도해 주세요!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 다시 찍기 버튼
                        Container(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              onRetry();
                            },
                            child: const Text(
                              "다시 찍기",
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

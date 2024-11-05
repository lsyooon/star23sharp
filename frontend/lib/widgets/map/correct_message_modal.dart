import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class CorrectMessageModal extends StatelessWidget {
  final VoidCallback onNoteButtonPressed;

  const CorrectMessageModal({required this.onNoteButtonPressed, Key? key})
      : super(key: key);

  static void show(BuildContext context,
      {required VoidCallback onNoteButtonPressed}) {
    showDialog(
      context: context,
      builder: (_) =>
          CorrectMessageModal(onNoteButtonPressed: onNoteButtonPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: UIhelper.deviceHeight(context) * 0.18,
          left: UIhelper.deviceWidth(context) * 0.1,
          right: UIhelper.deviceWidth(context) * 0.1,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(
              width: UIhelper.deviceWidth(context) * 0.8,
              child: Container(
                height: UIhelper.deviceHeight(context) * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFF9588E7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // X 버튼 영역
                    Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.all(8),
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
                    // 내용
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "정답입니다!",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "맞춘 쪽지를 확인해 보세요!",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 쪽지 확인하러 가기 버튼 영역
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          onNoteButtonPressed();
                        },
                        child: const Text(
                          "쪽지 확인하러 가기",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

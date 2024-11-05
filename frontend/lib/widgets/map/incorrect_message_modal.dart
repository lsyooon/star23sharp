import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

class IncorrectMessageModal extends StatelessWidget {
  final VoidCallback onRetry;

  const IncorrectMessageModal({required this.onRetry, Key? key})
      : super(key: key);

  static void show(BuildContext context, {required VoidCallback onRetry}) {
    showDialog(
      context: context,
      builder: (_) => IncorrectMessageModal(onRetry: onRetry),
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
              width: UIhelper.deviceWidth(context) * 0.4,
              child: Container(
                height: UIhelper.deviceHeight(context) * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFF9588E7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // X 버튼
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
                            "틀렸습니다",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "다시 시도해 주세요.",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 다시 찍기 버튼
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRetry();
                        },
                        child: const Text(
                          "다시 찍기",
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

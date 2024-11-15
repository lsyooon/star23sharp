import 'package:flutter/material.dart';
import 'package:star23sharp/widgets/index.dart';

void showImageModal(BuildContext context, String  image) {
  final deviceWidth = UIhelper.deviceWidth(context);
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
                  child: SizedBox(
                    width: deviceWidth * 0.9,
                    child: InteractiveViewer(
                      maxScale: 5.0, // 최대 확대 배율
                      minScale: 1.0,
                      child: Image.network(
                        image,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagePreviewCard extends StatelessWidget {
  final Uint8List? imageData;
  final File? fileImage;

  const ImagePreviewCard({
    Key? key,
    this.imageData,
    this.fileImage,
  }) : super(key: key);

  void _showPixelizedImageModal(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    if (imageData != null) {
      showDialog(
        context: context,
        barrierDismissible: true, // 다른 부분을 눌렀을 때 닫히도록 설정
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // 모달 닫기
            },
            child: Container(
              color: Colors.black.withOpacity(0.8), // 배경 색 설정
              child: GestureDetector(
                onTap: () {}, // 내부 클릭 시 닫히지 않도록 방지
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: deviceWidth * 0.8,
                          height: deviceHeight * 0.5,
                          child: Image.memory(
                            imageData!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showPixelizedImageModal(context),
      child: Stack(
        children: [
          Container(
            width: deviceWidth * 0.45,
            height: deviceWidth * 0.45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageData != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      imageData!,
                      fit: BoxFit.cover,
                    ),
                  )
                : (fileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          fileImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 50,
                      )),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/map_service.dart';
import 'package:star23sharp/widgets/index.dart';

class HideStarScreen extends StatefulWidget {
  const HideStarScreen({super.key});

  @override
  State<HideStarScreen> createState() => _HideStarScreenState();
}

class _HideStarScreenState extends State<HideStarScreen> {
  bool isPreviewMode = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile?> images = [null, null];
  int _currentIndex = 0;
  Uint8List? _pixelizedImageData;
  final PageController _pageController = PageController();

  Future<void> _takePhoto(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        images[index] = photo;
      });
    }
  }

// 픽셀화된 이미지 전체 보기 모달
  void _showPixelizedImageModal() {
    if (_pixelizedImageData != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Image.memory(
                      _pixelizedImageData!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _pixelizeImages() async {
    if (images[0] != null) {
      final Uint8List? pixelizedResult = await MapService.pixelizeImage(
        file: File(images[0]!.path),
        kernelSize: 7,
        pixelSize: 48,
      );

      if (pixelizedResult != null) {
        setState(() {
          _pixelizedImageData = pixelizedResult;
        });

        final File dotHintImageFile =
            await uint8ListToFile(_pixelizedImageData!, 'dot_hint_image.png');

        final messageProvider =
            Provider.of<MessageFormProvider>(context, listen: false);

        messageProvider.setMessageFormType(type: '/map');

        final cachedLocation = await SharedPreferences.getInstance();
        final lat = cachedLocation.getDouble('lat');
        final lng = cachedLocation.getDouble('lng');

        messageProvider.saveMessageData(
          hintImageFirst: File(images[0]!.path),
          hintImageSecond: File(images[1]!.path),
          dotHintImage: File(dotHintImageFile.path),
          lat: lat!,
          lng: lng!,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미지 픽셀화에 실패했습니다.")),
        );
      }
    }
  }

  Future<File> uint8ListToFile(Uint8List data, String fileName) async {
    // 1. 저장할 디렉토리 경로 가져오기
    final directory = await getTemporaryDirectory();

    // 2. 저장할 파일 경로 설정
    final filePath = '${directory.path}/$fileName';

    // 3. 파일 생성 및 바이트 데이터 작성
    final file = File(filePath);
    await file.writeAsBytes(data);

    return file;
  }

  Widget _buildCaptureMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "내 별 숨기기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          width: UIhelper.deviceWidth(context) * 0.7,
          height: UIhelper.deviceHeight(context) * 0.4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              const Text(
                "사진을 두 장 찍어주세요",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 170,
                height: 170,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: List.generate(2, (index) {
                    return GestureDetector(
                      onTap: () {
                        _takePhoto(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: images[index] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(images[index]!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 50,
                              ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: _currentIndex == index
                                ? Colors.black
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (images[0] != null && images[1] != null) {
              await _pixelizeImages();
              setState(() {
                isPreviewMode = true;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("사진을 두 장 모두 찍어주세요."),
                ),
              );
            }
          },
          child: const Text("다음"),
        ),
      ],
    );
  }

  Widget _buildPreviewMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "내 별 숨기기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          width: UIhelper.deviceWidth(context) * 0.7,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              const Text(
                "힌트 사진\n 누르면 크게 확인할 수 있어요!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showPixelizedImageModal,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _pixelizedImageData != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 150,
                            child: Image.memory(
                              _pixelizedImageData!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : (images[0] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 150,
                                child: Image.file(
                                  File(images[0]!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 50,
                            )),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        setState(() {
                          isPreviewMode = false;
                          images[0] = null;
                          images[1] = null;
                          _currentIndex = 0;
                          _pixelizedImageData = null;
                        });
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pageController.jumpToPage(0);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "재촬영",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 다음 단계 기능 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "다음",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.67,
            child: Image.asset(
              'assets/img/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isPreviewMode ? _buildPreviewMode() : _buildCaptureMode(),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/map_service.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class HideStarScreen extends StatefulWidget {
  const HideStarScreen({super.key});

  @override
  State<HideStarScreen> createState() => _HideStarScreenState();
}

class _HideStarScreenState extends State<HideStarScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  bool isPreviewMode = false, isLoading = false;
  List<File?> images = [null, null];
  Uint8List? _pixelizedImageData;
  int _currentIndex = 0;
  String hintText = '';

  Future<void> _takePhoto(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        images[index] = File(photo.path);
      });
    }
  }

  // 픽셀화된 이미지 전체 보기 모달
  void _showPixelizedImageModal() {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);

    if (_pixelizedImageData != null) {
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
                            _pixelizedImageData!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pop(); // 명시적으로 모달 닫기
                      //   },
                      //   child: const Text("확인"),
                      // ),
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

  Future<bool> _pixelizeImages() async {
    final messageProvider =
        Provider.of<MessageFormProvider>(context, listen: false);
    logger.d('images[0]: ${images[0]}, images[1]: ${images[1]}');
    if (images[0] != null && images[1] != null) {
      try {
        final Uint8List? pixelizedResult = await MapService.pixelizeImage(
          file: images[0]!,
          kernelSize: 7,
          pixelSize: 48,
        );

        if (pixelizedResult != null) {
          setState(() {
            _pixelizedImageData = pixelizedResult;
          });

          final File dotHintImageFile =
              await uint8ListToFile(_pixelizedImageData!, 'dot_hint_image.png');

          messageProvider.setMessageFormType(type: 'hidestar');

          var position = await Geolocator.getCurrentPosition();
          // final cachedLocation = await SharedPreferences.getInstance();
          final lat = position.latitude;
          final lng = position.longitude;

          messageProvider.saveMessageData(
            hintImageFirst: File(images[0]!.path),
            hintImageSecond: File(images[1]!.path),
            dotHintImage: dotHintImageFile,
            lat: lat,
            lng: lng,
          );
          return true;
        } else {
          ErrorSnackbar.show("이미지 픽셀화에 실패했습니다");

          return false;
        }
      } catch (e) {
        ErrorSnackbar.show("권한이 없어 작업을 수행할 수 없습니다");

        logger.d("픽셀화 Error : $e");
        return false;
      }
    }
    return false;
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
          "보물 쪽지 숨기기",
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
                "힌트 사진을 두 장 찍어주세요",
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
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 2, // 두 장의 사진
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
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
                          : null,
                    );
                  },
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
            if (images[_currentIndex] == null) {
              // 현재 페이지의 사진을 찍음
              await _takePhoto(_currentIndex);

              if (_currentIndex == 0) {
                // 첫 번째 사진을 찍었으면 페이지를 전환
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else if (_currentIndex == 1 && images[0] != null) {
                // 두 번째 사진까지 찍었으면 픽셀화 진행
                setState(() {
                  isPreviewMode = true;
                  isLoading = true;
                });
                await _pixelizeImages();
                setState(() {
                  isLoading = false;
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("이미 사진이 촬영되었습니다.")),
              );
            }
          },
          child: Text(
            "사진 찍기",
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewMode() {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    final messageProvider =
        Provider.of<MessageFormProvider>(context, listen: false);

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // 로딩 인디케이터
            SizedBox(height: 16), // 간격 추가
            Text(
              '''이미지를 제출 중입니다
 잠시만 기다려주세요''',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "보물 쪽지 숨기기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          width: deviceWidth * 0.7,
          height: deviceHeight * 0.4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "힌트 사진은 이렇게 전달되요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showPixelizedImageModal,
                        child: Stack(
                          children: [
                            Container(
                              width: deviceWidth * 0.45,
                              height: deviceWidth * 0.45,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _pixelizedImageData != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        _pixelizedImageData!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (images[0] != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            File(images[0]!.path),
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
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "글로도 힌트를 남길 수 있어요.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: deviceWidth * 0.5,
                        child: TextField(
                          maxLength: 20,
                          decoration: InputDecoration(
                            hintText: "힌트 입력 (최대 20자)",
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          onChanged: (text) {
                            setState(() {
                              hintText = text;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "재촬영",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  messageProvider.updateHint(hintText);
                  logger.d("${messageProvider.messageData}");
                  Navigator.pushReplacementNamed(context, '/starwriteform');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "다음",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.67,
            child: Image.asset(
              themeProvider.subBg,
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

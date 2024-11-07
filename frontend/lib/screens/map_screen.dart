import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/models/index.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  late KakaoMapController mapController;
  bool _isMenuTouched = false;
  Set<Marker> markers = {};
  String message = "";
  final ImagePicker _picker = ImagePicker();
  bool _isLocationLoaded = false; // 위치 로드 상태 변수

  // kakao_map_plugin
  // windowInfo에 값을 넣으면 마커 클릭 시, windowInfo가 표시되게 설계되어 있어서 markerId에 매칭 되는 Map을 만들어야할 것 같음
  // markerId 에 매칭되는 더미 데이터
  final Map<String, Map<String, dynamic>> markerInfo = {
    "1": {
      "title": "이거 찾아봐",
      "hint": "맞춰보셈.",
      "hintImg": const AssetImage(
        "assets/img/map/test.png",
      ),
      "nickname": "가나다",
      "isTreasure": true,
    },
    "2": {
      "title": "맞춰보셈",
      "hint": "여기는 새로운 발견이 있는 맞춰보셈.",
      "hintImg": const AssetImage(
        "assets/img/map/test.png",
      ),
      "nickname": "라마나",
      "isTreasure": true,
    },
    "3": {
      "title": "행운의 별",
      "hint": "행운을 가져다 주는 장소입니다.",
      "hintImg": const AssetImage(
        "assets/img/map/test.png",
      ),
      "nickname": "",
      "isTreasure": true,
    },
    "4": {
      "title": "하이하이",
      "hint": "친구들과 함께하는 즐거운 장소입니다.",
      "hintImg": const AssetImage(
        "assets/img/map/test.png",
      ),
      "nickname": "ㅋㅋㅋ",
      "isTreasure": false,
    },
    "5": {
      "title": "ㅜㅜㅜ",
      "hint": "장소입니다.",
      "hintImg": const AssetImage(
        "assets/img/map/test.png",
      ),
      "nickname": "ㅋㅋㅋ",
      "isTreasure": false,
    },
  };

  // 탭 간의 이동이나 스크롤을 할 때 상태가 리셋되지 않고 그대로 유지
  @override
  bool get wantKeepAlive => true;

  // 맵 시작 시 실행
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // 위치 권한 요청
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      var result = await Permission.location.request();
      if (result.isGranted) {
        _loadMap();
      } else if (result.isPermanentlyDenied) {
        showPermissionDialog(context);
      }
    } else if (status.isGranted) {
      _loadMap();
    } else if (status.isPermanentlyDenied) {
      showPermissionDialog(context);
    } else {
      setState(() {
        message = "위치 권한이 필요합니다.";
      });
    }
  }

  // 카메라 권한 요청
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.camera.request();
      return result.isGranted;
    }
  }

  // 지도 로드 후 캐시된 위치나 현재 위치로 이동
  Future<void> _loadMap() async {
    setState(() {
      _isLocationLoaded = true; // 지도 로딩 상태를 업데이트
    });
  }

  // 캐시된 위치 불러오기
  Future<void> _goToCachedOrCurrentLocation() async {
    if (mapController == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _goToCachedOrCurrentLocation();
    }
    final cachedLocation = await SharedPreferences.getInstance();
    final lat = cachedLocation.getDouble('lat');
    final lng = cachedLocation.getDouble('lng');

    // 캐시된 위치가 있으면 그 위치로 먼저 이동
    if (lat != null && lng != null) {
      final cachedLocationLatLng = LatLng(lat, lng);
      await _setMarker(cachedLocationLatLng); // 캐시된 위치에 마커 설정
      mapController.setCenter(cachedLocationLatLng); // 지도 중심을 캐시된 위치로 설정
    } else {
      print("캐시된 위치가 없습니다. 현재 위치를 가져옵니다.");
    }

    // 현재 위치를 가져와 지도 중심 업데이트
    try {
      await _goToCurrentLocation();
    } catch (e) {
      print("현재 위치를 가져오는 데 실패했습니다: $e");
    }
  }

  // 마커 더미데이터 설정 함수
  Future<void> _setMarker(LatLng location) async {
    setState(() {
      markers = {
        Marker(
          markerId: "1",
          latLng: LatLng(location.latitude, location.longitude),
          markerImageSrc:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s",
        ),
        Marker(
          markerId: "2",
          latLng: LatLng(location.latitude + 0.001, location.longitude + 0.001),
          markerImageSrc:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s",
        ),
        Marker(
          markerId: "3",
          latLng: LatLng(location.latitude - 0.001, location.longitude - 0.001),
          markerImageSrc:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s",
        ),
        Marker(
          markerId: "4",
          latLng: LatLng(location.latitude + 0.001, location.longitude - 0.001),
          markerImageSrc:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s",
        ),
        Marker(
          markerId: "5",
          latLng: LatLng(location.latitude + 0.002, location.longitude - 0.001),
          markerImageSrc:
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s",
        ),
      };
    });
  }

  // 위치 캐시
  Future<void> _cacheLocation(LatLng location) async {
    final currentLocation = await SharedPreferences.getInstance();
    await currentLocation.setDouble('lat', location.latitude);
    await currentLocation.setDouble('lng', location.longitude);

    print("lat=${location.latitude}, lng=${location.longitude}");
  }

  // 현재 위치로 이동
  Future<void> _goToCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition();
    final currentLocation = LatLng(position.latitude, position.longitude);

    mapController.setCenter(LatLng(position.latitude, position.longitude));

    await _cacheLocation(LatLng(position.latitude, position.longitude));
    await _setMarker(currentLocation);
  }

  // 사진 촬영
  Future<void> _takePhoto(Map<String, dynamic> markerData) async {
    bool isCameraGranted = await _requestCameraPermission();
    if (!isCameraGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("권한 필요"),
            content: const Text("사진 촬영을 위해 카메라 권한이 필요합니다."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("확인"),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 권한이 승인된 경우 사진 촬영
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      _verifyPicture(image, markerData); // markerData 전달
    } else {
      setState(() {
        message = "사진 촬영이 취소되었습니다.";
      });
    }
  }

  // 사진 검증 함수
  bool isCorrectPicture(XFile image) {
    // TODO - 사진 검증 api 호출
    return true;
  }

  // 사진 검증 후 성공/실패 모달 분기
  void _verifyPicture(XFile image, Map<String, dynamic> markerData) {
    if (isCorrectPicture(image)) {
      Navigator.pop(context);
      CorrectMessageModal.show(
        context,
        onNoteButtonPressed: () => CorrectModal.show(context, markerData),
        markerData: markerData,
      );
    } else {
      Navigator.pop(context);
      IncorrectMessageModal.show(
        context,
        onRetry: () => _takePhoto(markerData),
      );
    }
  }

  // 메뉴 항목에 따른 액션 관리 함수
  void _handleMenuAction(MenuItem option) {
    switch (option) {
      case MenuItem.hideMyStar:
        Navigator.pushReplacementNamed(context, '/hidestar');
        break;
      case MenuItem.viewHiddenStars:
        _goToCurrentLocation();
        break;
      case MenuItem.viewStarsForEveryone:
        _goToCurrentLocation();
        break;
      case MenuItem.viewStarsForMe:
        _goToCurrentLocation();
        break;
    }
  }

  // 모든 마커 리스트
  Future<void> _showMarkerList(BuildContext context) async {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    color: const Color(0xFF9588E7).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 32),
                            const Center(
                              child: Text(
                                "별똥별",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: markers.length,
                                itemBuilder: (context, index) {
                                  final marker = markers.elementAt(index);
                                  final markerData =
                                      markerInfo[marker.markerId] ??
                                          {
                                            "title": "정보 없음",
                                            "hint": "추가 정보 없음",
                                            "nickname": "",
                                            "isTreasure": false,
                                          };

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showMarkerDetail(
                                          context, marker.markerId);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 10.0,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: AssetImage(
                                              markerData['isTreasure'] == true
                                                  ? 'assets/img/map/star_message.png'
                                                  : 'assets/img/map/general_message.png',
                                            ),
                                            radius: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              markerData['title'],
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            markerData['nickname'],
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
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
      },
    );
  }

  // 마커 디테일
  Future<void> _showMarkerDetail(BuildContext context, String markerId) async {
    final markerData = markerInfo[markerId] ??
        {
          "title": "정보 없음",
          "hint": "추가 정보 없음",
        };

    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    color: const Color(0xFF9588E7).withOpacity(0.9),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: Text(
                                markerData['title'] ?? "정보 없음",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "힌트사진!",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: SizedBox(
                                        width: 320,
                                        height: 200,
                                        child: markerData["hintImg"] != null
                                            ? Image(
                                                image: markerData["hintImg"],
                                              )
                                            : const SizedBox(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "힌트",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      markerData['hint'] ?? "추가 정보 없음",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              // 버튼 영역
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _takePhoto(markerData),
                                    child: const Text("사진 찍기"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showMarkerList(context);
                                    },
                                    child: const Text(
                                      '뒤로 가기',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    super.build(context);

    return !_isLocationLoaded
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Center(
                child: SizedBox(
                  width: deviceWidth * 0.85,
                  height: deviceHeight * 0.67,
                  child: KakaoMap(
                    onMapCreated: (controller) async {
                      mapController = controller;
                      await _goToCachedOrCurrentLocation();
                    },
                    onMarkerTap: (markerId, latLng, zoomLevel) {
                      setState(() {
                        _showMarkerList(context);
                      });
                    },
                    markers: markers.toList(),
                    currentLevel: 3,
                    onBoundsChangeCallback: ((latLngBounds) {
                      final ne = latLngBounds.getNorthEast();
                      final sw = latLngBounds.getSouthWest();

                      message =
                          '남서쪽 위도, 경도\n${sw.latitude}, ${sw.longitude}\n 북동쪽 위도, 경도\n${ne.latitude}, ${ne.longitude}';
                      setState(() {});
                    }),
                  ),
                ),
              ),
              Positioned(
                bottom: deviceHeight * 0.1,
                left: deviceWidth * 0.12,
                child: FloatingActionButton(
                  onPressed: _goToCachedOrCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
              Positioned(
                bottom: deviceHeight * 0.1,
                right: deviceWidth * 0.12,
                child: MenuList(
                  onItemSelected: (MenuItem selectedOption) {
                    _handleMenuAction(selectedOption);
                    setState(() {
                      _isMenuTouched = false;
                    });
                  },
                  isMenuTouched: _isMenuTouched,
                ),
              ),
            ],
          );
  }
}

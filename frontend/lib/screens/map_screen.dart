import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';

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
  Map<String, Map<String, dynamic>> markerInfo = {};
  String message = "";
  final ImagePicker _picker = ImagePicker();
  bool _isLocationLoaded = false;

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
      _isLocationLoaded = true;
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
      mapController.setCenter(cachedLocationLatLng);
    } else {
      logger.d("캐시된 위치가 없습니다. 현재 위치를 가져옵니다.");
    }

    // 현재 위치를 가져와 지도 중심 업데이트
    try {
      await _goToCurrentLocation();
    } catch (e) {
      logger.d("현재 위치를 가져오는 데 실패했습니다: $e");
    }
  }

  // 위치 캐시
  Future<void> _cacheLocation(LatLng location) async {
    final currentLocation = await SharedPreferences.getInstance();
    await currentLocation.setDouble('lat', location.latitude);
    await currentLocation.setDouble('lng', location.longitude);

    logger.d("lat=${location.latitude}, lng=${location.longitude}");
  }

  // 현재 위치로 이동
  Future<void> _goToCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition();

    mapController.setCenter(LatLng(position.latitude, position.longitude));

    await _cacheLocation(LatLng(position.latitude, position.longitude));
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
      _verifyPicture(image, markerData);
    } else {
      setState(() {
        message = "사진 촬영이 취소되었습니다.";
      });
    }
  }

  // 사진 검증 함수
  Future<bool> isCorrectPicture(
      XFile image, Map<String, dynamic> markerData) async {
    final data = await MapService.verifyPhoto(
      file: File(image.path),
      id: markerData['id'],
      lat: markerData['lat'],
      lng: markerData['lng'],
    );

    if (data != null) {
      markerData.addAll(data);
      return true;
    } else {
      return false;
    }
  }

  // 사진 검증 후 성공/실패 모달 분기
  void _verifyPicture(XFile image, Map<String, dynamic> markerData) async {
    bool isCorrect = await isCorrectPicture(image, markerData);
    if (isCorrect) {
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
        markerData: markerData,
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
                                            "id": -1,
                                            "title": "정보 없음",
                                            "hint": "추가 정보 없음",
                                            "isTreasure": false,
                                            "isFound": false,
                                            "senderId": "1",
                                            "lat": -1,
                                            "lng": -1,
                                            "image": "",
                                            "content": "",
                                            "hint_image_first": "",
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
                                            markerData['senderId'],
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
          "id": -1,
          "title": "정보 없음",
          "hint": "추가 정보 없음",
          "isTreasure": true,
          "isFound": false,
          "senderId": "정보 없음",
          "dot_hint_image": "정보 없음",
          "lat": -1,
          "lng": -1,
          "image": "",
          "content": "",
          "hint_image_first": "",
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
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: SizedBox(
                                        width: 320,
                                        height: 200,
                                        child: markerData["dot_hint_image"] !=
                                                null
                                            ? Image.network(
                                                markerData["dot_hint_image"])
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

  Future<void> fetchTreasureDetail(double id) async {
    final result = await MapService.getTreasureDetail(id);

    if (result != null) {
      setState(() {
        // Treasure 데이터 기반으로 markerInfo 업데이트
        result.forEach((dynamic item) {
          final treasure = item as TreasureModel;
          markerInfo[treasure.id.toString()] = {
            "id": treasure.id,
            "title": treasure.title,
            "hint": treasure.hint,
            "isTreasure": treasure.isTreasure,
            "isFound": treasure.isFound,
            "senderId": treasure.senderId.toString(),
            "dot_hint_image": treasure.dotHintImage,
            "lat": treasure.lat,
            "lng": treasure.lng,
            "image": treasure.image,
            "content": treasure.content,
            "hint_image_first": treasure.hintImageFirst,
          };
        });
      });
    } else {
      logger.d("서버에서 Treasure Detail 데이터를 가져오지 못했습니다.");
    }
  }

  Future<void> _fetchTreasuresInBounds(LatLngBounds bounds) async {
    final ne = bounds.getNorthEast();
    final sw = bounds.getSouthWest();

    final treasures = await MapService.getTreasures(
      sw.latitude,
      sw.longitude,
      ne.latitude,
      ne.longitude,
    );

    if (treasures != null) {
      setState(() {
        markers = treasures
            .map((dynamic item) => item as TreasureModel)
            .map((TreasureModel treasure) {
          markerInfo[treasure.id.toString()] = {
            "id": treasure.id,
            "title": treasure.title,
            "hint": treasure.hint,
            "isTreasure": treasure.isTreasure,
            "isFound": treasure.isFound,
            "senderId": treasure.senderId.toString(),
            "dot_hint_image": treasure.dotHintImage,
            "lat": treasure.lat,
            "lng": treasure.lng,
            "image": treasure.image,
            "content": treasure.content,
            "hint_image_first": treasure.hintImageFirst,
          };

          return Marker(
            markerId: treasure.id.toString(),
            latLng: LatLng(treasure.lat, treasure.lng),
            markerImageSrc:
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEHbvLu6P77nT9xFFUptQLRhrLV5POynqepA&s',
          );
        }).toSet();
      });
    } else {
      logger.d("서버에서 데이터를 가져오지 못했습니다.");
    }
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
                      _fetchTreasuresInBounds(latLngBounds);
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

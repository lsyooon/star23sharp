import 'dart:async';
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
  KakaoMapController? mapController;
  bool _isMenuTouched = false;
  Set<Marker> markers = {};
  Map<String, Map<String, dynamic>> markerInfo = {};
  String message = "";
  final ImagePicker _picker = ImagePicker();
  bool _isLocationLoaded = false;
  LatLngBounds currentBounds = LatLngBounds(
    LatLng(-90, -180),
    LatLng(90, 180),
  );
  MenuItem selectedOption = MenuItem.viewStarsForEveryone;
  bool _isSearchButtonVisible = false;
  bool _isFound = false;
  bool _isFar = false;
  bool _isPictureCorrect = false;
  bool _isVerifyLoading = false;
  Set<Marker> myLocate = {};
  StreamSubscription<Position>? _positionStreamSubscription;

  // 탭 간의 이동이나 스크롤을 할 때 상태가 리셋되지 않고 그대로 유지
  @override
  bool get wantKeepAlive => true;

  // 맵 시작 시 실행
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // 위치 스트림을 사용하여 현재 위치 트래킹 시작
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      final currentPosition = LatLng(position.latitude, position.longitude);
      if (mapController == null) return;
      // 현재 위치 마커 업데이트
      setState(() {
        myLocate = {
          Marker(
            markerId: '99999999',
            latLng: currentPosition,
            markerImageSrc:
                'https://img1.picmix.com/output/stamp/normal/6/8/1/0/2550186_93a1e.gif',
          )
        }.toSet();

        // 지도 중심도 현재 위치로 이동
        mapController!.setCenter(currentPosition);
      });

      // 위치 캐시 저장
      _cacheLocation(currentPosition);
    });
  }

  // 위치 권한 요청
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      var result = await Permission.location.request();
      if (result.isGranted) {
        _goToCachedOrCurrentLocation();
      } else if (result.isPermanentlyDenied) {
        showPermissionDialog(context);
      }
    } else if (status.isGranted) {
      _goToCachedOrCurrentLocation();
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
    if (mapController == null) return;
    final cachedLocation = await SharedPreferences.getInstance();
    final lat = cachedLocation.getDouble('lat');
    final lng = cachedLocation.getDouble('lng');

    // 캐시된 위치가 있으면 그 위치로 먼저 이동
    if (lat != null && lng != null) {
      final cachedLocationLatLng = LatLng(lat, lng);
      mapController!.setCenter(cachedLocationLatLng);

      currentBounds = await mapController!.getBounds();

      myLocate = {
        Marker(
          markerId: '99999999',
          latLng: LatLng(lat, lng),
          markerImageSrc:
              'https://img1.picmix.com/output/stamp/normal/6/8/1/0/2550186_93a1e.gif',
        )
      }.toSet();

      _fetchTreasuresInBounds(
        currentBounds,
        false,
        true,
        true,
        false,
        false,
      );
    } else {
      logger.d("캐시된 위치가 없습니다. 현재 위치를 가져옵니다.");
    }

    // 현재 위치를 가져와 지도 중심 업데이트
    try {
      await _goToCurrentLocation();
      currentBounds = await mapController!.getBounds();

      _fetchTreasuresInBounds(
        currentBounds,
        false,
        true,
        true,
        false,
        false,
      );
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

    if (mapController == null) return;
    mapController!.setCenter(LatLng(position.latitude, position.longitude));
    myLocate = {
      Marker(
        markerId: '99999999',
        latLng: LatLng(position.latitude, position.longitude),
        markerImageSrc:
            'https://img1.picmix.com/output/stamp/normal/6/8/1/0/2550186_93a1e.gif',
      )
    }.toSet();

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

    logger.d('{$data}');

    if (data?['code'] == "200") {
      switch (data?['message']) {
        case 'success':
          markerData.addAll(data?['data']);
          return true;
        case 'member_too_far':
          _isFar = true;
          return false;
        case 'image_not_similar':
          _isPictureCorrect = true;
          return false;
        default:
          _isFound = true;
          return false;
      }
    } else {
      logger.d("예상치 못한 응답: $data");
      return false;
    }
  }

  // 사진 검증 후 성공/실패 모달 분기
  void _verifyPicture(XFile image, Map<String, dynamic> markerData) async {
    // setState(() {
    //   _isVerifyLoading = true;
    // });
    bool isCorrect = await isCorrectPicture(image, markerData);
    // setState(() {
    //   _isVerifyLoading = false;
    // });
    if (isCorrect) {
      Navigator.pop(context);
      CorrectMessageModal.show(
        context,
        onNoteButtonPressed: () => CorrectModal.show(context, markerData),
        markerData: markerData,
      );
    } else if (_isPictureCorrect) {
      _showCustomSnackbar(context, "정답이 아닙니다.\n 다시 사진을 찍어주세요!");
    } else if (_isFar) {
      _showCustomSnackbar(context, "거리가 너무 멉니다.\n 가까이 가주세요!!");
    } else if (_isFound) {
      _showCustomSnackbar(context, "이미 찾은 쪽지입니다.");
    }
  }

  void _showCustomSnackbar(BuildContext context, String message) {
    _isFar = false;
    _isPictureCorrect = false;
    _isFound = false;
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: deviceHeight * 0.37,
        left: deviceWidth * 0.2,
        right: deviceWidth * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 3초 후에 자동으로 사라짐
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // 메뉴 항목에 따른 액션 관리 함수
  void _handleMenuAction(MenuItem option) {
    setState(() {
      selectedOption = option;
      _isMenuTouched = true;
    });

    switch (option) {
      case MenuItem.viewHiddenStars:
        _fetchTreasuresInBounds(
          currentBounds,
          false,
          false,
          true,
          true,
          true,
        );
        break;
      case MenuItem.viewStarsForEveryone:
        _fetchTreasuresInBounds(
          currentBounds,
          false,
          true,
          true,
          false,
          false,
        );
        break;
      case MenuItem.viewStarsForMe:
        _fetchTreasuresInBounds(
          currentBounds,
          false,
          true,
          false,
          false,
          true,
        );
        break;
    }
    setState(() {
      _isMenuTouched = false;
    });
  }

  // 모든 마커 리스트
  Future<void> _showMarkerList(BuildContext context) async {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            final deviceWidth = UIhelper.deviceWidth(dialogContext);
            final deviceHeight = UIhelper.deviceHeight(dialogContext);
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
                                onPressed: () => _closeDialog(dialogContext),
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
                              horizontal: 16.0,
                            ),
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
                                const SizedBox(height: 4),
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
                                                "sender_nickname": "",
                                              };

                                      return GestureDetector(
                                        onTap: () {
                                          if (mounted) {
                                            if (marker.markerId == '99999999') {
                                              return;
                                            }
                                            Navigator.pop(context);
                                            _showMarkerDetail(
                                                context, marker.markerId);
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 10.0,
                                          ),
                                          child: Row(
                                            children: [
                                              ClipOval(
                                                child: Image.asset(
                                                  markerData['isTreasure'] ==
                                                          true
                                                      ? 'assets/img/map/star_icon.png'
                                                      : 'assets/img/map/star_icon.png',
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  markerData['title'],
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 24,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                markerData['sender_nickname'],
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 24,
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
    });
  }

  // 마커 디테일
  Future<void> _showMarkerDetail(BuildContext context, String markerId) async {
    if (!mounted) return;
    final markerData = await fetchTreasureDetail(int.parse(markerId));
    if (!mounted) return;
    if (markerData == null) {
      _showCustomSnackbar(context, "해당 마커의 정보를 가져올 수 없습니다.");
      return;
    }

    if (markerData['isFound'] == true) {
      _showCustomSnackbar(context, "이미 찾은 쪽지입니다.");
      _fetchTreasuresInBounds(
        currentBounds,
        false,
        true,
        true,
        false,
        false,
      );
      return;
    }

    if (!mounted) return;

    Future.delayed(Duration.zero, () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            final deviceWidth = UIhelper.deviceWidth(dialogContext);
            final deviceHeight = UIhelper.deviceHeight(dialogContext);
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
                        color: const Color(0xFF9588E7).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                onPressed: () => _closeDialog(dialogContext),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                Center(
                                  child: Text(
                                    markerData['title'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Container(
                                    width: deviceWidth * 0.65,
                                    height: deviceHeight * 0.25,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
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
                                              "힌트사진",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: SizedBox(
                                                  width: deviceWidth * 0.55,
                                                  height: deviceWidth * 0.55,
                                                  child: markerData[
                                                                  "dot_hint_image"] !=
                                                              null &&
                                                          markerData[
                                                                  "dot_hint_image"]
                                                              .isNotEmpty
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            _showImageModal(
                                                                markerData[
                                                                    "dot_hint_image"]);
                                                          },
                                                          child: Image.network(
                                                            markerData[
                                                                "dot_hint_image"],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : const SizedBox(),
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
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Divider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ),
                                            const Text(
                                              "힌트 :",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              markerData['hint'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: () async {
                                          // setState(() {
                                          //   _isVerifyLoading = true;
                                          // });

                                          await _takePhoto(markerData);

                                          // setState(() {
                                          //   _isVerifyLoading = false;
                                          // });
                                        },
                                        child: const Text(
                                          "사진 찍기",
                                          style: TextStyle(
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
                // if (_isVerifyLoading)
                //   Container(
                //     color: Colors.black.withOpacity(0.5),
                //     child: const Center(
                //       child: CircularProgressIndicator(),
                //     ),
                //   ),
              ],
            );
          },
        );
      }
    });
  }

  // 디테일 창에서 X 버튼 누를 때 모달 닫기 기능 수정
  void _closeDialog(BuildContext context) {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  void _showImageModal(String imageUrl) {
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
                const SizedBox(
                  height: 16,
                ),
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

  Future<Map<String, dynamic>?> fetchTreasureDetail(int id) async {
    final result = await MapService.getTreasureDetail(id);

    if (result != null) {
      final treasure = result.first as TreasureModel;
      return {
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
        "sender_nickname": treasure.senderNickname,
      };
    } else {
      logger.d("서버에서 Treasure Detail 데이터를 가져오지 못했습니다.");
      return null;
    }
  }

  // 현재 지도 위치에서 마커를 검색하는 함수
  void _fetchMarkersInCurrentBounds() {
    switch (selectedOption) {
      case MenuItem.viewHiddenStars:
        _fetchTreasuresInBounds(currentBounds, false, false, true, true, true);
        break;
      case MenuItem.viewStarsForEveryone:
        _fetchTreasuresInBounds(currentBounds, false, true, true, false, false);
        break;
      case MenuItem.viewStarsForMe:
        _fetchTreasuresInBounds(currentBounds, false, true, false, false, true);
        break;
      default:
        break;
    }
  }

  Future<void> _fetchTreasuresInBounds(
    LatLngBounds bounds,
    bool includeOpend,
    bool getReceived,
    bool includedPublic,
    bool includeGroup,
    bool includePrivate,
  ) async {
    final ne = bounds.getNorthEast();
    final sw = bounds.getSouthWest();

    final treasures = await MapService.getTreasures(
      sw.latitude,
      sw.longitude,
      ne.latitude,
      ne.longitude,
      includeOpend,
      getReceived,
      includedPublic,
      includeGroup,
      includePrivate,
    );

    if (treasures != null && mounted) {
      setState(() {
        markers = treasures
            .map((dynamic item) => item as TreasureModel)
            .where((TreasureModel treasure) =>
                isPointInBounds(LatLng(treasure.lat, treasure.lng), bounds))
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
            "sender_nickname": treasure.senderNickname,
          };

          return Marker(
            markerId: treasure.id.toString(),
            latLng: LatLng(treasure.lat, treasure.lng),
            markerImageSrc:
                'https://star23sharp.s3.ap-northeast-2.amazonaws.com/marker/star.svg',
          );
        }).toSet();
        markers.addAll(myLocate);
      });
    } else {
      logger.d("서버에서 데이터를 가져오지 못했습니다.");
    }
  }

  bool isPointInBounds(LatLng point, LatLngBounds bounds) {
    return (point.latitude >= bounds.getSouthWest().latitude &&
            point.latitude <= bounds.getNorthEast().latitude) &&
        (point.longitude >= bounds.getSouthWest().longitude &&
            point.longitude <= bounds.getNorthEast().longitude);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = UIhelper.deviceWidth(context);
    final deviceHeight = UIhelper.deviceHeight(context);
    super.build(context);

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: deviceWidth * 0.85,
            height: deviceHeight * 0.67,
            child: KakaoMap(
              onMapCreated: (controller) async {
                mapController = controller;
                await _goToCachedOrCurrentLocation();
                _startLocationTracking();

                currentBounds = await mapController!.getBounds();

                _fetchTreasuresInBounds(
                  currentBounds,
                  false,
                  true,
                  true,
                  false,
                  false,
                );
              },
              onMarkerTap: (markerId, latLng, zoomLevel) {
                setState(() {
                  _showMarkerDetail(context, markerId);
                });
              },
              markers: markers.toList(),
              currentLevel: 3,
              onBoundsChangeCallback: ((latLngBounds) {
                if (currentBounds != latLngBounds) {
                  setState(() {
                    currentBounds = latLngBounds;
                    _isSearchButtonVisible = true;
                  });
                }
              }),
            ),
          ),
        ),
        Positioned(
          bottom: deviceHeight * 0.1,
          left: deviceWidth * 0.12,
          child: InkWell(
            onTap: _goToCachedOrCurrentLocation,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/img/map/location.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: deviceHeight * 0.1,
          right: deviceWidth * 0.12,
          child: Opacity(
            opacity: 0.5,
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
        ),
        Positioned(
          bottom: deviceHeight * 0.17,
          right: deviceWidth * 0.12,
          child: InkWell(
            onTap: () => {Navigator.pushNamed(context, '/hidestar')},
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/img/map/plus.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
          ),
        ),
        if (_isSearchButtonVisible)
          Positioned(
            top: deviceHeight * 0.1,
            right: deviceWidth * 0.32,
            child: ElevatedButton(
              onPressed: () {
                _fetchMarkersInCurrentBounds();
                setState(() {
                  _isSearchButtonVisible = false;
                });
              },
              child: const Text("현재 위치에서 검색"),
            ),
          ),
      ],
    );
  }
}

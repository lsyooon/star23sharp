import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'package:provider/provider.dart';
import 'package:star23sharp/utilities/snackbar_route_observer.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:star23sharp/screens/index.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    logger.d("Notification Received!");
  }
}

//푸시 알림 메시지와 상호작용을 정의합니다.
Future<void> setupInteractedMessage() async {
  //앱이 종료된 상태에서 열릴 때 getInitialMessage 호출
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  //앱이 백그라운드 상태일 때, 푸시 알림을 탭할 때 RemoteMessage 처리
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  logger.d("Handling message: $message");
  // 데이터에서 notificationId 추출
  final notificationId = message.data['notificationId'];
  final messageId = message.data['messageId'];
  logger.d("백그라운드 main.dart:_handleMessage notificationId:  " + notificationId);
  logger.d("백그라운드 main.dart _handleMessage: message아이디는:  " + messageId);

  Future.delayed(const Duration(seconds: 1), () {
    final isLoggedIn = Provider.of<AuthProvider>(
            AppGlobal.navigatorKey.currentContext!,
            listen: false)
        .isLoggedIn;

    if (isLoggedIn) {
      if (messageId != null) {
        logger.d("알림 messageId: $messageId");

        // 홈 화면을 네비게이션 스택에 추가하고, 그 위에 상세 페이지를 추가
        AppGlobal.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/home', // 홈 화면
          (route) => false, // 기존 스택을 제거
        );

        AppGlobal.navigatorKey.currentState!.pushNamed(
          '/star_received_detail',
          arguments: int.tryParse(messageId), // messageId 전달
        );
        return;
      }

// 홈 화면을 네비게이션 스택에 추가하고, 그 위에 알림 페이지를 추가
      AppGlobal.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/home', // 홈 화면
        (route) => false, // 기존 스택을 제거
      );

      AppGlobal.navigatorKey.currentState!.pushNamed(
        '/notification',
        arguments: int.tryParse(notificationId), // notificationId를 전달
      );
    } else {
      AppGlobal.navigatorKey.currentState!.pushNamed(
        '/signin',
      );
    }
  });
}

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // 호출 스택 깊이
    errorMethodCount: 5, // 에러 발생 시 호출 스택 깊이
    lineLength: 50, // 한 줄의 길이 제한
    colors: true, // 컬러 출력 여부
    printEmojis: true, // 이모지 출력 여부
  ),
);

// 토큰 저장 관련
const storage = FlutterSecureStorage();

// storage에 저장해둔 내용 받아오기
Future<void> loadAccessToken(AuthProvider authProvider) async {
  String? access = await storage.read(key: 'access');
  String? refresh = await storage.read(key: 'refresh');
  if (access != null && refresh != null) {
    logger.d("access: $access, refresh: $refresh");
    authProvider.setToken(access, refresh);
  } else {
    logger.d("토큰 없음 -> 로그인 안된 상태");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

//firebase setting
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //FCM 푸시 알림 관련 초기화
  FCMService.init();
  //flutter_local_notifications 패키지 관련 초기화
  FCMService.localNotiInit();
  //백그라운드 알림 수신 리스너
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //포그라운드 알림 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    String? imageUrl = message.notification?.android?.imageUrl;
    if (notification != null) {
      if (imageUrl != null) {
        // 이미지가 포함된 경우
        await FCMService.showImageNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          imageUrl: imageUrl,
          payload: jsonEncode(message.data),
          notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        // 일반 알림
        await FCMService.showSimpleNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
          notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      }
      // 현재 라우트 확인
      final currentState = AppGlobal.navigatorKey.currentState;
      if (currentState != null) {
        String? currentPath;
        currentState.popUntil((route) {
          currentPath = route.settings.name;
          return true;
        });
        logger.d("현재 화면 url: $currentPath");

        // 현재 화면이 '/notification'인 경우 fetchNotifications 호출
        if (currentPath == '/notification') {
          if (PushAlarmScreenState.instance != null) {
            logger.d("PushAlarmScreenState 인스턴스 감지");
            PushAlarmScreenState.instance!.fetchNotifications();
          }
        } else {
          logger.e("알림 화면 상태를 찾을 수 없음.");
        }
      } else {
        logger.e("현재 Navigator 상태를 찾을 수 없음.");
      }
    }
  });

  //메시지 상호작용 함수 호출
  setupInteractedMessage();

  // env 파일 설정
  await dotenv.load(fileName: '.env');
  final appKey = dotenv.env['KAKAO_MAP_APP_KEY'] ?? '';
  AuthRepository.initialize(
    appKey: appKey,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessageFormProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MessageFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: AppGlobal.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.mainColor, // 주요 색상
          ),
        primaryColor: themeProvider.backgroundColor,
        fontFamily: 'Hakgyoansim Chilpanjiugae',
      ),
      navigatorObservers: <NavigatorObserver>[
        observer,
        AppGlobal.routeObserver,
        SnackbarRouteObserver(),
        RouteObserver<PageRoute>()
      ],
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MainLayout(child: HomeScreen()),
        '/map': (context) => const MainLayout(child: MapScreen()),
        '/starstorage': (context) => const MainLayout(child: StarStoragebox()),
        '/starwriteform': (context) =>
            const MainLayout(child: StarFormScreen()),
        '/profile': (context) => const MainLayout(child: ProfileScreen()),
        '/notification': (context) =>
            const MainLayout(child: PushAlarmScreen()),
        '/signin': (context) => const MainLayout(child: LoginScreen()),
        '/signup': (context) => const MainLayout(child: SignUpScreen()),
        '/message_style_editor': (context) =>
            const MainLayout(child: ChooseStarStyleScreen()),
        '/star_received_detail': (context) =>
            const MainLayout(child: StarReceivedDetailScreen()),
        '/star_sent_detail': (context) =>
            const MainLayout(child: StarSentDetailScreen()),
        '/modify_profile': (context) =>
            const MainLayout(child: ModifyProfileScreen()),
        '/hidestar': (context) => const MainLayout(child: HideStarScreen()),
        '/notification_setting': (context) =>
            const MainLayout(child: NotificationSettingsScreen()),
        '/nickbooks': (context) => const MainLayout(child: NickbookScreen()),
      },
    );
  }
}

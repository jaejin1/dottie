import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/background/background_service.dart';
import 'core/config/app_config.dart';
import 'features/notification/data/push_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 보안: release 빌드에서 debugPrint 는 제거되지 않고 시스템 로그
  // (logcat/os_log)로 출력된다. 이 앱은 위치를 시간별로 기록하므로
  // 좌표·메모·식별자가 로그로 새면 같은 기기의 로그 접근 앱/MDM/adb 로
  // 이동 경로가 재구성될 수 있다. release 에서는 전역 no-op 으로 차단한다.
  // (개별 민감 로그는 각 지점에서 assert() 가드로도 이중 방어.)
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // 보안: prod 빌드가 평문 http 로 잘못 구성됐으면 여기서 즉시 실패.
  AppConfig.assertSecureConfig();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // intl 의 한국어 요일/월 이름은 locale 데이터를 명시적으로 로드해야 사용 가능.
  // (DateFormat('EEEE', 'ko') 같은 호출 전에 반드시 한 번 호출 — main 에서 1회로 충분.)
  await initializeDateFormatting('ko_KR');

  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);

  KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM 백그라운드 핸들러 등록 — Firebase init 직후, runApp 전에 한 번 등록.
  // top-level 함수라 별도 isolate 에서 호출되며 인스턴스 의존 X.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 백그라운드 작업이 dart-define 값에 접근할 수 있도록 SharedPreferences에 저장
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_url', AppConfig.apiUrl);

  // WorkManager 초기화 + 저장된 자동기록 간격 복원
  // (Foreground Service는 프로세스가 죽으면 함께 종료되므로 부팅/재시작 시 재가동 필요)
  await BackgroundService.initialize();
  await BackgroundService.restoreOnLaunch();

  runApp(
    const ProviderScope(
      child: DottieApp(),
    ),
  );
}

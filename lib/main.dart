import 'package:firebase_core/firebase_core.dart';
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
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

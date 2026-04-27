import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
// Firebase는 flutterfire configure 실행 후 아래 주석 해제
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Mapbox 액세스 토큰 설정
  MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);

  // Firebase 초기화 (firebase_options.dart 생성 후 활성화)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    const ProviderScope(
      child: DottieApp(),
    ),
  );
}

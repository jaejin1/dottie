import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 앱 전역에서 공유하는 하드닝된 secure storage 옵션.
///
/// - Android: `encryptedSharedPreferences`로 Jetpack Security 기반 암호화 저장.
/// - iOS: `first_unlock_this_device` —
///   - `_this_device` : 암호화 백업/기기 이전 시 항목이 따라가지 않아 토큰·DB
///     키가 다른 기기로 유출되지 않는다.
///   - `first_unlock` : 첫 잠금해제 후에는 잠금 상태에서도 읽기 가능 —
///     백그라운드 자동 기록 isolate 가 잠긴 기기에서 토큰을 읽어야 하므로 필요.
///     (`unlocked` 로 하면 백그라운드 sync 가 잠금 중 실패한다.)
const kSecureStorageAndroidOptions =
    AndroidOptions(encryptedSharedPreferences: true);

const kSecureStorageIOSOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);

/// 하드닝 옵션이 적용된 공유 인스턴스. 새로 만들 땐 이걸 쓴다.
const FlutterSecureStorage kSecureStorage = FlutterSecureStorage(
  aOptions: kSecureStorageAndroidOptions,
  iOptions: kSecureStorageIOSOptions,
);

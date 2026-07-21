import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

class LocationException implements Exception {
  const LocationException(
    this.message, {
    this.permanentlyDenied = false,
    this.serviceDisabled = false,
  });
  final String message;

  /// `LocationPermission.deniedForever` — OS 권한 모달이 더 이상 뜨지 않음.
  /// 사용자가 *시스템 설정* 으로 직접 가야 함. 호출자는 SnackBarAction("설정 열기")
  /// 으로 안내.
  final bool permanentlyDenied;

  /// 위치 서비스 자체가 꺼져 있음. 사용자가 시스템 설정에서 켜야 함.
  final bool serviceDisabled;

  /// 호출자가 "설정 열기" 액션을 노출해야 하는 케이스.
  bool get shouldOpenSettings => permanentlyDenied || serviceDisabled;

  @override
  String toString() => message;
}

class LocationService {
  /// 위치 권한 확인 및 요청. 거부 시 [LocationException] throw.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        '위치 서비스가 꺼져 있어요. 설정에서 켜주세요.',
        serviceDisabled: true,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('위치 권한을 허용해야 dot 을 찍을 수 있어요');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        '위치 권한이 차단돼 있어요. 설정에서 직접 허용해주세요.',
        permanentlyDenied: true,
      );
    }

    return true;
  }

  /// 현재 위치 1회 수집. 최대 30초 대기 (Android cold-start GPS 워밍업 고려).
  Future<Position> getCurrentPosition() async {
    await requestPermission();
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      throw const LocationException('위치를 가져오는 데 시간이 너무 걸렸어요. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<LocationPermission> getPermissionStatus() =>
      Geolocator.checkPermission();
}

@riverpod
LocationService locationService(Ref ref) => LocationService();

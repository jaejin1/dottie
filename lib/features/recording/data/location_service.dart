import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocationService {
  /// 위치 권한 확인 및 요청. 거부 시 [LocationException] throw.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('위치 서비스가 꺼져 있습니다. 설정에서 활성화해주세요.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        '위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 허용해주세요.',
      );
    }

    return true;
  }

  /// 현재 위치 1회 수집. 최대 10초 대기.
  Future<Position> getCurrentPosition() async {
    await requestPermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  Future<LocationPermission> getPermissionStatus() =>
      Geolocator.checkPermission();
}

@riverpod
LocationService locationService(Ref ref) => LocationService();

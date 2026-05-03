import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/paperdoll_parts.dart';
import '../domain/paperdoll_validators.dart';

/// `assets/character/manifest.json`을 로드해 `PaperdollManifestData`로 파싱.
///
/// security-auditor 권고:
/// - 모든 ID는 `isValidPartId()` 통과해야 등록.
/// - 에셋 경로는 manifest의 `asset` 필드에서만 도출(외부 입력 금지).
/// - 잘못된 항목은 무시(로그만 출력)하고 나머지는 정상 동작.
class PaperdollManifestLoader {
  PaperdollManifestLoader({String assetPath = 'assets/character/manifest.json'})
      : _assetPath = assetPath;

  final String _assetPath;
  PaperdollManifestData? _cached;

  Future<PaperdollManifestData> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cached = _parse(json);
    return _cached!;
  }

  /// 메모리 캐시 클리어 (핫리로드/테스트용)
  void invalidate() => _cached = null;

  PaperdollManifestData _parse(Map<String, dynamic> json) {
    final size = json['frame_size'] as Map<String, dynamic>? ??
        const {'w': 32, 'h': 32};
    final w = (size['w'] as num? ?? 32).toInt();
    final h = (size['h'] as num? ?? 32).toInt();
    final frameCount = (json['frame_count'] as num? ?? 5).toInt();
    final version = (json['version'] as num? ?? 1).toInt();

    // sanity check — 악의적 manifest 차단
    final safeW = w.clamp(8, 256);
    final safeH = h.clamp(8, 256);
    final safeCount = frameCount.clamp(1, 16);

    final partsRaw = json['parts'] as Map<String, dynamic>? ?? {};
    final parts = <PartType, List<PartItem>>{};

    void addPart(PartType type, String key) {
      final list = partsRaw[key] as List? ?? const [];
      final items = <PartItem>[];
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) continue;
        final id = entry['id'] as String?;
        final asset = entry['asset'] as String?;
        if (!isValidPartId(id) || asset == null || asset.isEmpty) continue;
        // 에셋 경로 sanity — 'assets/character/'로 시작해야 함
        if (!asset.startsWith('assets/character/')) continue;
        items.add(PartItem(
          id: id!,
          name: (entry['name'] as String?) ?? id,
          assetPath: asset,
          tintable: (entry['tintable'] as bool?) ?? false,
          expressions: (entry['expressions'] as List?)
                  ?.whereType<String>()
                  .toList() ??
              const [],
          thumbnailPath: entry['thumbnail'] as String?,
        ));
      }
      if (items.isNotEmpty) parts[type] = items;
    }

    addPart(PartType.skin, 'skin');
    addPart(PartType.hairBack, 'hair_back');
    addPart(PartType.hairFront, 'hair_front');
    addPart(PartType.face, 'face');
    addPart(PartType.top, 'top');
    addPart(PartType.bottom, 'bottom');
    addPart(PartType.shoes, 'shoes');
    addPart(PartType.accessory, 'accessory');

    return PaperdollManifestData(
      version: version,
      frameWidth: safeW,
      frameHeight: safeH,
      frameCount: safeCount,
      parts: parts,
    );
  }
}

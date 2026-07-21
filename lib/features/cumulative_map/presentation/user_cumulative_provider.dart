import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../recording/data/dot_remote_source.dart';
import '../../recording/domain/dot_model.dart';

part 'user_cumulative_provider.g.dart';

/// 본인 누적 dot — `/v1/dots/cumulative` cursor pagination 자동 루프.
///
/// timestamp DESC 정렬. 안전장치 50 페이지 (5,000 dot 까지).
@riverpod
Future<List<Dot>> userCumulativeDots(Ref ref) async {
  final remote = ref.watch(dotRemoteSourceProvider);

  String? cursor;
  final all = <Dot>[];
  for (var page = 0; page < 50; page++) {
    final res = await remote.getCumulativeDots(cursor: cursor, limit: 100);
    all.addAll(res.dots);
    cursor = res.nextCursor;
    if (cursor == null) break;
  }

  if (kDebugMode) {
    debugPrint('[userCumulative] dots=${all.length}');
  }

  return all;
}

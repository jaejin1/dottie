import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../recording/data/dot_repository.dart';
import '../../recording/domain/dot_model.dart';

part 'hidden_dots_provider.g.dart';

/// 본인이 특정 룸에서 숨긴 dot 목록.
/// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
/// 숨김/해제 액션 후엔 invalidate 해서 갱신.
@riverpod
Future<List<Dot>> hiddenDotsByMe(Ref ref, String roomId) async {
  final repo = ref.watch(dotRepositoryProvider);
  return repo.getHiddenDotsByMe(roomId);
}

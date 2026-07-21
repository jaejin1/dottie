import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/domain/user_model.dart';
import '../../character/paperdoll/data/paperdoll_legacy_adapter.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../cumulative_map/domain/place.dart';
import '../../map_animation/data/animation_builder.dart';
import '../../map_animation/presentation/animation_provider.dart'
    show PlaySpeed, PlaySpeedExt;
import '../../recording/domain/dot_model.dart';
import '../../room/data/room_repository.dart';
import '../../room/domain/room_model.dart';
import '../data/shared_map_builder.dart';
import '../domain/shared_map_model.dart';

part 'shared_map_provider.g.dart';

/// 공유 지도 화면의 표시 모드.
/// - [explore] : 정적 지도 + dot/트레일만. 캐릭터/재생 컨트롤 숨김. 진입 기본값.
/// - [playback] : 캐릭터가 시간순으로 이동하는 시네마 모드. 컨트롤 패널 표시.
enum SharedMapViewMode { explore, playback }

class SharedMapState {
  const SharedMapState({
    required this.tracks,
    this.progress = 0.0,
    this.isPlaying = false,
    this.speed = PlaySpeed.x1,
    this.meetings = const [],
    this.paperdolls = const {},
    this.viewMode = SharedMapViewMode.explore,
    this.showOrderNumbers = false,
  });

  final List<MemberTrack> tracks;
  final double progress;
  final bool isPlaying;
  final PlaySpeed speed;
  final List<MeetingEvent> meetings;

  /// userId → PaperdollConfig. BE 응답의 member.character_config 파싱 결과.
  final Map<String, PaperdollConfig> paperdolls;

  final SharedMapViewMode viewMode;

  /// dot 위에 이동 순번(1·2·3...) 표시 여부. 기본 OFF — 사용자가 토글로 켠다.
  final bool showOrderNumbers;

  SharedMapState copyWith({
    List<MemberTrack>? tracks,
    double? progress,
    bool? isPlaying,
    PlaySpeed? speed,
    List<MeetingEvent>? meetings,
    Map<String, PaperdollConfig>? paperdolls,
    SharedMapViewMode? viewMode,
    bool? showOrderNumbers,
  }) =>
      SharedMapState(
        tracks: tracks ?? this.tracks,
        progress: progress ?? this.progress,
        isPlaying: isPlaying ?? this.isPlaying,
        speed: speed ?? this.speed,
        meetings: meetings ?? this.meetings,
        paperdolls: paperdolls ?? this.paperdolls,
        viewMode: viewMode ?? this.viewMode,
        showOrderNumbers: showOrderNumbers ?? this.showOrderNumbers,
      );

  /// 모든 멤버 중 가장 이른 첫 dot 시각 = 공통 재생 시작. 프레임 없으면 null.
  DateTime? get globalStartTime {
    DateTime? start;
    for (final t in tracks) {
      final frames = t.sequence.frames;
      if (frames.isEmpty) continue;
      final ts = frames.first.dot.timestamp;
      if (start == null || ts.isBefore(start)) start = ts;
    }
    return start;
  }

  /// 모든 멤버 중 가장 늦은 마지막 dot 시각 = 공통 재생 끝. 프레임 없으면 null.
  DateTime? get globalEndTime {
    DateTime? end;
    for (final t in tracks) {
      final frames = t.sequence.frames;
      if (frames.isEmpty) continue;
      final ts = frames.last.dot.timestamp;
      if (end == null || ts.isAfter(end)) end = ts;
    }
    return end;
  }

  /// progress(0~1) → 공통 벽시계상의 현재 실제 시각.
  DateTime? currentTimeAt(double progress) {
    final start = globalStartTime;
    final end = globalEndTime;
    if (start == null || end == null) return null;
    final spanMs = end.difference(start).inMilliseconds;
    return start.add(Duration(milliseconds: (spanMs * progress).round()));
  }

  /// 재생 총 길이(애니메이션 ms). 이전에는 멤버별 시퀀스 길이의 최댓값을
  /// 썼으나(공통 시계 없음), 이제 **전역 시간 span**(첫~마지막 dot)을 실제
  /// 시간 비율로 환산한다. 이렇게 해야 progress 가 벽시계에 선형 대응한다.
  double get totalDurationMs {
    final start = globalStartTime;
    final end = globalEndTime;
    if (start == null || end == null) return 0;
    final spanMinutes = end.difference(start).inMinutes;
    final ms = spanMinutes * AnimationBuilder.msPerRealMinute;
    return ms.clamp(3000, double.infinity); // 최소 3초
  }
}

@riverpod
class SharedMapNotifier extends _$SharedMapNotifier {
  Ticker? _ticker;
  double _lastTimestamp = 0;

  @override
  SharedMapState? build(String roomId, String date) {
    ref.onDispose(() => _ticker?.dispose());
    _loadTracks(roomId, date);
    return null;
  }

  Future<void> _loadTracks(String roomId, String date) async {
    try {
      final repo = ref.read(roomRepositoryProvider);
      final data = await repo.getSharedMap(roomId, DateTime.parse(date));

      if (data == null) {
        // 기존 사용자 토글(showOrderNumbers / viewMode) 보존.
        state = (state ?? const SharedMapState(tracks: []))
            .copyWith(tracks: const [], meetings: const []);
        return;
      }

      final rawMembers = data['members'] as List? ?? [];

      final dotsByMember = <String, List<Dot>>{};
      for (final m in rawMembers) {
        final map = m as Map<String, dynamic>;
        final userId = map['user_id'] as String;
        final rawDots = map['dots'] as List? ?? [];
        dotsByMember[userId] =
            rawDots.map((d) => _dotFromApi(d as Map<String, dynamic>, userId)).toList();
      }

      final members = rawMembers.map<RoomMember>((m) {
        final map = m as Map<String, dynamic>;
        final config = map['character_config'] as Map<String, dynamic>?;
        return RoomMember(
          userId: map['user_id'] as String,
          nickname: map['nickname'] as String? ?? '',
          character: CharacterConfig(
            colorHex: config?['color_hex'] as String? ?? '#7EB8F7',
          ),
          joinedAt: DateTime.now(),
        );
      }).toList();

      final rawEncounters = data['encounters'] as List? ?? [];
      final meetings = rawEncounters.map((e) {
        final map = e as Map<String, dynamic>;
        // B5: user_ids/dot_ids 가변 길이 (최소 2). 같은 순서/길이 매칭.
        final userIds = (map['user_ids'] as List).cast<String>();
        final dotIds =
            (map['dot_ids'] as List?)?.cast<String>() ?? const <String>[];
        final loc = map['location'] as Map<String, dynamic>;
        final startedAtRaw = map['started_at'] as String?;
        // B5: distance_m → max_distance_m rename. 호환을 위해 둘 다 시도.
        final maxDist = (map['max_distance_m'] as num?)?.toDouble() ??
            (map['distance_m'] as num?)?.toDouble();
        return MeetingEvent(
          userIds: userIds,
          lat: (loc['latitude'] as num).toDouble(),
          lng: (loc['longitude'] as num).toDouble(),
          startedAt:
              startedAtRaw != null ? DateTime.parse(startedAtRaw) : null,
          durationMinutes: (map['duration_minutes'] as num?)?.toInt(),
          placeName: map['place_name'] as String?,
          dotIds: dotIds,
          maxDistanceM: maxDist,
        );
      }).toList();

      final normalizedDots = {
        for (final entry in dotsByMember.entries)
          if (entry.value.isNotEmpty) entry.key: entry.value,
      };

      debugPrint('[SharedMapNotifier] members=${members.length}, '
          'dotsByMember keys=${normalizedDots.keys.toList()}');

      final tracks = SharedMapBuilder.build(
        members: members,
        dotsByMember: normalizedDots,
        colorByUserId: _colorMapFromApiMembers(rawMembers),
      );
      final paperdolls = _paperdollsFromApiMembers(rawMembers);
      debugPrint('[SharedMapNotifier] tracks built: ${tracks.length}, '
          'frames: ${tracks.map((t) => t.sequence.frames.length).toList()}, '
          'paperdolls: ${paperdolls.length}');
      // invalidate 후 reload 시 사용자 토글(showOrderNumbers / viewMode 등) 보존.
      // tracks / meetings / paperdolls 만 새 데이터로 교체.
      state = (state ?? const SharedMapState(tracks: [])).copyWith(
        tracks: tracks,
        meetings: meetings,
        paperdolls: paperdolls,
      );
    } catch (e, st) {
      debugPrint('[SharedMapNotifier] _loadTracks error: $e\n$st');
      state = (state ?? const SharedMapState(tracks: []))
          .copyWith(tracks: const [], meetings: const []);
    }
  }

  static Dot _dotFromApi(Map<String, dynamic> d, String userId) {
    final lastCommentedRaw = d['last_commented_at'] as String?;
    final placeRaw = d['place'] as Map<String, dynamic>?;
    final rawTags = d['tags'];
    final tags = (rawTags is List)
        ? rawTags.whereType<String>().toList(growable: false)
        : const <String>[];
    return Dot(
      id: d['id'] as String,
      latitude: (d['latitude'] as num).toDouble(),
      longitude: (d['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(d['timestamp'] as String),
      placeName: d['place_name'] as String?,
      placeCategory: d['place_category'] as String?,
      // photo_url 은 BE 응답에서 제거됨 — variant URL 만 받음.
      photoThumbUrl: d['photo_thumb_url'] as String?,
      photoPreviewUrl: d['photo_preview_url'] as String?,
      memo: d['memo'] as String?,
      emotion: d['emotion'] as String?,
      dayLogId: d['day_log_id'] as String? ?? userId,
      synced: true,
      commentCount: (d['comment_count'] as num?)?.toInt() ?? 0,
      lastCommentedAt:
          lastCommentedRaw != null ? DateTime.parse(lastCommentedRaw) : null,
      placeId: d['place_id'] as String?,
      place: placeRaw != null ? Place.fromJson(placeRaw) : null,
      tags: tags,
    );
  }

  static Map<String, String> _colorMapFromApiMembers(List rawMembers) {
    // BE 응답의 character_config.color_hex (자유 hex) 매핑.
    // 빠진 항목은 RoomMember.character.colorHex 의 default(#7EB8F7)로 폴백됨.
    final result = <String, String>{};
    for (final m in rawMembers) {
      final map = m as Map<String, dynamic>;
      final userId = map['user_id'] as String;
      final config = map['character_config'] as Map<String, dynamic>?;
      final hex = config?['color_hex'] as String?;
      if (hex != null && hex.isNotEmpty) {
        result[userId] = hex;
      }
    }
    return result;
  }

  /// 멤버별 PaperdollConfig 파싱. v1/v2 둘 다 안전하게 처리.
  static Map<String, PaperdollConfig> _paperdollsFromApiMembers(
      List rawMembers) {
    final result = <String, PaperdollConfig>{};
    for (final m in rawMembers) {
      final map = m as Map<String, dynamic>;
      final userId = map['user_id'] as String;
      final config = map['character_config'] as Map<String, dynamic>?;
      result[userId] = paperdollFromMixedJson(config);
    }
    return result;
  }

  void play() {
    if (state == null) return;
    state = state!.copyWith(isPlaying: true);
    _startTicker();
  }

  void pause() {
    _ticker?.stop();
    if (state == null) return;
    state = state!.copyWith(isPlaying: false);
  }

  void setSpeed(PlaySpeed speed) {
    if (state == null) return;
    state = state!.copyWith(speed: speed);
  }

  /// 표시 모드 전환.
  /// - explore 진입: 재생 정지 + 처음으로 되감기 (캐릭터를 시작점으로 리셋).
  /// - playback 진입: 처음으로 되감은 뒤 자동 재생.
  /// 캐릭터 layer visibility 토글은 화면(_SharedMapScreenState)에서
  /// ref.listen 으로 viewMode 변화를 감지해 처리한다.
  /// meetings는 BE 정적 데이터이므로 모드 전환 시 덮어쓰지 않는다.
  void setViewMode(SharedMapViewMode mode) {
    if (state == null) return;
    if (state!.viewMode == mode) return;
    _ticker?.stop();
    state = state!.copyWith(
      viewMode: mode,
      progress: 0.0,
      isPlaying: false,
    );
    if (mode == SharedMapViewMode.playback) {
      play();
    }
  }

  /// dot 순번 표시 토글. layer visibility 동기화는 화면이 ref.listen 으로 처리.
  void setShowOrderNumbers(bool value) {
    if (state == null) return;
    if (state!.showOrderNumbers == value) return;
    state = state!.copyWith(showOrderNumbers: value);
  }

  void scrubTo(double progress) {
    _ticker?.stop();
    if (state == null) return;
    final p = progress.clamp(0.0, 1.0);
    // meetings는 BE 정적 데이터 — 스크럽 시 덮어쓰지 않는다.
    state = state!.copyWith(
      progress: p,
      isPlaying: false,
    );
  }

  void _startTicker() {
    _ticker?.dispose();
    _lastTimestamp = 0;

    _ticker = Ticker((elapsed) {
      if (state == null || !state!.isPlaying) return;
      final ms = elapsed.inMilliseconds.toDouble();
      final delta = _lastTimestamp == 0 ? 0 : ms - _lastTimestamp;
      _lastTimestamp = ms;

      final totalMs = state!.totalDurationMs;
      if (totalMs <= 0) return;

      final increment = (delta * state!.speed.multiplier) / totalMs;
      final newProgress = (state!.progress + increment).clamp(0.0, 1.0);

      // meetings는 BE 정적 데이터 — 매 tick 갱신하지 않는다.
      if (newProgress >= 1.0) {
        _ticker?.stop();
        state = state!.copyWith(progress: 1.0, isPlaying: false);
      } else {
        state = state!.copyWith(progress: newProgress);
      }
    })
      ..start();
  }
}

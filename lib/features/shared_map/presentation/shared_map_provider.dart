import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/domain/user_model.dart';
import '../../character/paperdoll/data/paperdoll_legacy_adapter.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
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
  });

  final List<MemberTrack> tracks;
  final double progress;
  final bool isPlaying;
  final PlaySpeed speed;
  final List<MeetingEvent> meetings;

  /// userId → PaperdollConfig. BE 응답의 member.character_config 파싱 결과.
  final Map<String, PaperdollConfig> paperdolls;

  final SharedMapViewMode viewMode;

  SharedMapState copyWith({
    List<MemberTrack>? tracks,
    double? progress,
    bool? isPlaying,
    PlaySpeed? speed,
    List<MeetingEvent>? meetings,
    Map<String, PaperdollConfig>? paperdolls,
    SharedMapViewMode? viewMode,
  }) =>
      SharedMapState(
        tracks: tracks ?? this.tracks,
        progress: progress ?? this.progress,
        isPlaying: isPlaying ?? this.isPlaying,
        speed: speed ?? this.speed,
        meetings: meetings ?? this.meetings,
        paperdolls: paperdolls ?? this.paperdolls,
        viewMode: viewMode ?? this.viewMode,
      );

  double get totalDurationMs => tracks.isEmpty
      ? 0
      : tracks
          .map((t) => t.sequence.totalDurationMs)
          .reduce((a, b) => a > b ? a : b);
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
        state = const SharedMapState(tracks: []);
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
            colorKey: config?['color_key'] as String? ?? 'blue',
          ),
          joinedAt: DateTime.now(),
        );
      }).toList();

      final rawEncounters = data['encounters'] as List? ?? [];
      final meetings = rawEncounters.map((e) {
        final map = e as Map<String, dynamic>;
        final userIds = (map['user_ids'] as List).cast<String>();
        final loc = map['location'] as Map<String, dynamic>;
        return MeetingEvent(
          memberIdA: userIds.isNotEmpty ? userIds[0] : '',
          memberIdB: userIds.length > 1 ? userIds[1] : '',
          lat: (loc['latitude'] as num).toDouble(),
          lng: (loc['longitude'] as num).toDouble(),
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
      state = SharedMapState(
        tracks: tracks,
        meetings: meetings,
        paperdolls: paperdolls,
      );
    } catch (e, st) {
      debugPrint('[SharedMapNotifier] _loadTracks error: $e\n$st');
      state = const SharedMapState(tracks: []);
    }
  }

  static Dot _dotFromApi(Map<String, dynamic> d, String userId) => Dot(
        id: d['id'] as String,
        latitude: (d['latitude'] as num).toDouble(),
        longitude: (d['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(d['timestamp'] as String),
        placeName: d['place_name'] as String?,
        placeCategory: d['place_category'] as String?,
        photoUrl: d['photo_url'] as String?,
        memo: d['memo'] as String?,
        emotion: d['emotion'] as String?,
        dayLogId: d['day_log_id'] as String? ?? userId,
        synced: true,
      );

  static Map<String, String> _colorMapFromApiMembers(List rawMembers) {
    // BE 응답의 character_config.color_key (5색 프리셋) 매핑.
    // 빠진 항목은 RoomMember.character.colorKey 의 default('blue')로 폴백됨.
    final result = <String, String>{};
    for (final m in rawMembers) {
      final map = m as Map<String, dynamic>;
      final userId = map['user_id'] as String;
      final config = map['character_config'] as Map<String, dynamic>?;
      final key = config?['color_key'] as String?;
      if (key != null && key.isNotEmpty) {
        result[userId] = key;
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
  void setViewMode(SharedMapViewMode mode) {
    if (state == null) return;
    if (state!.viewMode == mode) return;
    _ticker?.stop();
    final positions =
        SharedMapBuilder.interpolateAll(state!.tracks, 0.0);
    state = state!.copyWith(
      viewMode: mode,
      progress: 0.0,
      isPlaying: false,
      meetings: SharedMapBuilder.detectMeetings(positions),
    );
    if (mode == SharedMapViewMode.playback) {
      play();
    }
  }

  void scrubTo(double progress) {
    _ticker?.stop();
    if (state == null) return;
    final p = progress.clamp(0.0, 1.0);
    final positions = SharedMapBuilder.interpolateAll(state!.tracks, p);
    state = state!.copyWith(
      progress: p,
      isPlaying: false,
      meetings: SharedMapBuilder.detectMeetings(positions),
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

      final positions =
          SharedMapBuilder.interpolateAll(state!.tracks, newProgress);
      final meetings = SharedMapBuilder.detectMeetings(positions);

      if (newProgress >= 1.0) {
        _ticker?.stop();
        state = state!.copyWith(
            progress: 1.0, isPlaying: false, meetings: meetings);
      } else {
        state = state!.copyWith(
            progress: newProgress, meetings: meetings);
      }
    })
      ..start();
  }
}

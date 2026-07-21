// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myTodoListsHash() => r'33eb9724c64014f77149d48ecfd0832d8b184fec';

/// 내 모든 할일 목록. BE 우선, 오프라인 시 로컬 캐시.
///
/// fetch 전 미동기화 항목을 일괄 push — 오프라인 → 온라인 전환 후 첫 진입 시
/// pending changes 가 BE 응답에 반영됨. [TodoRepository.syncUnsynced] 는
/// in-flight 가드가 있어 동시 호출 안전.
///
/// Copied from [myTodoLists].
@ProviderFor(myTodoLists)
final myTodoListsProvider = AutoDisposeFutureProvider<List<TodoList>>.internal(
  myTodoLists,
  name: r'myTodoListsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myTodoListsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyTodoListsRef = AutoDisposeFutureProviderRef<List<TodoList>>;
String _$todoListByIdHash() => r'bc3d8df201fc79e3047db83cde6f961aec789bd2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 단일 할일 상세 (items 포함). BE 우선.
///
/// Copied from [todoListById].
@ProviderFor(todoListById)
const todoListByIdProvider = TodoListByIdFamily();

/// 단일 할일 상세 (items 포함). BE 우선.
///
/// Copied from [todoListById].
class TodoListByIdFamily extends Family<AsyncValue<TodoList?>> {
  /// 단일 할일 상세 (items 포함). BE 우선.
  ///
  /// Copied from [todoListById].
  const TodoListByIdFamily();

  /// 단일 할일 상세 (items 포함). BE 우선.
  ///
  /// Copied from [todoListById].
  TodoListByIdProvider call(String todoListId) {
    return TodoListByIdProvider(todoListId);
  }

  @override
  TodoListByIdProvider getProviderOverride(
    covariant TodoListByIdProvider provider,
  ) {
    return call(provider.todoListId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'todoListByIdProvider';
}

/// 단일 할일 상세 (items 포함). BE 우선.
///
/// Copied from [todoListById].
class TodoListByIdProvider extends AutoDisposeFutureProvider<TodoList?> {
  /// 단일 할일 상세 (items 포함). BE 우선.
  ///
  /// Copied from [todoListById].
  TodoListByIdProvider(String todoListId)
    : this._internal(
        (ref) => todoListById(ref as TodoListByIdRef, todoListId),
        from: todoListByIdProvider,
        name: r'todoListByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todoListByIdHash,
        dependencies: TodoListByIdFamily._dependencies,
        allTransitiveDependencies:
            TodoListByIdFamily._allTransitiveDependencies,
        todoListId: todoListId,
      );

  TodoListByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.todoListId,
  }) : super.internal();

  final String todoListId;

  @override
  Override overrideWith(
    FutureOr<TodoList?> Function(TodoListByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodoListByIdProvider._internal(
        (ref) => create(ref as TodoListByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        todoListId: todoListId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TodoList?> createElement() {
    return _TodoListByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoListByIdProvider && other.todoListId == todoListId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, todoListId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodoListByIdRef on AutoDisposeFutureProviderRef<TodoList?> {
  /// The parameter `todoListId` of this provider.
  String get todoListId;
}

class _TodoListByIdProviderElement
    extends AutoDisposeFutureProviderElement<TodoList?>
    with TodoListByIdRef {
  _TodoListByIdProviderElement(super.provider);

  @override
  String get todoListId => (origin as TodoListByIdProvider).todoListId;
}

String _$roomTodoListsHash() => r'd352508a37b64db4ae8e4caa3cc30ef5d33d19f3';

/// 룸에 연결된 스팟 리스트 목록.
///
/// Copied from [roomTodoLists].
@ProviderFor(roomTodoLists)
const roomTodoListsProvider = RoomTodoListsFamily();

/// 룸에 연결된 스팟 리스트 목록.
///
/// Copied from [roomTodoLists].
class RoomTodoListsFamily extends Family<AsyncValue<List<TodoList>>> {
  /// 룸에 연결된 스팟 리스트 목록.
  ///
  /// Copied from [roomTodoLists].
  const RoomTodoListsFamily();

  /// 룸에 연결된 스팟 리스트 목록.
  ///
  /// Copied from [roomTodoLists].
  RoomTodoListsProvider call(String roomId) {
    return RoomTodoListsProvider(roomId);
  }

  @override
  RoomTodoListsProvider getProviderOverride(
    covariant RoomTodoListsProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roomTodoListsProvider';
}

/// 룸에 연결된 스팟 리스트 목록.
///
/// Copied from [roomTodoLists].
class RoomTodoListsProvider extends AutoDisposeFutureProvider<List<TodoList>> {
  /// 룸에 연결된 스팟 리스트 목록.
  ///
  /// Copied from [roomTodoLists].
  RoomTodoListsProvider(String roomId)
    : this._internal(
        (ref) => roomTodoLists(ref as RoomTodoListsRef, roomId),
        from: roomTodoListsProvider,
        name: r'roomTodoListsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roomTodoListsHash,
        dependencies: RoomTodoListsFamily._dependencies,
        allTransitiveDependencies:
            RoomTodoListsFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  RoomTodoListsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    FutureOr<List<TodoList>> Function(RoomTodoListsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomTodoListsProvider._internal(
        (ref) => create(ref as RoomTodoListsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TodoList>> createElement() {
    return _RoomTodoListsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomTodoListsProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoomTodoListsRef on AutoDisposeFutureProviderRef<List<TodoList>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomTodoListsProviderElement
    extends AutoDisposeFutureProviderElement<List<TodoList>>
    with RoomTodoListsRef {
  _RoomTodoListsProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomTodoListsProvider).roomId;
}

String _$routeRemoteSourceHash() => r'55ac1f9ec571fa2c2e67347ff5dd4693dc920fca';

/// BE 경로 캐시 엔드포인트 호출 — 앱 공용 ApiClient (인증 헤더 자동 첨부).
///
/// Copied from [routeRemoteSource].
@ProviderFor(routeRemoteSource)
final routeRemoteSourceProvider = Provider<RouteRemoteSource>.internal(
  routeRemoteSource,
  name: r'routeRemoteSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routeRemoteSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouteRemoteSourceRef = ProviderRef<RouteRemoteSource>;
String _$todoDayRouteHash() => r'f77fe33ea5bed5c5e233a7916bb75977eb7c93e7';

/// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
/// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
/// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
///
/// Copied from [todoDayRoute].
@ProviderFor(todoDayRoute)
const todoDayRouteProvider = TodoDayRouteFamily();

/// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
/// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
/// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
///
/// Copied from [todoDayRoute].
class TodoDayRouteFamily extends Family<AsyncValue<DayRoute?>> {
  /// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
  /// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
  /// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
  ///
  /// Copied from [todoDayRoute].
  const TodoDayRouteFamily();

  /// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
  /// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
  /// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
  ///
  /// Copied from [todoDayRoute].
  TodoDayRouteProvider call(String todoListId, int dayIndex) {
    return TodoDayRouteProvider(todoListId, dayIndex);
  }

  @override
  TodoDayRouteProvider getProviderOverride(
    covariant TodoDayRouteProvider provider,
  ) {
    return call(provider.todoListId, provider.dayIndex);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'todoDayRouteProvider';
}

/// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
/// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
/// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
///
/// Copied from [todoDayRoute].
class TodoDayRouteProvider extends AutoDisposeFutureProvider<DayRoute?> {
  /// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
  /// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
  /// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
  ///
  /// Copied from [todoDayRoute].
  TodoDayRouteProvider(String todoListId, int dayIndex)
    : this._internal(
        (ref) => todoDayRoute(ref as TodoDayRouteRef, todoListId, dayIndex),
        from: todoDayRouteProvider,
        name: r'todoDayRouteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todoDayRouteHash,
        dependencies: TodoDayRouteFamily._dependencies,
        allTransitiveDependencies:
            TodoDayRouteFamily._allTransitiveDependencies,
        todoListId: todoListId,
        dayIndex: dayIndex,
      );

  TodoDayRouteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.todoListId,
    required this.dayIndex,
  }) : super.internal();

  final String todoListId;
  final int dayIndex;

  @override
  Override overrideWith(
    FutureOr<DayRoute?> Function(TodoDayRouteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodoDayRouteProvider._internal(
        (ref) => create(ref as TodoDayRouteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        todoListId: todoListId,
        dayIndex: dayIndex,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DayRoute?> createElement() {
    return _TodoDayRouteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoDayRouteProvider &&
        other.todoListId == todoListId &&
        other.dayIndex == dayIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, todoListId.hashCode);
    hash = _SystemHash.combine(hash, dayIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodoDayRouteRef on AutoDisposeFutureProviderRef<DayRoute?> {
  /// The parameter `todoListId` of this provider.
  String get todoListId;

  /// The parameter `dayIndex` of this provider.
  int get dayIndex;
}

class _TodoDayRouteProviderElement
    extends AutoDisposeFutureProviderElement<DayRoute?>
    with TodoDayRouteRef {
  _TodoDayRouteProviderElement(super.provider);

  @override
  String get todoListId => (origin as TodoDayRouteProvider).todoListId;
  @override
  int get dayIndex => (origin as TodoDayRouteProvider).dayIndex;
}

String _$activeTodoListHash() => r'60920de778a6abc1a741da0ebdef2620134018b3';

/// 현재 활성 컬렉션 (없으면 null — 빈 상태).
///
/// 우선순위:
///   1) 마지막 선택 id 가 존재하고 해당 컬렉션이 살아있으면 그것
///   2) 컬렉션이 1개 이상 있으면 가장 최근 created
///   3) 아예 없으면 null (호출자가 빈 상태 UI 처리 — default 자동 생성 *안 함*)
///
/// 이전 동작에서 default "내 스팟" 자동 생성을 두었으나, 메인 화면이 *컬렉션
/// 리스트* 로 재설계되면서 사용자가 명시적으로 만드는 흐름으로 통일.
/// 빈 상태 UI 가 onboarding 역할.
///
/// Copied from [activeTodoList].
@ProviderFor(activeTodoList)
final activeTodoListProvider = AutoDisposeFutureProvider<TodoList?>.internal(
  activeTodoList,
  name: r'activeTodoListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTodoListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTodoListRef = AutoDisposeFutureProviderRef<TodoList?>;
String _$todoMapFocusHash() => r'245212f5a03a224ffb3a260cd3605723ae940c21';

/// 상세 시트 "지도" 버튼 → 지도 뷰 전환 + 해당 스팟으로 카메라 이동 요청.
/// todo_map_screen 이 listen 해 지도 뷰로 전환하고, todo_map_view 가
/// 카메라 이동 후 clear() 한다.
///
/// Copied from [TodoMapFocus].
@ProviderFor(TodoMapFocus)
final todoMapFocusProvider = NotifierProvider<TodoMapFocus, TodoItem?>.internal(
  TodoMapFocus.new,
  name: r'todoMapFocusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todoMapFocusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodoMapFocus = Notifier<TodoItem?>;
String _$selectedTodoListIdHash() =>
    r'7ad8c38b430f83454f95a328dc732059700be714';

/// 마지막 선택한 컬렉션 id 를 SharedPreferences 에 영속.
/// 재진입 시 사용자가 마지막 본 컬렉션이 자동 표시됨.
///
/// Copied from [SelectedTodoListId].
@ProviderFor(SelectedTodoListId)
final selectedTodoListIdProvider =
    AsyncNotifierProvider<SelectedTodoListId, String?>.internal(
      SelectedTodoListId.new,
      name: r'selectedTodoListIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedTodoListIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedTodoListId = AsyncNotifier<String?>;
String _$todoNotifierHash() => r'183033060594fe03bc08849eac21ff3eb781059b';

/// 할일 CRUD / 체크인 등 변경 작업.
/// `AsyncValue<void>` 로 로딩/에러 상태 관리.
///
/// Copied from [TodoNotifier].
@ProviderFor(TodoNotifier)
final todoNotifierProvider =
    AutoDisposeNotifierProvider<TodoNotifier, AsyncValue<void>>.internal(
      TodoNotifier.new,
      name: r'todoNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

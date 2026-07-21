// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$popularTagsHash() => r'ae7ad14b6d38a902e20bc97191c1c25cfd94720e';

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

/// 인기 태그 (검색 화면 첫 진입 chip cloud).
///
/// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
/// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
///
/// Copied from [popularTags].
@ProviderFor(popularTags)
const popularTagsProvider = PopularTagsFamily();

/// 인기 태그 (검색 화면 첫 진입 chip cloud).
///
/// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
/// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
///
/// Copied from [popularTags].
class PopularTagsFamily extends Family<AsyncValue<List<TagWithCount>>> {
  /// 인기 태그 (검색 화면 첫 진입 chip cloud).
  ///
  /// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
  /// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
  ///
  /// Copied from [popularTags].
  const PopularTagsFamily();

  /// 인기 태그 (검색 화면 첫 진입 chip cloud).
  ///
  /// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
  /// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
  ///
  /// Copied from [popularTags].
  PopularTagsProvider call({String? roomId}) {
    return PopularTagsProvider(roomId: roomId);
  }

  @override
  PopularTagsProvider getProviderOverride(
    covariant PopularTagsProvider provider,
  ) {
    return call(roomId: provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'popularTagsProvider';
}

/// 인기 태그 (검색 화면 첫 진입 chip cloud).
///
/// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
/// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
///
/// Copied from [popularTags].
class PopularTagsProvider
    extends AutoDisposeFutureProvider<List<TagWithCount>> {
  /// 인기 태그 (검색 화면 첫 진입 chip cloud).
  ///
  /// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
  /// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
  ///
  /// Copied from [popularTags].
  PopularTagsProvider({String? roomId})
    : this._internal(
        (ref) => popularTags(ref as PopularTagsRef, roomId: roomId),
        from: popularTagsProvider,
        name: r'popularTagsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$popularTagsHash,
        dependencies: PopularTagsFamily._dependencies,
        allTransitiveDependencies: PopularTagsFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  PopularTagsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String? roomId;

  @override
  Override overrideWith(
    FutureOr<List<TagWithCount>> Function(PopularTagsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PopularTagsProvider._internal(
        (ref) => create(ref as PopularTagsRef),
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
  AutoDisposeFutureProviderElement<List<TagWithCount>> createElement() {
    return _PopularTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PopularTagsProvider && other.roomId == roomId;
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
mixin PopularTagsRef on AutoDisposeFutureProviderRef<List<TagWithCount>> {
  /// The parameter `roomId` of this provider.
  String? get roomId;
}

class _PopularTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<TagWithCount>>
    with PopularTagsRef {
  _PopularTagsProviderElement(super.provider);

  @override
  String? get roomId => (origin as PopularTagsProvider).roomId;
}

String _$tagAutocompleteHash() => r'3ffb943ac27ad06f42f7c70061cf4e47d4ce8074';

/// 자동완성 — `prefix` 별로 family.
/// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
///
/// Copied from [tagAutocomplete].
@ProviderFor(tagAutocomplete)
const tagAutocompleteProvider = TagAutocompleteFamily();

/// 자동완성 — `prefix` 별로 family.
/// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
///
/// Copied from [tagAutocomplete].
class TagAutocompleteFamily extends Family<AsyncValue<List<String>>> {
  /// 자동완성 — `prefix` 별로 family.
  /// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
  ///
  /// Copied from [tagAutocomplete].
  const TagAutocompleteFamily();

  /// 자동완성 — `prefix` 별로 family.
  /// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
  ///
  /// Copied from [tagAutocomplete].
  TagAutocompleteProvider call(String prefix) {
    return TagAutocompleteProvider(prefix);
  }

  @override
  TagAutocompleteProvider getProviderOverride(
    covariant TagAutocompleteProvider provider,
  ) {
    return call(provider.prefix);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tagAutocompleteProvider';
}

/// 자동완성 — `prefix` 별로 family.
/// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
///
/// Copied from [tagAutocomplete].
class TagAutocompleteProvider extends AutoDisposeFutureProvider<List<String>> {
  /// 자동완성 — `prefix` 별로 family.
  /// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
  ///
  /// Copied from [tagAutocomplete].
  TagAutocompleteProvider(String prefix)
    : this._internal(
        (ref) => tagAutocomplete(ref as TagAutocompleteRef, prefix),
        from: tagAutocompleteProvider,
        name: r'tagAutocompleteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tagAutocompleteHash,
        dependencies: TagAutocompleteFamily._dependencies,
        allTransitiveDependencies:
            TagAutocompleteFamily._allTransitiveDependencies,
        prefix: prefix,
      );

  TagAutocompleteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.prefix,
  }) : super.internal();

  final String prefix;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(TagAutocompleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagAutocompleteProvider._internal(
        (ref) => create(ref as TagAutocompleteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        prefix: prefix,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _TagAutocompleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagAutocompleteProvider && other.prefix == prefix;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, prefix.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TagAutocompleteRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `prefix` of this provider.
  String get prefix;
}

class _TagAutocompleteProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with TagAutocompleteRef {
  _TagAutocompleteProviderElement(super.provider);

  @override
  String get prefix => (origin as TagAutocompleteProvider).prefix;
}

String _$tagSearchHash() => r'221f4e1dee55d21f3340e6bd59472ef848b88c2f';

/// 검색 화면 상태 — 입력된 태그 + 매칭 모드 + 결과.
///
/// Copied from [TagSearch].
@ProviderFor(TagSearch)
final tagSearchProvider =
    AutoDisposeNotifierProvider<TagSearch, TagSearchState>.internal(
      TagSearch.new,
      name: r'tagSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tagSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TagSearch = AutoDisposeNotifier<TagSearchState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

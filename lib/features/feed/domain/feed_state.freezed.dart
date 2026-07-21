// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FeedState {
  List<FeedEntry> get entries => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedStateCopyWith<FeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedStateCopyWith<$Res> {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) then) =
      _$FeedStateCopyWithImpl<$Res, FeedState>;
  @useResult
  $Res call({
    List<FeedEntry> entries,
    String? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class _$FeedStateCopyWithImpl<$Res, $Val extends FeedState>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
  }) {
    return _then(
      _value.copyWith(
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<FeedEntry>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
    _$FeedStateImpl value,
    $Res Function(_$FeedStateImpl) then,
  ) = __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FeedEntry> entries,
    String? nextCursor,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
    _$FeedStateImpl _value,
    $Res Function(_$FeedStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? nextCursor = freezed,
    Object? hasMore = null,
    Object? isLoadingMore = null,
  }) {
    return _then(
      _$FeedStateImpl(
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<FeedEntry>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FeedStateImpl implements _FeedState {
  const _$FeedStateImpl({
    required final List<FeedEntry> entries,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  }) : _entries = entries;

  final List<FeedEntry> _entries;
  @override
  List<FeedEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final String? nextCursor;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'FeedState(entries: $entries, nextCursor: $nextCursor, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entries),
    nextCursor,
    hasMore,
    isLoadingMore,
  );

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState implements FeedState {
  const factory _FeedState({
    required final List<FeedEntry> entries,
    final String? nextCursor,
    final bool hasMore,
    final bool isLoadingMore,
  }) = _$FeedStateImpl;

  @override
  List<FeedEntry> get entries;
  @override
  String? get nextCursor;
  @override
  bool get hasMore;
  @override
  bool get isLoadingMore;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

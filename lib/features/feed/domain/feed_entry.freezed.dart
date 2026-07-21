// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FeedEntry {
  Dot get dot => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get authorNickname => throw _privateConstructorUsedError;
  String get authorColorHex => throw _privateConstructorUsedError;
  bool get isMine => throw _privateConstructorUsedError;
  Set<String> get sharedRoomIds => throw _privateConstructorUsedError;

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedEntryCopyWith<FeedEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedEntryCopyWith<$Res> {
  factory $FeedEntryCopyWith(FeedEntry value, $Res Function(FeedEntry) then) =
      _$FeedEntryCopyWithImpl<$Res, FeedEntry>;
  @useResult
  $Res call({
    Dot dot,
    String authorId,
    String authorNickname,
    String authorColorHex,
    bool isMine,
    Set<String> sharedRoomIds,
  });

  $DotCopyWith<$Res> get dot;
}

/// @nodoc
class _$FeedEntryCopyWithImpl<$Res, $Val extends FeedEntry>
    implements $FeedEntryCopyWith<$Res> {
  _$FeedEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dot = null,
    Object? authorId = null,
    Object? authorNickname = null,
    Object? authorColorHex = null,
    Object? isMine = null,
    Object? sharedRoomIds = null,
  }) {
    return _then(
      _value.copyWith(
            dot: null == dot
                ? _value.dot
                : dot // ignore: cast_nullable_to_non_nullable
                      as Dot,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorNickname: null == authorNickname
                ? _value.authorNickname
                : authorNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            authorColorHex: null == authorColorHex
                ? _value.authorColorHex
                : authorColorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            isMine: null == isMine
                ? _value.isMine
                : isMine // ignore: cast_nullable_to_non_nullable
                      as bool,
            sharedRoomIds: null == sharedRoomIds
                ? _value.sharedRoomIds
                : sharedRoomIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCopyWith<$Res> get dot {
    return $DotCopyWith<$Res>(_value.dot, (value) {
      return _then(_value.copyWith(dot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedEntryImplCopyWith<$Res>
    implements $FeedEntryCopyWith<$Res> {
  factory _$$FeedEntryImplCopyWith(
    _$FeedEntryImpl value,
    $Res Function(_$FeedEntryImpl) then,
  ) = __$$FeedEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Dot dot,
    String authorId,
    String authorNickname,
    String authorColorHex,
    bool isMine,
    Set<String> sharedRoomIds,
  });

  @override
  $DotCopyWith<$Res> get dot;
}

/// @nodoc
class __$$FeedEntryImplCopyWithImpl<$Res>
    extends _$FeedEntryCopyWithImpl<$Res, _$FeedEntryImpl>
    implements _$$FeedEntryImplCopyWith<$Res> {
  __$$FeedEntryImplCopyWithImpl(
    _$FeedEntryImpl _value,
    $Res Function(_$FeedEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dot = null,
    Object? authorId = null,
    Object? authorNickname = null,
    Object? authorColorHex = null,
    Object? isMine = null,
    Object? sharedRoomIds = null,
  }) {
    return _then(
      _$FeedEntryImpl(
        dot: null == dot
            ? _value.dot
            : dot // ignore: cast_nullable_to_non_nullable
                  as Dot,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorNickname: null == authorNickname
            ? _value.authorNickname
            : authorNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        authorColorHex: null == authorColorHex
            ? _value.authorColorHex
            : authorColorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        isMine: null == isMine
            ? _value.isMine
            : isMine // ignore: cast_nullable_to_non_nullable
                  as bool,
        sharedRoomIds: null == sharedRoomIds
            ? _value._sharedRoomIds
            : sharedRoomIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// @nodoc

class _$FeedEntryImpl implements _FeedEntry {
  const _$FeedEntryImpl({
    required this.dot,
    required this.authorId,
    required this.authorNickname,
    required this.authorColorHex,
    required this.isMine,
    final Set<String> sharedRoomIds = const <String>{},
  }) : _sharedRoomIds = sharedRoomIds;

  @override
  final Dot dot;
  @override
  final String authorId;
  @override
  final String authorNickname;
  @override
  final String authorColorHex;
  @override
  final bool isMine;
  final Set<String> _sharedRoomIds;
  @override
  @JsonKey()
  Set<String> get sharedRoomIds {
    if (_sharedRoomIds is EqualUnmodifiableSetView) return _sharedRoomIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_sharedRoomIds);
  }

  @override
  String toString() {
    return 'FeedEntry(dot: $dot, authorId: $authorId, authorNickname: $authorNickname, authorColorHex: $authorColorHex, isMine: $isMine, sharedRoomIds: $sharedRoomIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedEntryImpl &&
            (identical(other.dot, dot) || other.dot == dot) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorNickname, authorNickname) ||
                other.authorNickname == authorNickname) &&
            (identical(other.authorColorHex, authorColorHex) ||
                other.authorColorHex == authorColorHex) &&
            (identical(other.isMine, isMine) || other.isMine == isMine) &&
            const DeepCollectionEquality().equals(
              other._sharedRoomIds,
              _sharedRoomIds,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    dot,
    authorId,
    authorNickname,
    authorColorHex,
    isMine,
    const DeepCollectionEquality().hash(_sharedRoomIds),
  );

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedEntryImplCopyWith<_$FeedEntryImpl> get copyWith =>
      __$$FeedEntryImplCopyWithImpl<_$FeedEntryImpl>(this, _$identity);
}

abstract class _FeedEntry implements FeedEntry {
  const factory _FeedEntry({
    required final Dot dot,
    required final String authorId,
    required final String authorNickname,
    required final String authorColorHex,
    required final bool isMine,
    final Set<String> sharedRoomIds,
  }) = _$FeedEntryImpl;

  @override
  Dot get dot;
  @override
  String get authorId;
  @override
  String get authorNickname;
  @override
  String get authorColorHex;
  @override
  bool get isMine;
  @override
  Set<String> get sharedRoomIds;

  /// Create a copy of FeedEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedEntryImplCopyWith<_$FeedEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

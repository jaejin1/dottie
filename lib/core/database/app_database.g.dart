// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DotTableTable extends DotTable
    with TableInfo<$DotTableTable, DotTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DotTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeCategoryMeta = const VerificationMeta(
    'placeCategory',
  );
  @override
  late final GeneratedColumn<String> placeCategory = GeneratedColumn<String>(
    'place_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoLocalPathMeta = const VerificationMeta(
    'photoLocalPath',
  );
  @override
  late final GeneratedColumn<String> photoLocalPath = GeneratedColumn<String>(
    'photo_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoThumbUrlMeta = const VerificationMeta(
    'photoThumbUrl',
  );
  @override
  late final GeneratedColumn<String> photoThumbUrl = GeneratedColumn<String>(
    'photo_thumb_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPreviewUrlMeta = const VerificationMeta(
    'photoPreviewUrl',
  );
  @override
  late final GeneratedColumn<String> photoPreviewUrl = GeneratedColumn<String>(
    'photo_preview_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayLogIdMeta = const VerificationMeta(
    'dayLogId',
  );
  @override
  late final GeneratedColumn<String> dayLogId = GeneratedColumn<String>(
    'day_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sharedRoomIdsJsonMeta = const VerificationMeta(
    'sharedRoomIdsJson',
  );
  @override
  late final GeneratedColumn<String> sharedRoomIdsJson =
      GeneratedColumn<String>(
        'shared_room_ids_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    timestamp,
    placeName,
    placeCategory,
    photoLocalPath,
    photoUrl,
    photoThumbUrl,
    photoPreviewUrl,
    memo,
    emotion,
    dayLogId,
    tagsJson,
    sharedRoomIdsJson,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dot_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DotTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    }
    if (data.containsKey('place_category')) {
      context.handle(
        _placeCategoryMeta,
        placeCategory.isAcceptableOrUnknown(
          data['place_category']!,
          _placeCategoryMeta,
        ),
      );
    }
    if (data.containsKey('photo_local_path')) {
      context.handle(
        _photoLocalPathMeta,
        photoLocalPath.isAcceptableOrUnknown(
          data['photo_local_path']!,
          _photoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('photo_thumb_url')) {
      context.handle(
        _photoThumbUrlMeta,
        photoThumbUrl.isAcceptableOrUnknown(
          data['photo_thumb_url']!,
          _photoThumbUrlMeta,
        ),
      );
    }
    if (data.containsKey('photo_preview_url')) {
      context.handle(
        _photoPreviewUrlMeta,
        photoPreviewUrl.isAcceptableOrUnknown(
          data['photo_preview_url']!,
          _photoPreviewUrlMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    }
    if (data.containsKey('day_log_id')) {
      context.handle(
        _dayLogIdMeta,
        dayLogId.isAcceptableOrUnknown(data['day_log_id']!, _dayLogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayLogIdMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('shared_room_ids_json')) {
      context.handle(
        _sharedRoomIdsJsonMeta,
        sharedRoomIdsJson.isAcceptableOrUnknown(
          data['shared_room_ids_json']!,
          _sharedRoomIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DotTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DotTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      ),
      placeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category'],
      ),
      photoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_local_path'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      photoThumbUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_thumb_url'],
      ),
      photoPreviewUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_preview_url'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      ),
      dayLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_log_id'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      sharedRoomIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shared_room_ids_json'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $DotTableTable createAlias(String alias) {
    return $DotTableTable(attachedDatabase, alias);
  }
}

class DotTableData extends DataClass implements Insertable<DotTableData> {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? placeName;
  final String? placeCategory;
  final String? photoLocalPath;
  final String? photoUrl;
  final String? photoThumbUrl;
  final String? photoPreviewUrl;
  final String? memo;
  final String? emotion;
  final String dayLogId;
  final String tagsJson;
  final String? sharedRoomIdsJson;
  final bool synced;
  const DotTableData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.placeName,
    this.placeCategory,
    this.photoLocalPath,
    this.photoUrl,
    this.photoThumbUrl,
    this.photoPreviewUrl,
    this.memo,
    this.emotion,
    required this.dayLogId,
    required this.tagsJson,
    this.sharedRoomIdsJson,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    if (!nullToAbsent || placeCategory != null) {
      map['place_category'] = Variable<String>(placeCategory);
    }
    if (!nullToAbsent || photoLocalPath != null) {
      map['photo_local_path'] = Variable<String>(photoLocalPath);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || photoThumbUrl != null) {
      map['photo_thumb_url'] = Variable<String>(photoThumbUrl);
    }
    if (!nullToAbsent || photoPreviewUrl != null) {
      map['photo_preview_url'] = Variable<String>(photoPreviewUrl);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    map['day_log_id'] = Variable<String>(dayLogId);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || sharedRoomIdsJson != null) {
      map['shared_room_ids_json'] = Variable<String>(sharedRoomIdsJson);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DotTableCompanion toCompanion(bool nullToAbsent) {
    return DotTableCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      timestamp: Value(timestamp),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      placeCategory: placeCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCategory),
      photoLocalPath: photoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoLocalPath),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      photoThumbUrl: photoThumbUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoThumbUrl),
      photoPreviewUrl: photoPreviewUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPreviewUrl),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      emotion: emotion == null && nullToAbsent
          ? const Value.absent()
          : Value(emotion),
      dayLogId: Value(dayLogId),
      tagsJson: Value(tagsJson),
      sharedRoomIdsJson: sharedRoomIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedRoomIdsJson),
      synced: Value(synced),
    );
  }

  factory DotTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DotTableData(
      id: serializer.fromJson<String>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      placeCategory: serializer.fromJson<String?>(json['placeCategory']),
      photoLocalPath: serializer.fromJson<String?>(json['photoLocalPath']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      photoThumbUrl: serializer.fromJson<String?>(json['photoThumbUrl']),
      photoPreviewUrl: serializer.fromJson<String?>(json['photoPreviewUrl']),
      memo: serializer.fromJson<String?>(json['memo']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      dayLogId: serializer.fromJson<String>(json['dayLogId']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      sharedRoomIdsJson: serializer.fromJson<String?>(
        json['sharedRoomIdsJson'],
      ),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'placeName': serializer.toJson<String?>(placeName),
      'placeCategory': serializer.toJson<String?>(placeCategory),
      'photoLocalPath': serializer.toJson<String?>(photoLocalPath),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'photoThumbUrl': serializer.toJson<String?>(photoThumbUrl),
      'photoPreviewUrl': serializer.toJson<String?>(photoPreviewUrl),
      'memo': serializer.toJson<String?>(memo),
      'emotion': serializer.toJson<String?>(emotion),
      'dayLogId': serializer.toJson<String>(dayLogId),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'sharedRoomIdsJson': serializer.toJson<String?>(sharedRoomIdsJson),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DotTableData copyWith({
    String? id,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    Value<String?> placeName = const Value.absent(),
    Value<String?> placeCategory = const Value.absent(),
    Value<String?> photoLocalPath = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> photoThumbUrl = const Value.absent(),
    Value<String?> photoPreviewUrl = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    String? dayLogId,
    String? tagsJson,
    Value<String?> sharedRoomIdsJson = const Value.absent(),
    bool? synced,
  }) => DotTableData(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timestamp: timestamp ?? this.timestamp,
    placeName: placeName.present ? placeName.value : this.placeName,
    placeCategory: placeCategory.present
        ? placeCategory.value
        : this.placeCategory,
    photoLocalPath: photoLocalPath.present
        ? photoLocalPath.value
        : this.photoLocalPath,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    photoThumbUrl: photoThumbUrl.present
        ? photoThumbUrl.value
        : this.photoThumbUrl,
    photoPreviewUrl: photoPreviewUrl.present
        ? photoPreviewUrl.value
        : this.photoPreviewUrl,
    memo: memo.present ? memo.value : this.memo,
    emotion: emotion.present ? emotion.value : this.emotion,
    dayLogId: dayLogId ?? this.dayLogId,
    tagsJson: tagsJson ?? this.tagsJson,
    sharedRoomIdsJson: sharedRoomIdsJson.present
        ? sharedRoomIdsJson.value
        : this.sharedRoomIdsJson,
    synced: synced ?? this.synced,
  );
  DotTableData copyWithCompanion(DotTableCompanion data) {
    return DotTableData(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      placeCategory: data.placeCategory.present
          ? data.placeCategory.value
          : this.placeCategory,
      photoLocalPath: data.photoLocalPath.present
          ? data.photoLocalPath.value
          : this.photoLocalPath,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoThumbUrl: data.photoThumbUrl.present
          ? data.photoThumbUrl.value
          : this.photoThumbUrl,
      photoPreviewUrl: data.photoPreviewUrl.present
          ? data.photoPreviewUrl.value
          : this.photoPreviewUrl,
      memo: data.memo.present ? data.memo.value : this.memo,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      dayLogId: data.dayLogId.present ? data.dayLogId.value : this.dayLogId,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      sharedRoomIdsJson: data.sharedRoomIdsJson.present
          ? data.sharedRoomIdsJson.value
          : this.sharedRoomIdsJson,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DotTableData(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoThumbUrl: $photoThumbUrl, ')
          ..write('photoPreviewUrl: $photoPreviewUrl, ')
          ..write('memo: $memo, ')
          ..write('emotion: $emotion, ')
          ..write('dayLogId: $dayLogId, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sharedRoomIdsJson: $sharedRoomIdsJson, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    latitude,
    longitude,
    timestamp,
    placeName,
    placeCategory,
    photoLocalPath,
    photoUrl,
    photoThumbUrl,
    photoPreviewUrl,
    memo,
    emotion,
    dayLogId,
    tagsJson,
    sharedRoomIdsJson,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DotTableData &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.timestamp == this.timestamp &&
          other.placeName == this.placeName &&
          other.placeCategory == this.placeCategory &&
          other.photoLocalPath == this.photoLocalPath &&
          other.photoUrl == this.photoUrl &&
          other.photoThumbUrl == this.photoThumbUrl &&
          other.photoPreviewUrl == this.photoPreviewUrl &&
          other.memo == this.memo &&
          other.emotion == this.emotion &&
          other.dayLogId == this.dayLogId &&
          other.tagsJson == this.tagsJson &&
          other.sharedRoomIdsJson == this.sharedRoomIdsJson &&
          other.synced == this.synced);
}

class DotTableCompanion extends UpdateCompanion<DotTableData> {
  final Value<String> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> timestamp;
  final Value<String?> placeName;
  final Value<String?> placeCategory;
  final Value<String?> photoLocalPath;
  final Value<String?> photoUrl;
  final Value<String?> photoThumbUrl;
  final Value<String?> photoPreviewUrl;
  final Value<String?> memo;
  final Value<String?> emotion;
  final Value<String> dayLogId;
  final Value<String> tagsJson;
  final Value<String?> sharedRoomIdsJson;
  final Value<bool> synced;
  final Value<int> rowid;
  const DotTableCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.placeName = const Value.absent(),
    this.placeCategory = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoThumbUrl = const Value.absent(),
    this.photoPreviewUrl = const Value.absent(),
    this.memo = const Value.absent(),
    this.emotion = const Value.absent(),
    this.dayLogId = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.sharedRoomIdsJson = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DotTableCompanion.insert({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    this.placeName = const Value.absent(),
    this.placeCategory = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoThumbUrl = const Value.absent(),
    this.photoPreviewUrl = const Value.absent(),
    this.memo = const Value.absent(),
    this.emotion = const Value.absent(),
    required String dayLogId,
    this.tagsJson = const Value.absent(),
    this.sharedRoomIdsJson = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       latitude = Value(latitude),
       longitude = Value(longitude),
       timestamp = Value(timestamp),
       dayLogId = Value(dayLogId);
  static Insertable<DotTableData> custom({
    Expression<String>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? timestamp,
    Expression<String>? placeName,
    Expression<String>? placeCategory,
    Expression<String>? photoLocalPath,
    Expression<String>? photoUrl,
    Expression<String>? photoThumbUrl,
    Expression<String>? photoPreviewUrl,
    Expression<String>? memo,
    Expression<String>? emotion,
    Expression<String>? dayLogId,
    Expression<String>? tagsJson,
    Expression<String>? sharedRoomIdsJson,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (timestamp != null) 'timestamp': timestamp,
      if (placeName != null) 'place_name': placeName,
      if (placeCategory != null) 'place_category': placeCategory,
      if (photoLocalPath != null) 'photo_local_path': photoLocalPath,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoThumbUrl != null) 'photo_thumb_url': photoThumbUrl,
      if (photoPreviewUrl != null) 'photo_preview_url': photoPreviewUrl,
      if (memo != null) 'memo': memo,
      if (emotion != null) 'emotion': emotion,
      if (dayLogId != null) 'day_log_id': dayLogId,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (sharedRoomIdsJson != null) 'shared_room_ids_json': sharedRoomIdsJson,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DotTableCompanion copyWith({
    Value<String>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? timestamp,
    Value<String?>? placeName,
    Value<String?>? placeCategory,
    Value<String?>? photoLocalPath,
    Value<String?>? photoUrl,
    Value<String?>? photoThumbUrl,
    Value<String?>? photoPreviewUrl,
    Value<String?>? memo,
    Value<String?>? emotion,
    Value<String>? dayLogId,
    Value<String>? tagsJson,
    Value<String?>? sharedRoomIdsJson,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return DotTableCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      placeName: placeName ?? this.placeName,
      placeCategory: placeCategory ?? this.placeCategory,
      photoLocalPath: photoLocalPath ?? this.photoLocalPath,
      photoUrl: photoUrl ?? this.photoUrl,
      photoThumbUrl: photoThumbUrl ?? this.photoThumbUrl,
      photoPreviewUrl: photoPreviewUrl ?? this.photoPreviewUrl,
      memo: memo ?? this.memo,
      emotion: emotion ?? this.emotion,
      dayLogId: dayLogId ?? this.dayLogId,
      tagsJson: tagsJson ?? this.tagsJson,
      sharedRoomIdsJson: sharedRoomIdsJson ?? this.sharedRoomIdsJson,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (placeCategory.present) {
      map['place_category'] = Variable<String>(placeCategory.value);
    }
    if (photoLocalPath.present) {
      map['photo_local_path'] = Variable<String>(photoLocalPath.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoThumbUrl.present) {
      map['photo_thumb_url'] = Variable<String>(photoThumbUrl.value);
    }
    if (photoPreviewUrl.present) {
      map['photo_preview_url'] = Variable<String>(photoPreviewUrl.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (dayLogId.present) {
      map['day_log_id'] = Variable<String>(dayLogId.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (sharedRoomIdsJson.present) {
      map['shared_room_ids_json'] = Variable<String>(sharedRoomIdsJson.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DotTableCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('timestamp: $timestamp, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoThumbUrl: $photoThumbUrl, ')
          ..write('photoPreviewUrl: $photoPreviewUrl, ')
          ..write('memo: $memo, ')
          ..write('emotion: $emotion, ')
          ..write('dayLogId: $dayLogId, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sharedRoomIdsJson: $sharedRoomIdsJson, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayLogTableTable extends DayLogTable
    with TableInfo<$DayLogTableTable, DayLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecordingMeta = const VerificationMeta(
    'isRecording',
  );
  @override
  late final GeneratedColumn<bool> isRecording = GeneratedColumn<bool>(
    'is_recording',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recording" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    date,
    startedAt,
    endedAt,
    isRecording,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_log_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('is_recording')) {
      context.handle(
        _isRecordingMeta,
        isRecording.isAcceptableOrUnknown(
          data['is_recording']!,
          _isRecordingMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      isRecording: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recording'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $DayLogTableTable createAlias(String alias) {
    return $DayLogTableTable(attachedDatabase, alias);
  }
}

class DayLogTableData extends DataClass implements Insertable<DayLogTableData> {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isRecording;
  final bool synced;
  const DayLogTableData({
    required this.id,
    required this.userId,
    required this.date,
    required this.startedAt,
    this.endedAt,
    required this.isRecording,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<DateTime>(date);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['is_recording'] = Variable<bool>(isRecording);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DayLogTableCompanion toCompanion(bool nullToAbsent) {
    return DayLogTableCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      isRecording: Value(isRecording),
      synced: Value(synced),
    );
  }

  factory DayLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLogTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<DateTime>(json['date']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      isRecording: serializer.fromJson<bool>(json['isRecording']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<DateTime>(date),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'isRecording': serializer.toJson<bool>(isRecording),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DayLogTableData copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    bool? isRecording,
    bool? synced,
  }) => DayLogTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    date: date ?? this.date,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    isRecording: isRecording ?? this.isRecording,
    synced: synced ?? this.synced,
  );
  DayLogTableData copyWithCompanion(DayLogTableCompanion data) {
    return DayLogTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      isRecording: data.isRecording.present
          ? data.isRecording.value
          : this.isRecording,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLogTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('isRecording: $isRecording, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, date, startedAt, endedAt, isRecording, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLogTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.isRecording == this.isRecording &&
          other.synced == this.synced);
}

class DayLogTableCompanion extends UpdateCompanion<DayLogTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> date;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> isRecording;
  final Value<bool> synced;
  final Value<int> rowid;
  const DayLogTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.isRecording = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayLogTableCompanion.insert({
    required String id,
    required String userId,
    required DateTime date,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.isRecording = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       startedAt = Value(startedAt);
  static Insertable<DayLogTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? date,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? isRecording,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (isRecording != null) 'is_recording': isRecording,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? date,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<bool>? isRecording,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return DayLogTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isRecording: isRecording ?? this.isRecording,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (isRecording.present) {
      map['is_recording'] = Variable<bool>(isRecording.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('isRecording: $isRecording, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoListTableTable extends TodoListTable
    with TableInfo<$TodoListTableTable, TodoListTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoListTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverEmojiMeta = const VerificationMeta(
    'coverEmoji',
  );
  @override
  late final GeneratedColumn<String> coverEmoji = GeneratedColumn<String>(
    'cover_emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shareTokenMeta = const VerificationMeta(
    'shareToken',
  );
  @override
  late final GeneratedColumn<String> shareToken = GeneratedColumn<String>(
    'share_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareTokenExpiresAtMeta =
      const VerificationMeta('shareTokenExpiresAt');
  @override
  late final GeneratedColumn<DateTime> shareTokenExpiresAt =
      GeneratedColumn<DateTime>(
        'share_token_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _courseTypeMeta = const VerificationMeta(
    'courseType',
  );
  @override
  late final GeneratedColumn<String> courseType = GeneratedColumn<String>(
    'course_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('trip'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _coverImageUrlMeta = const VerificationMeta(
    'coverImageUrl',
  );
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
    'cover_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('private'),
  );
  static const VerificationMeta _isImportedMeta = const VerificationMeta(
    'isImported',
  );
  @override
  late final GeneratedColumn<bool> isImported = GeneratedColumn<bool>(
    'is_imported',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_imported" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _membersJsonMeta = const VerificationMeta(
    'membersJson',
  );
  @override
  late final GeneratedColumn<String> membersJson = GeneratedColumn<String>(
    'members_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinOrderMeta = const VerificationMeta(
    'pinOrder',
  );
  @override
  late final GeneratedColumn<int> pinOrder = GeneratedColumn<int>(
    'pin_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    coverEmoji,
    startDate,
    endDate,
    shareToken,
    shareTokenExpiresAt,
    createdAt,
    updatedAt,
    synced,
    courseType,
    description,
    tagsJson,
    coverImageUrl,
    visibility,
    isImported,
    membersJson,
    isPinned,
    pinOrder,
    likeCount,
    region,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_list_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoListTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_emoji')) {
      context.handle(
        _coverEmojiMeta,
        coverEmoji.isAcceptableOrUnknown(data['cover_emoji']!, _coverEmojiMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('share_token')) {
      context.handle(
        _shareTokenMeta,
        shareToken.isAcceptableOrUnknown(data['share_token']!, _shareTokenMeta),
      );
    }
    if (data.containsKey('share_token_expires_at')) {
      context.handle(
        _shareTokenExpiresAtMeta,
        shareTokenExpiresAt.isAcceptableOrUnknown(
          data['share_token_expires_at']!,
          _shareTokenExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('course_type')) {
      context.handle(
        _courseTypeMeta,
        courseType.isAcceptableOrUnknown(data['course_type']!, _courseTypeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
        _coverImageUrlMeta,
        coverImageUrl.isAcceptableOrUnknown(
          data['cover_image_url']!,
          _coverImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('is_imported')) {
      context.handle(
        _isImportedMeta,
        isImported.isAcceptableOrUnknown(data['is_imported']!, _isImportedMeta),
      );
    }
    if (data.containsKey('members_json')) {
      context.handle(
        _membersJsonMeta,
        membersJson.isAcceptableOrUnknown(
          data['members_json']!,
          _membersJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('pin_order')) {
      context.handle(
        _pinOrderMeta,
        pinOrder.isAcceptableOrUnknown(data['pin_order']!, _pinOrderMeta),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoListTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoListTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      coverEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_emoji'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      shareToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_token'],
      ),
      shareTokenExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}share_token_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      courseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      coverImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_url'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      isImported: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_imported'],
      )!,
      membersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}members_json'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      pinOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pin_order'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
    );
  }

  @override
  $TodoListTableTable createAlias(String alias) {
    return $TodoListTableTable(attachedDatabase, alias);
  }
}

class TodoListTableData extends DataClass
    implements Insertable<TodoListTableData> {
  final String id;
  final String ownerId;
  final String name;
  final String? coverEmoji;
  final DateTime startDate;
  final DateTime endDate;
  final String? shareToken;
  final DateTime? shareTokenExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final String courseType;
  final String? description;
  final String tagsJson;
  final String? coverImageUrl;
  final String visibility;
  final bool isImported;
  final String membersJson;
  final bool isPinned;
  final int pinOrder;
  final int likeCount;
  final String? region;
  const TodoListTableData({
    required this.id,
    required this.ownerId,
    required this.name,
    this.coverEmoji,
    required this.startDate,
    required this.endDate,
    this.shareToken,
    this.shareTokenExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
    required this.courseType,
    this.description,
    required this.tagsJson,
    this.coverImageUrl,
    required this.visibility,
    required this.isImported,
    required this.membersJson,
    required this.isPinned,
    required this.pinOrder,
    required this.likeCount,
    this.region,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverEmoji != null) {
      map['cover_emoji'] = Variable<String>(coverEmoji);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || shareToken != null) {
      map['share_token'] = Variable<String>(shareToken);
    }
    if (!nullToAbsent || shareTokenExpiresAt != null) {
      map['share_token_expires_at'] = Variable<DateTime>(shareTokenExpiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['course_type'] = Variable<String>(courseType);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['visibility'] = Variable<String>(visibility);
    map['is_imported'] = Variable<bool>(isImported);
    map['members_json'] = Variable<String>(membersJson);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['pin_order'] = Variable<int>(pinOrder);
    map['like_count'] = Variable<int>(likeCount);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    return map;
  }

  TodoListTableCompanion toCompanion(bool nullToAbsent) {
    return TodoListTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      coverEmoji: coverEmoji == null && nullToAbsent
          ? const Value.absent()
          : Value(coverEmoji),
      startDate: Value(startDate),
      endDate: Value(endDate),
      shareToken: shareToken == null && nullToAbsent
          ? const Value.absent()
          : Value(shareToken),
      shareTokenExpiresAt: shareTokenExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(shareTokenExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      courseType: Value(courseType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      tagsJson: Value(tagsJson),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      visibility: Value(visibility),
      isImported: Value(isImported),
      membersJson: Value(membersJson),
      isPinned: Value(isPinned),
      pinOrder: Value(pinOrder),
      likeCount: Value(likeCount),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
    );
  }

  factory TodoListTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoListTableData(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      coverEmoji: serializer.fromJson<String?>(json['coverEmoji']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      shareToken: serializer.fromJson<String?>(json['shareToken']),
      shareTokenExpiresAt: serializer.fromJson<DateTime?>(
        json['shareTokenExpiresAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      courseType: serializer.fromJson<String>(json['courseType']),
      description: serializer.fromJson<String?>(json['description']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      visibility: serializer.fromJson<String>(json['visibility']),
      isImported: serializer.fromJson<bool>(json['isImported']),
      membersJson: serializer.fromJson<String>(json['membersJson']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      pinOrder: serializer.fromJson<int>(json['pinOrder']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      region: serializer.fromJson<String?>(json['region']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'coverEmoji': serializer.toJson<String?>(coverEmoji),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'shareToken': serializer.toJson<String?>(shareToken),
      'shareTokenExpiresAt': serializer.toJson<DateTime?>(shareTokenExpiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'courseType': serializer.toJson<String>(courseType),
      'description': serializer.toJson<String?>(description),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'visibility': serializer.toJson<String>(visibility),
      'isImported': serializer.toJson<bool>(isImported),
      'membersJson': serializer.toJson<String>(membersJson),
      'isPinned': serializer.toJson<bool>(isPinned),
      'pinOrder': serializer.toJson<int>(pinOrder),
      'likeCount': serializer.toJson<int>(likeCount),
      'region': serializer.toJson<String?>(region),
    };
  }

  TodoListTableData copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<String?> coverEmoji = const Value.absent(),
    DateTime? startDate,
    DateTime? endDate,
    Value<String?> shareToken = const Value.absent(),
    Value<DateTime?> shareTokenExpiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
    String? courseType,
    Value<String?> description = const Value.absent(),
    String? tagsJson,
    Value<String?> coverImageUrl = const Value.absent(),
    String? visibility,
    bool? isImported,
    String? membersJson,
    bool? isPinned,
    int? pinOrder,
    int? likeCount,
    Value<String?> region = const Value.absent(),
  }) => TodoListTableData(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    coverEmoji: coverEmoji.present ? coverEmoji.value : this.coverEmoji,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    shareToken: shareToken.present ? shareToken.value : this.shareToken,
    shareTokenExpiresAt: shareTokenExpiresAt.present
        ? shareTokenExpiresAt.value
        : this.shareTokenExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    courseType: courseType ?? this.courseType,
    description: description.present ? description.value : this.description,
    tagsJson: tagsJson ?? this.tagsJson,
    coverImageUrl: coverImageUrl.present
        ? coverImageUrl.value
        : this.coverImageUrl,
    visibility: visibility ?? this.visibility,
    isImported: isImported ?? this.isImported,
    membersJson: membersJson ?? this.membersJson,
    isPinned: isPinned ?? this.isPinned,
    pinOrder: pinOrder ?? this.pinOrder,
    likeCount: likeCount ?? this.likeCount,
    region: region.present ? region.value : this.region,
  );
  TodoListTableData copyWithCompanion(TodoListTableCompanion data) {
    return TodoListTableData(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      coverEmoji: data.coverEmoji.present
          ? data.coverEmoji.value
          : this.coverEmoji,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      shareToken: data.shareToken.present
          ? data.shareToken.value
          : this.shareToken,
      shareTokenExpiresAt: data.shareTokenExpiresAt.present
          ? data.shareTokenExpiresAt.value
          : this.shareTokenExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      courseType: data.courseType.present
          ? data.courseType.value
          : this.courseType,
      description: data.description.present
          ? data.description.value
          : this.description,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      isImported: data.isImported.present
          ? data.isImported.value
          : this.isImported,
      membersJson: data.membersJson.present
          ? data.membersJson.value
          : this.membersJson,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      pinOrder: data.pinOrder.present ? data.pinOrder.value : this.pinOrder,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      region: data.region.present ? data.region.value : this.region,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoListTableData(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shareToken: $shareToken, ')
          ..write('shareTokenExpiresAt: $shareTokenExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('courseType: $courseType, ')
          ..write('description: $description, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('visibility: $visibility, ')
          ..write('isImported: $isImported, ')
          ..write('membersJson: $membersJson, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder, ')
          ..write('likeCount: $likeCount, ')
          ..write('region: $region')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerId,
    name,
    coverEmoji,
    startDate,
    endDate,
    shareToken,
    shareTokenExpiresAt,
    createdAt,
    updatedAt,
    synced,
    courseType,
    description,
    tagsJson,
    coverImageUrl,
    visibility,
    isImported,
    membersJson,
    isPinned,
    pinOrder,
    likeCount,
    region,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoListTableData &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.coverEmoji == this.coverEmoji &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.shareToken == this.shareToken &&
          other.shareTokenExpiresAt == this.shareTokenExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.courseType == this.courseType &&
          other.description == this.description &&
          other.tagsJson == this.tagsJson &&
          other.coverImageUrl == this.coverImageUrl &&
          other.visibility == this.visibility &&
          other.isImported == this.isImported &&
          other.membersJson == this.membersJson &&
          other.isPinned == this.isPinned &&
          other.pinOrder == this.pinOrder &&
          other.likeCount == this.likeCount &&
          other.region == this.region);
}

class TodoListTableCompanion extends UpdateCompanion<TodoListTableData> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String?> coverEmoji;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String?> shareToken;
  final Value<DateTime?> shareTokenExpiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<String> courseType;
  final Value<String?> description;
  final Value<String> tagsJson;
  final Value<String?> coverImageUrl;
  final Value<String> visibility;
  final Value<bool> isImported;
  final Value<String> membersJson;
  final Value<bool> isPinned;
  final Value<int> pinOrder;
  final Value<int> likeCount;
  final Value<String?> region;
  final Value<int> rowid;
  const TodoListTableCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.coverEmoji = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.shareToken = const Value.absent(),
    this.shareTokenExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.courseType = const Value.absent(),
    this.description = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isImported = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.region = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoListTableCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.coverEmoji = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    this.shareToken = const Value.absent(),
    this.shareTokenExpiresAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.courseType = const Value.absent(),
    this.description = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.visibility = const Value.absent(),
    this.isImported = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.region = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       startDate = Value(startDate),
       endDate = Value(endDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TodoListTableData> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? coverEmoji,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? shareToken,
    Expression<DateTime>? shareTokenExpiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<String>? courseType,
    Expression<String>? description,
    Expression<String>? tagsJson,
    Expression<String>? coverImageUrl,
    Expression<String>? visibility,
    Expression<bool>? isImported,
    Expression<String>? membersJson,
    Expression<bool>? isPinned,
    Expression<int>? pinOrder,
    Expression<int>? likeCount,
    Expression<String>? region,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (coverEmoji != null) 'cover_emoji': coverEmoji,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (shareToken != null) 'share_token': shareToken,
      if (shareTokenExpiresAt != null)
        'share_token_expires_at': shareTokenExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (courseType != null) 'course_type': courseType,
      if (description != null) 'description': description,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (visibility != null) 'visibility': visibility,
      if (isImported != null) 'is_imported': isImported,
      if (membersJson != null) 'members_json': membersJson,
      if (isPinned != null) 'is_pinned': isPinned,
      if (pinOrder != null) 'pin_order': pinOrder,
      if (likeCount != null) 'like_count': likeCount,
      if (region != null) 'region': region,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoListTableCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String?>? coverEmoji,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String?>? shareToken,
    Value<DateTime?>? shareTokenExpiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<String>? courseType,
    Value<String?>? description,
    Value<String>? tagsJson,
    Value<String?>? coverImageUrl,
    Value<String>? visibility,
    Value<bool>? isImported,
    Value<String>? membersJson,
    Value<bool>? isPinned,
    Value<int>? pinOrder,
    Value<int>? likeCount,
    Value<String?>? region,
    Value<int>? rowid,
  }) {
    return TodoListTableCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shareToken: shareToken ?? this.shareToken,
      shareTokenExpiresAt: shareTokenExpiresAt ?? this.shareTokenExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      courseType: courseType ?? this.courseType,
      description: description ?? this.description,
      tagsJson: tagsJson ?? this.tagsJson,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      visibility: visibility ?? this.visibility,
      isImported: isImported ?? this.isImported,
      membersJson: membersJson ?? this.membersJson,
      isPinned: isPinned ?? this.isPinned,
      pinOrder: pinOrder ?? this.pinOrder,
      likeCount: likeCount ?? this.likeCount,
      region: region ?? this.region,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverEmoji.present) {
      map['cover_emoji'] = Variable<String>(coverEmoji.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (shareToken.present) {
      map['share_token'] = Variable<String>(shareToken.value);
    }
    if (shareTokenExpiresAt.present) {
      map['share_token_expires_at'] = Variable<DateTime>(
        shareTokenExpiresAt.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (courseType.present) {
      map['course_type'] = Variable<String>(courseType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (isImported.present) {
      map['is_imported'] = Variable<bool>(isImported.value);
    }
    if (membersJson.present) {
      map['members_json'] = Variable<String>(membersJson.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (pinOrder.present) {
      map['pin_order'] = Variable<int>(pinOrder.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoListTableCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('coverEmoji: $coverEmoji, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shareToken: $shareToken, ')
          ..write('shareTokenExpiresAt: $shareTokenExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('courseType: $courseType, ')
          ..write('description: $description, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('visibility: $visibility, ')
          ..write('isImported: $isImported, ')
          ..write('membersJson: $membersJson, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder, ')
          ..write('likeCount: $likeCount, ')
          ..write('region: $region, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoItemTableTable extends TodoItemTable
    with TableInfo<$TodoItemTableTable, TodoItemTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoListIdMeta = const VerificationMeta(
    'todoListId',
  );
  @override
  late final GeneratedColumn<String> todoListId = GeneratedColumn<String>(
    'todo_list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES todo_list_table (id)',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeCategoryMeta = const VerificationMeta(
    'placeCategory',
  );
  @override
  late final GeneratedColumn<String> placeCategory = GeneratedColumn<String>(
    'place_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta(
    'placeId',
  );
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _orderInDayMeta = const VerificationMeta(
    'orderInDay',
  );
  @override
  late final GeneratedColumn<int> orderInDay = GeneratedColumn<int>(
    'order_in_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInDotIdMeta = const VerificationMeta(
    'checkInDotId',
  );
  @override
  late final GeneratedColumn<String> checkInDotId = GeneratedColumn<String>(
    'check_in_dot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedInAtMeta = const VerificationMeta(
    'checkedInAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedInAt = GeneratedColumn<DateTime>(
    'checked_in_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checkInDirtyMeta = const VerificationMeta(
    'checkInDirty',
  );
  @override
  late final GeneratedColumn<bool> checkInDirty = GeneratedColumn<bool>(
    'check_in_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("check_in_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinOrderMeta = const VerificationMeta(
    'pinOrder',
  );
  @override
  late final GeneratedColumn<int> pinOrder = GeneratedColumn<int>(
    'pin_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    todoListId,
    latitude,
    longitude,
    placeName,
    placeCategory,
    placeId,
    plannedAt,
    dayIndex,
    orderInDay,
    notes,
    emotion,
    checkInDotId,
    checkedInAt,
    photoUrl,
    synced,
    checkInDirty,
    isPinned,
    pinOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_item_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoItemTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('todo_list_id')) {
      context.handle(
        _todoListIdMeta,
        todoListId.isAcceptableOrUnknown(
          data['todo_list_id']!,
          _todoListIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_todoListIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    }
    if (data.containsKey('place_category')) {
      context.handle(
        _placeCategoryMeta,
        placeCategory.isAcceptableOrUnknown(
          data['place_category']!,
          _placeCategoryMeta,
        ),
      );
    }
    if (data.containsKey('place_id')) {
      context.handle(
        _placeIdMeta,
        placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta),
      );
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
      );
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    }
    if (data.containsKey('order_in_day')) {
      context.handle(
        _orderInDayMeta,
        orderInDay.isAcceptableOrUnknown(
          data['order_in_day']!,
          _orderInDayMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    }
    if (data.containsKey('check_in_dot_id')) {
      context.handle(
        _checkInDotIdMeta,
        checkInDotId.isAcceptableOrUnknown(
          data['check_in_dot_id']!,
          _checkInDotIdMeta,
        ),
      );
    }
    if (data.containsKey('checked_in_at')) {
      context.handle(
        _checkedInAtMeta,
        checkedInAt.isAcceptableOrUnknown(
          data['checked_in_at']!,
          _checkedInAtMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('check_in_dirty')) {
      context.handle(
        _checkInDirtyMeta,
        checkInDirty.isAcceptableOrUnknown(
          data['check_in_dirty']!,
          _checkInDirtyMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('pin_order')) {
      context.handle(
        _pinOrderMeta,
        pinOrder.isAcceptableOrUnknown(data['pin_order']!, _pinOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoItemTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItemTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      todoListId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo_list_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      ),
      placeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_category'],
      ),
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      ),
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      ),
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      orderInDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_day'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      ),
      checkInDotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_dot_id'],
      ),
      checkedInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_in_at'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      checkInDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}check_in_dirty'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      pinOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pin_order'],
      )!,
    );
  }

  @override
  $TodoItemTableTable createAlias(String alias) {
    return $TodoItemTableTable(attachedDatabase, alias);
  }
}

class TodoItemTableData extends DataClass
    implements Insertable<TodoItemTableData> {
  final String id;
  final String todoListId;
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? placeCategory;
  final String? placeId;
  final DateTime? plannedAt;
  final int dayIndex;
  final int orderInDay;
  final String? notes;
  final String? emotion;
  final String? checkInDotId;
  final DateTime? checkedInAt;
  final String? photoUrl;
  final bool synced;
  final bool checkInDirty;
  final bool isPinned;
  final int pinOrder;
  const TodoItemTableData({
    required this.id,
    required this.todoListId,
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.placeCategory,
    this.placeId,
    this.plannedAt,
    required this.dayIndex,
    required this.orderInDay,
    this.notes,
    this.emotion,
    this.checkInDotId,
    this.checkedInAt,
    this.photoUrl,
    required this.synced,
    required this.checkInDirty,
    required this.isPinned,
    required this.pinOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['todo_list_id'] = Variable<String>(todoListId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    if (!nullToAbsent || placeCategory != null) {
      map['place_category'] = Variable<String>(placeCategory);
    }
    if (!nullToAbsent || placeId != null) {
      map['place_id'] = Variable<String>(placeId);
    }
    if (!nullToAbsent || plannedAt != null) {
      map['planned_at'] = Variable<DateTime>(plannedAt);
    }
    map['day_index'] = Variable<int>(dayIndex);
    map['order_in_day'] = Variable<int>(orderInDay);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    if (!nullToAbsent || checkInDotId != null) {
      map['check_in_dot_id'] = Variable<String>(checkInDotId);
    }
    if (!nullToAbsent || checkedInAt != null) {
      map['checked_in_at'] = Variable<DateTime>(checkedInAt);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['synced'] = Variable<bool>(synced);
    map['check_in_dirty'] = Variable<bool>(checkInDirty);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['pin_order'] = Variable<int>(pinOrder);
    return map;
  }

  TodoItemTableCompanion toCompanion(bool nullToAbsent) {
    return TodoItemTableCompanion(
      id: Value(id),
      todoListId: Value(todoListId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      placeCategory: placeCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(placeCategory),
      placeId: placeId == null && nullToAbsent
          ? const Value.absent()
          : Value(placeId),
      plannedAt: plannedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedAt),
      dayIndex: Value(dayIndex),
      orderInDay: Value(orderInDay),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      emotion: emotion == null && nullToAbsent
          ? const Value.absent()
          : Value(emotion),
      checkInDotId: checkInDotId == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInDotId),
      checkedInAt: checkedInAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedInAt),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      synced: Value(synced),
      checkInDirty: Value(checkInDirty),
      isPinned: Value(isPinned),
      pinOrder: Value(pinOrder),
    );
  }

  factory TodoItemTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItemTableData(
      id: serializer.fromJson<String>(json['id']),
      todoListId: serializer.fromJson<String>(json['todoListId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      placeCategory: serializer.fromJson<String?>(json['placeCategory']),
      placeId: serializer.fromJson<String?>(json['placeId']),
      plannedAt: serializer.fromJson<DateTime?>(json['plannedAt']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      orderInDay: serializer.fromJson<int>(json['orderInDay']),
      notes: serializer.fromJson<String?>(json['notes']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      checkInDotId: serializer.fromJson<String?>(json['checkInDotId']),
      checkedInAt: serializer.fromJson<DateTime?>(json['checkedInAt']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      synced: serializer.fromJson<bool>(json['synced']),
      checkInDirty: serializer.fromJson<bool>(json['checkInDirty']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      pinOrder: serializer.fromJson<int>(json['pinOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'todoListId': serializer.toJson<String>(todoListId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'placeName': serializer.toJson<String?>(placeName),
      'placeCategory': serializer.toJson<String?>(placeCategory),
      'placeId': serializer.toJson<String?>(placeId),
      'plannedAt': serializer.toJson<DateTime?>(plannedAt),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'orderInDay': serializer.toJson<int>(orderInDay),
      'notes': serializer.toJson<String?>(notes),
      'emotion': serializer.toJson<String?>(emotion),
      'checkInDotId': serializer.toJson<String?>(checkInDotId),
      'checkedInAt': serializer.toJson<DateTime?>(checkedInAt),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'synced': serializer.toJson<bool>(synced),
      'checkInDirty': serializer.toJson<bool>(checkInDirty),
      'isPinned': serializer.toJson<bool>(isPinned),
      'pinOrder': serializer.toJson<int>(pinOrder),
    };
  }

  TodoItemTableData copyWith({
    String? id,
    String? todoListId,
    double? latitude,
    double? longitude,
    Value<String?> placeName = const Value.absent(),
    Value<String?> placeCategory = const Value.absent(),
    Value<String?> placeId = const Value.absent(),
    Value<DateTime?> plannedAt = const Value.absent(),
    int? dayIndex,
    int? orderInDay,
    Value<String?> notes = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    Value<String?> checkInDotId = const Value.absent(),
    Value<DateTime?> checkedInAt = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    bool? synced,
    bool? checkInDirty,
    bool? isPinned,
    int? pinOrder,
  }) => TodoItemTableData(
    id: id ?? this.id,
    todoListId: todoListId ?? this.todoListId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    placeName: placeName.present ? placeName.value : this.placeName,
    placeCategory: placeCategory.present
        ? placeCategory.value
        : this.placeCategory,
    placeId: placeId.present ? placeId.value : this.placeId,
    plannedAt: plannedAt.present ? plannedAt.value : this.plannedAt,
    dayIndex: dayIndex ?? this.dayIndex,
    orderInDay: orderInDay ?? this.orderInDay,
    notes: notes.present ? notes.value : this.notes,
    emotion: emotion.present ? emotion.value : this.emotion,
    checkInDotId: checkInDotId.present ? checkInDotId.value : this.checkInDotId,
    checkedInAt: checkedInAt.present ? checkedInAt.value : this.checkedInAt,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    synced: synced ?? this.synced,
    checkInDirty: checkInDirty ?? this.checkInDirty,
    isPinned: isPinned ?? this.isPinned,
    pinOrder: pinOrder ?? this.pinOrder,
  );
  TodoItemTableData copyWithCompanion(TodoItemTableCompanion data) {
    return TodoItemTableData(
      id: data.id.present ? data.id.value : this.id,
      todoListId: data.todoListId.present
          ? data.todoListId.value
          : this.todoListId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      placeCategory: data.placeCategory.present
          ? data.placeCategory.value
          : this.placeCategory,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      orderInDay: data.orderInDay.present
          ? data.orderInDay.value
          : this.orderInDay,
      notes: data.notes.present ? data.notes.value : this.notes,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      checkInDotId: data.checkInDotId.present
          ? data.checkInDotId.value
          : this.checkInDotId,
      checkedInAt: data.checkedInAt.present
          ? data.checkedInAt.value
          : this.checkedInAt,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      synced: data.synced.present ? data.synced.value : this.synced,
      checkInDirty: data.checkInDirty.present
          ? data.checkInDirty.value
          : this.checkInDirty,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      pinOrder: data.pinOrder.present ? data.pinOrder.value : this.pinOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemTableData(')
          ..write('id: $id, ')
          ..write('todoListId: $todoListId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('placeId: $placeId, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('orderInDay: $orderInDay, ')
          ..write('notes: $notes, ')
          ..write('emotion: $emotion, ')
          ..write('checkInDotId: $checkInDotId, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('synced: $synced, ')
          ..write('checkInDirty: $checkInDirty, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    todoListId,
    latitude,
    longitude,
    placeName,
    placeCategory,
    placeId,
    plannedAt,
    dayIndex,
    orderInDay,
    notes,
    emotion,
    checkInDotId,
    checkedInAt,
    photoUrl,
    synced,
    checkInDirty,
    isPinned,
    pinOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItemTableData &&
          other.id == this.id &&
          other.todoListId == this.todoListId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.placeName == this.placeName &&
          other.placeCategory == this.placeCategory &&
          other.placeId == this.placeId &&
          other.plannedAt == this.plannedAt &&
          other.dayIndex == this.dayIndex &&
          other.orderInDay == this.orderInDay &&
          other.notes == this.notes &&
          other.emotion == this.emotion &&
          other.checkInDotId == this.checkInDotId &&
          other.checkedInAt == this.checkedInAt &&
          other.photoUrl == this.photoUrl &&
          other.synced == this.synced &&
          other.checkInDirty == this.checkInDirty &&
          other.isPinned == this.isPinned &&
          other.pinOrder == this.pinOrder);
}

class TodoItemTableCompanion extends UpdateCompanion<TodoItemTableData> {
  final Value<String> id;
  final Value<String> todoListId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> placeName;
  final Value<String?> placeCategory;
  final Value<String?> placeId;
  final Value<DateTime?> plannedAt;
  final Value<int> dayIndex;
  final Value<int> orderInDay;
  final Value<String?> notes;
  final Value<String?> emotion;
  final Value<String?> checkInDotId;
  final Value<DateTime?> checkedInAt;
  final Value<String?> photoUrl;
  final Value<bool> synced;
  final Value<bool> checkInDirty;
  final Value<bool> isPinned;
  final Value<int> pinOrder;
  final Value<int> rowid;
  const TodoItemTableCompanion({
    this.id = const Value.absent(),
    this.todoListId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.placeName = const Value.absent(),
    this.placeCategory = const Value.absent(),
    this.placeId = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.orderInDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.emotion = const Value.absent(),
    this.checkInDotId = const Value.absent(),
    this.checkedInAt = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.synced = const Value.absent(),
    this.checkInDirty = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoItemTableCompanion.insert({
    required String id,
    required String todoListId,
    required double latitude,
    required double longitude,
    this.placeName = const Value.absent(),
    this.placeCategory = const Value.absent(),
    this.placeId = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.orderInDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.emotion = const Value.absent(),
    this.checkInDotId = const Value.absent(),
    this.checkedInAt = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.synced = const Value.absent(),
    this.checkInDirty = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.pinOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       todoListId = Value(todoListId),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<TodoItemTableData> custom({
    Expression<String>? id,
    Expression<String>? todoListId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? placeName,
    Expression<String>? placeCategory,
    Expression<String>? placeId,
    Expression<DateTime>? plannedAt,
    Expression<int>? dayIndex,
    Expression<int>? orderInDay,
    Expression<String>? notes,
    Expression<String>? emotion,
    Expression<String>? checkInDotId,
    Expression<DateTime>? checkedInAt,
    Expression<String>? photoUrl,
    Expression<bool>? synced,
    Expression<bool>? checkInDirty,
    Expression<bool>? isPinned,
    Expression<int>? pinOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (todoListId != null) 'todo_list_id': todoListId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeName != null) 'place_name': placeName,
      if (placeCategory != null) 'place_category': placeCategory,
      if (placeId != null) 'place_id': placeId,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (dayIndex != null) 'day_index': dayIndex,
      if (orderInDay != null) 'order_in_day': orderInDay,
      if (notes != null) 'notes': notes,
      if (emotion != null) 'emotion': emotion,
      if (checkInDotId != null) 'check_in_dot_id': checkInDotId,
      if (checkedInAt != null) 'checked_in_at': checkedInAt,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (synced != null) 'synced': synced,
      if (checkInDirty != null) 'check_in_dirty': checkInDirty,
      if (isPinned != null) 'is_pinned': isPinned,
      if (pinOrder != null) 'pin_order': pinOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoItemTableCompanion copyWith({
    Value<String>? id,
    Value<String>? todoListId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? placeName,
    Value<String?>? placeCategory,
    Value<String?>? placeId,
    Value<DateTime?>? plannedAt,
    Value<int>? dayIndex,
    Value<int>? orderInDay,
    Value<String?>? notes,
    Value<String?>? emotion,
    Value<String?>? checkInDotId,
    Value<DateTime?>? checkedInAt,
    Value<String?>? photoUrl,
    Value<bool>? synced,
    Value<bool>? checkInDirty,
    Value<bool>? isPinned,
    Value<int>? pinOrder,
    Value<int>? rowid,
  }) {
    return TodoItemTableCompanion(
      id: id ?? this.id,
      todoListId: todoListId ?? this.todoListId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      placeCategory: placeCategory ?? this.placeCategory,
      placeId: placeId ?? this.placeId,
      plannedAt: plannedAt ?? this.plannedAt,
      dayIndex: dayIndex ?? this.dayIndex,
      orderInDay: orderInDay ?? this.orderInDay,
      notes: notes ?? this.notes,
      emotion: emotion ?? this.emotion,
      checkInDotId: checkInDotId ?? this.checkInDotId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      photoUrl: photoUrl ?? this.photoUrl,
      synced: synced ?? this.synced,
      checkInDirty: checkInDirty ?? this.checkInDirty,
      isPinned: isPinned ?? this.isPinned,
      pinOrder: pinOrder ?? this.pinOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (todoListId.present) {
      map['todo_list_id'] = Variable<String>(todoListId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (placeCategory.present) {
      map['place_category'] = Variable<String>(placeCategory.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (orderInDay.present) {
      map['order_in_day'] = Variable<int>(orderInDay.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (checkInDotId.present) {
      map['check_in_dot_id'] = Variable<String>(checkInDotId.value);
    }
    if (checkedInAt.present) {
      map['checked_in_at'] = Variable<DateTime>(checkedInAt.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (checkInDirty.present) {
      map['check_in_dirty'] = Variable<bool>(checkInDirty.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (pinOrder.present) {
      map['pin_order'] = Variable<int>(pinOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemTableCompanion(')
          ..write('id: $id, ')
          ..write('todoListId: $todoListId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeName: $placeName, ')
          ..write('placeCategory: $placeCategory, ')
          ..write('placeId: $placeId, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('orderInDay: $orderInDay, ')
          ..write('notes: $notes, ')
          ..write('emotion: $emotion, ')
          ..write('checkInDotId: $checkInDotId, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('synced: $synced, ')
          ..write('checkInDirty: $checkInDirty, ')
          ..write('isPinned: $isPinned, ')
          ..write('pinOrder: $pinOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DotTableTable dotTable = $DotTableTable(this);
  late final $DayLogTableTable dayLogTable = $DayLogTableTable(this);
  late final $TodoListTableTable todoListTable = $TodoListTableTable(this);
  late final $TodoItemTableTable todoItemTable = $TodoItemTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dotTable,
    dayLogTable,
    todoListTable,
    todoItemTable,
  ];
}

typedef $$DotTableTableCreateCompanionBuilder =
    DotTableCompanion Function({
      required String id,
      required double latitude,
      required double longitude,
      required DateTime timestamp,
      Value<String?> placeName,
      Value<String?> placeCategory,
      Value<String?> photoLocalPath,
      Value<String?> photoUrl,
      Value<String?> photoThumbUrl,
      Value<String?> photoPreviewUrl,
      Value<String?> memo,
      Value<String?> emotion,
      required String dayLogId,
      Value<String> tagsJson,
      Value<String?> sharedRoomIdsJson,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$DotTableTableUpdateCompanionBuilder =
    DotTableCompanion Function({
      Value<String> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> timestamp,
      Value<String?> placeName,
      Value<String?> placeCategory,
      Value<String?> photoLocalPath,
      Value<String?> photoUrl,
      Value<String?> photoThumbUrl,
      Value<String?> photoPreviewUrl,
      Value<String?> memo,
      Value<String?> emotion,
      Value<String> dayLogId,
      Value<String> tagsJson,
      Value<String?> sharedRoomIdsJson,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$DotTableTableFilterComposer
    extends Composer<_$AppDatabase, $DotTableTable> {
  $$DotTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoThumbUrl => $composableBuilder(
    column: $table.photoThumbUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPreviewUrl => $composableBuilder(
    column: $table.photoPreviewUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayLogId => $composableBuilder(
    column: $table.dayLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedRoomIdsJson => $composableBuilder(
    column: $table.sharedRoomIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DotTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DotTableTable> {
  $$DotTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoThumbUrl => $composableBuilder(
    column: $table.photoThumbUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPreviewUrl => $composableBuilder(
    column: $table.photoPreviewUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayLogId => $composableBuilder(
    column: $table.dayLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedRoomIdsJson => $composableBuilder(
    column: $table.sharedRoomIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DotTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DotTableTable> {
  $$DotTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get photoThumbUrl => $composableBuilder(
    column: $table.photoThumbUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPreviewUrl => $composableBuilder(
    column: $table.photoPreviewUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get dayLogId =>
      $composableBuilder(column: $table.dayLogId, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get sharedRoomIdsJson => $composableBuilder(
    column: $table.sharedRoomIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DotTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DotTableTable,
          DotTableData,
          $$DotTableTableFilterComposer,
          $$DotTableTableOrderingComposer,
          $$DotTableTableAnnotationComposer,
          $$DotTableTableCreateCompanionBuilder,
          $$DotTableTableUpdateCompanionBuilder,
          (
            DotTableData,
            BaseReferences<_$AppDatabase, $DotTableTable, DotTableData>,
          ),
          DotTableData,
          PrefetchHooks Function()
        > {
  $$DotTableTableTableManager(_$AppDatabase db, $DotTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DotTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DotTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DotTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeCategory = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> photoThumbUrl = const Value.absent(),
                Value<String?> photoPreviewUrl = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String> dayLogId = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String?> sharedRoomIdsJson = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DotTableCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                placeName: placeName,
                placeCategory: placeCategory,
                photoLocalPath: photoLocalPath,
                photoUrl: photoUrl,
                photoThumbUrl: photoThumbUrl,
                photoPreviewUrl: photoPreviewUrl,
                memo: memo,
                emotion: emotion,
                dayLogId: dayLogId,
                tagsJson: tagsJson,
                sharedRoomIdsJson: sharedRoomIdsJson,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double latitude,
                required double longitude,
                required DateTime timestamp,
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeCategory = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> photoThumbUrl = const Value.absent(),
                Value<String?> photoPreviewUrl = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                required String dayLogId,
                Value<String> tagsJson = const Value.absent(),
                Value<String?> sharedRoomIdsJson = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DotTableCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp,
                placeName: placeName,
                placeCategory: placeCategory,
                photoLocalPath: photoLocalPath,
                photoUrl: photoUrl,
                photoThumbUrl: photoThumbUrl,
                photoPreviewUrl: photoPreviewUrl,
                memo: memo,
                emotion: emotion,
                dayLogId: dayLogId,
                tagsJson: tagsJson,
                sharedRoomIdsJson: sharedRoomIdsJson,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DotTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DotTableTable,
      DotTableData,
      $$DotTableTableFilterComposer,
      $$DotTableTableOrderingComposer,
      $$DotTableTableAnnotationComposer,
      $$DotTableTableCreateCompanionBuilder,
      $$DotTableTableUpdateCompanionBuilder,
      (
        DotTableData,
        BaseReferences<_$AppDatabase, $DotTableTable, DotTableData>,
      ),
      DotTableData,
      PrefetchHooks Function()
    >;
typedef $$DayLogTableTableCreateCompanionBuilder =
    DayLogTableCompanion Function({
      required String id,
      required String userId,
      required DateTime date,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<bool> isRecording,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$DayLogTableTableUpdateCompanionBuilder =
    DayLogTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> date,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<bool> isRecording,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$DayLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $DayLogTableTable> {
  $$DayLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecording => $composableBuilder(
    column: $table.isRecording,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DayLogTableTable> {
  $$DayLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecording => $composableBuilder(
    column: $table.isRecording,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayLogTableTable> {
  $$DayLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRecording => $composableBuilder(
    column: $table.isRecording,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DayLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayLogTableTable,
          DayLogTableData,
          $$DayLogTableTableFilterComposer,
          $$DayLogTableTableOrderingComposer,
          $$DayLogTableTableAnnotationComposer,
          $$DayLogTableTableCreateCompanionBuilder,
          $$DayLogTableTableUpdateCompanionBuilder,
          (
            DayLogTableData,
            BaseReferences<_$AppDatabase, $DayLogTableTable, DayLogTableData>,
          ),
          DayLogTableData,
          PrefetchHooks Function()
        > {
  $$DayLogTableTableTableManager(_$AppDatabase db, $DayLogTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> isRecording = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogTableCompanion(
                id: id,
                userId: userId,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                isRecording: isRecording,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime date,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> isRecording = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogTableCompanion.insert(
                id: id,
                userId: userId,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                isRecording: isRecording,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayLogTableTable,
      DayLogTableData,
      $$DayLogTableTableFilterComposer,
      $$DayLogTableTableOrderingComposer,
      $$DayLogTableTableAnnotationComposer,
      $$DayLogTableTableCreateCompanionBuilder,
      $$DayLogTableTableUpdateCompanionBuilder,
      (
        DayLogTableData,
        BaseReferences<_$AppDatabase, $DayLogTableTable, DayLogTableData>,
      ),
      DayLogTableData,
      PrefetchHooks Function()
    >;
typedef $$TodoListTableTableCreateCompanionBuilder =
    TodoListTableCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      Value<String?> coverEmoji,
      required DateTime startDate,
      required DateTime endDate,
      Value<String?> shareToken,
      Value<DateTime?> shareTokenExpiresAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> synced,
      Value<String> courseType,
      Value<String?> description,
      Value<String> tagsJson,
      Value<String?> coverImageUrl,
      Value<String> visibility,
      Value<bool> isImported,
      Value<String> membersJson,
      Value<bool> isPinned,
      Value<int> pinOrder,
      Value<int> likeCount,
      Value<String?> region,
      Value<int> rowid,
    });
typedef $$TodoListTableTableUpdateCompanionBuilder =
    TodoListTableCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String?> coverEmoji,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String?> shareToken,
      Value<DateTime?> shareTokenExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<String> courseType,
      Value<String?> description,
      Value<String> tagsJson,
      Value<String?> coverImageUrl,
      Value<String> visibility,
      Value<bool> isImported,
      Value<String> membersJson,
      Value<bool> isPinned,
      Value<int> pinOrder,
      Value<int> likeCount,
      Value<String?> region,
      Value<int> rowid,
    });

final class $$TodoListTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $TodoListTableTable, TodoListTableData> {
  $$TodoListTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TodoItemTableTable, List<TodoItemTableData>>
  _todoItemTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.todoItemTable,
    aliasName: $_aliasNameGenerator(
      db.todoListTable.id,
      db.todoItemTable.todoListId,
    ),
  );

  $$TodoItemTableTableProcessedTableManager get todoItemTableRefs {
    final manager = $$TodoItemTableTableTableManager(
      $_db,
      $_db.todoItemTable,
    ).filter((f) => f.todoListId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_todoItemTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TodoListTableTableFilterComposer
    extends Composer<_$AppDatabase, $TodoListTableTable> {
  $$TodoListTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareToken => $composableBuilder(
    column: $table.shareToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shareTokenExpiresAt => $composableBuilder(
    column: $table.shareTokenExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseType => $composableBuilder(
    column: $table.courseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isImported => $composableBuilder(
    column: $table.isImported,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> todoItemTableRefs(
    Expression<bool> Function($$TodoItemTableTableFilterComposer f) f,
  ) {
    final $$TodoItemTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoItemTable,
      getReferencedColumn: (t) => t.todoListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoItemTableTableFilterComposer(
            $db: $db,
            $table: $db.todoItemTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodoListTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoListTableTable> {
  $$TodoListTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareToken => $composableBuilder(
    column: $table.shareToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shareTokenExpiresAt => $composableBuilder(
    column: $table.shareTokenExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseType => $composableBuilder(
    column: $table.courseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isImported => $composableBuilder(
    column: $table.isImported,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoListTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoListTableTable> {
  $$TodoListTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverEmoji => $composableBuilder(
    column: $table.coverEmoji,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get shareToken => $composableBuilder(
    column: $table.shareToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shareTokenExpiresAt => $composableBuilder(
    column: $table.shareTokenExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get courseType => $composableBuilder(
    column: $table.courseType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
    column: $table.coverImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isImported => $composableBuilder(
    column: $table.isImported,
    builder: (column) => column,
  );

  GeneratedColumn<String> get membersJson => $composableBuilder(
    column: $table.membersJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get pinOrder =>
      $composableBuilder(column: $table.pinOrder, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  Expression<T> todoItemTableRefs<T extends Object>(
    Expression<T> Function($$TodoItemTableTableAnnotationComposer a) f,
  ) {
    final $$TodoItemTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.todoItemTable,
      getReferencedColumn: (t) => t.todoListId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoItemTableTableAnnotationComposer(
            $db: $db,
            $table: $db.todoItemTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TodoListTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoListTableTable,
          TodoListTableData,
          $$TodoListTableTableFilterComposer,
          $$TodoListTableTableOrderingComposer,
          $$TodoListTableTableAnnotationComposer,
          $$TodoListTableTableCreateCompanionBuilder,
          $$TodoListTableTableUpdateCompanionBuilder,
          (TodoListTableData, $$TodoListTableTableReferences),
          TodoListTableData,
          PrefetchHooks Function({bool todoItemTableRefs})
        > {
  $$TodoListTableTableTableManager(_$AppDatabase db, $TodoListTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoListTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoListTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoListTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverEmoji = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String?> shareToken = const Value.absent(),
                Value<DateTime?> shareTokenExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> courseType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> isImported = const Value.absent(),
                Value<String> membersJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> pinOrder = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoListTableCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                coverEmoji: coverEmoji,
                startDate: startDate,
                endDate: endDate,
                shareToken: shareToken,
                shareTokenExpiresAt: shareTokenExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                courseType: courseType,
                description: description,
                tagsJson: tagsJson,
                coverImageUrl: coverImageUrl,
                visibility: visibility,
                isImported: isImported,
                membersJson: membersJson,
                isPinned: isPinned,
                pinOrder: pinOrder,
                likeCount: likeCount,
                region: region,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<String?> coverEmoji = const Value.absent(),
                required DateTime startDate,
                required DateTime endDate,
                Value<String?> shareToken = const Value.absent(),
                Value<DateTime?> shareTokenExpiresAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> synced = const Value.absent(),
                Value<String> courseType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String?> coverImageUrl = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> isImported = const Value.absent(),
                Value<String> membersJson = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> pinOrder = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoListTableCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                coverEmoji: coverEmoji,
                startDate: startDate,
                endDate: endDate,
                shareToken: shareToken,
                shareTokenExpiresAt: shareTokenExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                synced: synced,
                courseType: courseType,
                description: description,
                tagsJson: tagsJson,
                coverImageUrl: coverImageUrl,
                visibility: visibility,
                isImported: isImported,
                membersJson: membersJson,
                isPinned: isPinned,
                pinOrder: pinOrder,
                likeCount: likeCount,
                region: region,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TodoListTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todoItemTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (todoItemTableRefs) db.todoItemTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (todoItemTableRefs)
                    await $_getPrefetchedData<
                      TodoListTableData,
                      $TodoListTableTable,
                      TodoItemTableData
                    >(
                      currentTable: table,
                      referencedTable: $$TodoListTableTableReferences
                          ._todoItemTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TodoListTableTableReferences(
                            db,
                            table,
                            p0,
                          ).todoItemTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.todoListId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TodoListTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoListTableTable,
      TodoListTableData,
      $$TodoListTableTableFilterComposer,
      $$TodoListTableTableOrderingComposer,
      $$TodoListTableTableAnnotationComposer,
      $$TodoListTableTableCreateCompanionBuilder,
      $$TodoListTableTableUpdateCompanionBuilder,
      (TodoListTableData, $$TodoListTableTableReferences),
      TodoListTableData,
      PrefetchHooks Function({bool todoItemTableRefs})
    >;
typedef $$TodoItemTableTableCreateCompanionBuilder =
    TodoItemTableCompanion Function({
      required String id,
      required String todoListId,
      required double latitude,
      required double longitude,
      Value<String?> placeName,
      Value<String?> placeCategory,
      Value<String?> placeId,
      Value<DateTime?> plannedAt,
      Value<int> dayIndex,
      Value<int> orderInDay,
      Value<String?> notes,
      Value<String?> emotion,
      Value<String?> checkInDotId,
      Value<DateTime?> checkedInAt,
      Value<String?> photoUrl,
      Value<bool> synced,
      Value<bool> checkInDirty,
      Value<bool> isPinned,
      Value<int> pinOrder,
      Value<int> rowid,
    });
typedef $$TodoItemTableTableUpdateCompanionBuilder =
    TodoItemTableCompanion Function({
      Value<String> id,
      Value<String> todoListId,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> placeName,
      Value<String?> placeCategory,
      Value<String?> placeId,
      Value<DateTime?> plannedAt,
      Value<int> dayIndex,
      Value<int> orderInDay,
      Value<String?> notes,
      Value<String?> emotion,
      Value<String?> checkInDotId,
      Value<DateTime?> checkedInAt,
      Value<String?> photoUrl,
      Value<bool> synced,
      Value<bool> checkInDirty,
      Value<bool> isPinned,
      Value<int> pinOrder,
      Value<int> rowid,
    });

final class $$TodoItemTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $TodoItemTableTable, TodoItemTableData> {
  $$TodoItemTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TodoListTableTable _todoListIdTable(_$AppDatabase db) =>
      db.todoListTable.createAlias(
        $_aliasNameGenerator(db.todoItemTable.todoListId, db.todoListTable.id),
      );

  $$TodoListTableTableProcessedTableManager get todoListId {
    final $_column = $_itemColumn<String>('todo_list_id')!;

    final manager = $$TodoListTableTableTableManager(
      $_db,
      $_db.todoListTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_todoListIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TodoItemTableTableFilterComposer
    extends Composer<_$AppDatabase, $TodoItemTableTable> {
  $$TodoItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeId => $composableBuilder(
    column: $table.placeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInDay => $composableBuilder(
    column: $table.orderInDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkInDotId => $composableBuilder(
    column: $table.checkInDotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checkInDirty => $composableBuilder(
    column: $table.checkInDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$TodoListTableTableFilterComposer get todoListId {
    final $$TodoListTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoListId,
      referencedTable: $db.todoListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoListTableTableFilterComposer(
            $db: $db,
            $table: $db.todoListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoItemTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoItemTableTable> {
  $$TodoItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeId => $composableBuilder(
    column: $table.placeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInDay => $composableBuilder(
    column: $table.orderInDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkInDotId => $composableBuilder(
    column: $table.checkInDotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checkInDirty => $composableBuilder(
    column: $table.checkInDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pinOrder => $composableBuilder(
    column: $table.pinOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$TodoListTableTableOrderingComposer get todoListId {
    final $$TodoListTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoListId,
      referencedTable: $db.todoListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoListTableTableOrderingComposer(
            $db: $db,
            $table: $db.todoListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoItemTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoItemTableTable> {
  $$TodoItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<String> get placeCategory => $composableBuilder(
    column: $table.placeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<int> get orderInDay => $composableBuilder(
    column: $table.orderInDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get checkInDotId => $composableBuilder(
    column: $table.checkInDotId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get checkInDirty => $composableBuilder(
    column: $table.checkInDirty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get pinOrder =>
      $composableBuilder(column: $table.pinOrder, builder: (column) => column);

  $$TodoListTableTableAnnotationComposer get todoListId {
    final $$TodoListTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.todoListId,
      referencedTable: $db.todoListTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TodoListTableTableAnnotationComposer(
            $db: $db,
            $table: $db.todoListTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TodoItemTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoItemTableTable,
          TodoItemTableData,
          $$TodoItemTableTableFilterComposer,
          $$TodoItemTableTableOrderingComposer,
          $$TodoItemTableTableAnnotationComposer,
          $$TodoItemTableTableCreateCompanionBuilder,
          $$TodoItemTableTableUpdateCompanionBuilder,
          (TodoItemTableData, $$TodoItemTableTableReferences),
          TodoItemTableData,
          PrefetchHooks Function({bool todoListId})
        > {
  $$TodoItemTableTableTableManager(_$AppDatabase db, $TodoItemTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoItemTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoItemTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoItemTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> todoListId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeCategory = const Value.absent(),
                Value<String?> placeId = const Value.absent(),
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<int> orderInDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String?> checkInDotId = const Value.absent(),
                Value<DateTime?> checkedInAt = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> checkInDirty = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> pinOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoItemTableCompanion(
                id: id,
                todoListId: todoListId,
                latitude: latitude,
                longitude: longitude,
                placeName: placeName,
                placeCategory: placeCategory,
                placeId: placeId,
                plannedAt: plannedAt,
                dayIndex: dayIndex,
                orderInDay: orderInDay,
                notes: notes,
                emotion: emotion,
                checkInDotId: checkInDotId,
                checkedInAt: checkedInAt,
                photoUrl: photoUrl,
                synced: synced,
                checkInDirty: checkInDirty,
                isPinned: isPinned,
                pinOrder: pinOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String todoListId,
                required double latitude,
                required double longitude,
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeCategory = const Value.absent(),
                Value<String?> placeId = const Value.absent(),
                Value<DateTime?> plannedAt = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<int> orderInDay = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String?> checkInDotId = const Value.absent(),
                Value<DateTime?> checkedInAt = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> checkInDirty = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> pinOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoItemTableCompanion.insert(
                id: id,
                todoListId: todoListId,
                latitude: latitude,
                longitude: longitude,
                placeName: placeName,
                placeCategory: placeCategory,
                placeId: placeId,
                plannedAt: plannedAt,
                dayIndex: dayIndex,
                orderInDay: orderInDay,
                notes: notes,
                emotion: emotion,
                checkInDotId: checkInDotId,
                checkedInAt: checkedInAt,
                photoUrl: photoUrl,
                synced: synced,
                checkInDirty: checkInDirty,
                isPinned: isPinned,
                pinOrder: pinOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TodoItemTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({todoListId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (todoListId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.todoListId,
                                referencedTable: $$TodoItemTableTableReferences
                                    ._todoListIdTable(db),
                                referencedColumn: $$TodoItemTableTableReferences
                                    ._todoListIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TodoItemTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoItemTableTable,
      TodoItemTableData,
      $$TodoItemTableTableFilterComposer,
      $$TodoItemTableTableOrderingComposer,
      $$TodoItemTableTableAnnotationComposer,
      $$TodoItemTableTableCreateCompanionBuilder,
      $$TodoItemTableTableUpdateCompanionBuilder,
      (TodoItemTableData, $$TodoItemTableTableReferences),
      TodoItemTableData,
      PrefetchHooks Function({bool todoListId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DotTableTableTableManager get dotTable =>
      $$DotTableTableTableManager(_db, _db.dotTable);
  $$DayLogTableTableTableManager get dayLogTable =>
      $$DayLogTableTableTableManager(_db, _db.dayLogTable);
  $$TodoListTableTableTableManager get todoListTable =>
      $$TodoListTableTableTableManager(_db, _db.todoListTable);
  $$TodoItemTableTableTableManager get todoItemTable =>
      $$TodoItemTableTableTableManager(_db, _db.todoItemTable);
}

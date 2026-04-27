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
    memo,
    emotion,
    dayLogId,
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
  final String? memo;
  final String? emotion;
  final String dayLogId;
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
    this.memo,
    this.emotion,
    required this.dayLogId,
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
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || emotion != null) {
      map['emotion'] = Variable<String>(emotion);
    }
    map['day_log_id'] = Variable<String>(dayLogId);
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
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      emotion: emotion == null && nullToAbsent
          ? const Value.absent()
          : Value(emotion),
      dayLogId: Value(dayLogId),
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
      memo: serializer.fromJson<String?>(json['memo']),
      emotion: serializer.fromJson<String?>(json['emotion']),
      dayLogId: serializer.fromJson<String>(json['dayLogId']),
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
      'memo': serializer.toJson<String?>(memo),
      'emotion': serializer.toJson<String?>(emotion),
      'dayLogId': serializer.toJson<String>(dayLogId),
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
    Value<String?> memo = const Value.absent(),
    Value<String?> emotion = const Value.absent(),
    String? dayLogId,
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
    memo: memo.present ? memo.value : this.memo,
    emotion: emotion.present ? emotion.value : this.emotion,
    dayLogId: dayLogId ?? this.dayLogId,
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
      memo: data.memo.present ? data.memo.value : this.memo,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      dayLogId: data.dayLogId.present ? data.dayLogId.value : this.dayLogId,
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
          ..write('memo: $memo, ')
          ..write('emotion: $emotion, ')
          ..write('dayLogId: $dayLogId, ')
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
    memo,
    emotion,
    dayLogId,
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
          other.memo == this.memo &&
          other.emotion == this.emotion &&
          other.dayLogId == this.dayLogId &&
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
  final Value<String?> memo;
  final Value<String?> emotion;
  final Value<String> dayLogId;
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
    this.memo = const Value.absent(),
    this.emotion = const Value.absent(),
    this.dayLogId = const Value.absent(),
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
    this.memo = const Value.absent(),
    this.emotion = const Value.absent(),
    required String dayLogId,
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
    Expression<String>? memo,
    Expression<String>? emotion,
    Expression<String>? dayLogId,
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
      if (memo != null) 'memo': memo,
      if (emotion != null) 'emotion': emotion,
      if (dayLogId != null) 'day_log_id': dayLogId,
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
    Value<String?>? memo,
    Value<String?>? emotion,
    Value<String>? dayLogId,
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
      memo: memo ?? this.memo,
      emotion: emotion ?? this.emotion,
      dayLogId: dayLogId ?? this.dayLogId,
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
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (dayLogId.present) {
      map['day_log_id'] = Variable<String>(dayLogId.value);
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
          ..write('memo: $memo, ')
          ..write('emotion: $emotion, ')
          ..write('dayLogId: $dayLogId, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DotTableTable dotTable = $DotTableTable(this);
  late final $DayLogTableTable dayLogTable = $DayLogTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dotTable, dayLogTable];
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
      Value<String?> memo,
      Value<String?> emotion,
      required String dayLogId,
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
      Value<String?> memo,
      Value<String?> emotion,
      Value<String> dayLogId,
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

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get dayLogId =>
      $composableBuilder(column: $table.dayLogId, builder: (column) => column);

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
                Value<String?> memo = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                Value<String> dayLogId = const Value.absent(),
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
                memo: memo,
                emotion: emotion,
                dayLogId: dayLogId,
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
                Value<String?> memo = const Value.absent(),
                Value<String?> emotion = const Value.absent(),
                required String dayLogId,
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
                memo: memo,
                emotion: emotion,
                dayLogId: dayLogId,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DotTableTableTableManager get dotTable =>
      $$DotTableTableTableManager(_db, _db.dotTable);
  $$DayLogTableTableTableManager get dayLogTable =>
      $$DayLogTableTableTableManager(_db, _db.dayLogTable);
}

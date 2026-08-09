// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayDayLogHash() => r'cb294e76bc26c6af7054ea5f7a7fb8a63eb632e9';

/// See also [todayDayLog].
@ProviderFor(todayDayLog)
final todayDayLogProvider = AutoDisposeFutureProvider<DayLog?>.internal(
  todayDayLog,
  name: r'todayDayLogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayDayLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayDayLogRef = AutoDisposeFutureProviderRef<DayLog?>;
String _$allDayLogsHash() => r'1773e87a59a3e0366e27e057f506c081847a1d7b';

/// See also [allDayLogs].
@ProviderFor(allDayLogs)
final allDayLogsProvider = AutoDisposeFutureProvider<List<DayLog>>.internal(
  allDayLogs,
  name: r'allDayLogsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allDayLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllDayLogsRef = AutoDisposeFutureProviderRef<List<DayLog>>;
String _$activeRecordingHash() => r'c19e69e8e8840f2518af894830d0666cfc2a4e2f';

/// See also [ActiveRecording].
@ProviderFor(ActiveRecording)
final activeRecordingProvider =
    AutoDisposeAsyncNotifierProvider<
      ActiveRecording,
      RecordingSession?
    >.internal(
      ActiveRecording.new,
      name: r'activeRecordingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeRecordingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveRecording = AutoDisposeAsyncNotifier<RecordingSession?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

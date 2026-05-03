// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayDayLogHash() => r'd9f33524f92a886cca165ac15c560eb62e6375b7';

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
String _$allDayLogsHash() => r'81cca795b52ac24dc2bc1662e8ceb5c72906f5a2';

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
String _$activeRecordingHash() => r'69dd8572780f9a866f3b4f4894f796d50b2a4afe';

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

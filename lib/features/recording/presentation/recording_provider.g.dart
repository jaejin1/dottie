// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allDayLogsHash() => r'8a6b8b1b414872a6e56b22f0b032a1367f5ad7a3';

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
String _$activeRecordingHash() => r'355a49b978146050d9329f9a2dfc56faf1ae47d5';

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../domain/auto_record_settings.dart';
import 'auto_record_provider.dart';

/// 홈 화면 FAB 위에 표시되는 자동기록 토글 칩
class AutoRecordChip extends ConsumerWidget {
  const AutoRecordChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalAsync = ref.watch(autoRecordNotifierProvider);
    final interval = intervalAsync.valueOrNull ?? AutoRecordInterval.manual;
    final isAuto = interval != AutoRecordInterval.manual;

    return GestureDetector(
      onTap: () => _showIntervalSheet(context, ref, interval),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAuto
              ? DottieColors.primary.withAlpha(220)
              : DottieColors.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAuto
                ? DottieColors.primary
                : DottieColors.textHint.withAlpha(80),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAuto ? Icons.location_on_rounded : Icons.location_off_outlined,
              size: 13,
              color: isAuto ? Colors.white : DottieColors.textHint,
            ),
            const SizedBox(width: 4),
            Text(
              isAuto
                  ? '자동 ${AutoRecordInterval.label(interval)}'
                  : '자동 기록 꺼짐',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAuto ? Colors.white : DottieColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalSheet(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DottieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => IntervalPickerSheet(current: current, ref: ref),
    );
  }
}

// ── 인터벌 선택 바텀시트 ───────────────────────────────

class IntervalPickerSheet extends StatefulWidget {
  const IntervalPickerSheet(
      {super.key, required this.current, required this.ref});
  final int current;
  final WidgetRef ref;

  @override
  State<IntervalPickerSheet> createState() => _IntervalPickerSheetState();
}

class _IntervalPickerSheetState extends State<IntervalPickerSheet>
    with WidgetsBindingObserver {
  bool _waitingForSettings = false;
  late int _selectedInterval;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.current;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 설정 앱에서 돌아왔을 때 권한 재확인
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      _recheckPermissionAfterSettings();
    }
  }

  Future<void> _recheckPermissionAfterSettings() async {
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;

    if (permission == LocationPermission.always) {
      // 권한 확보 — 이전에 선택하려 했던 간격이 없으면 그냥 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\'항상 허용\' 권한이 확인됐어요. 다시 간격을 선택해 주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('아직 \'항상\' 권한이 아니에요. 설정 > Dottie > 위치에서 변경해 주세요.'),
          action: SnackBarAction(
            label: '설정 열기',
            onPressed: () {
              _waitingForSettings = true;
              openAppSettings();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '자동 위치 기록',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '앱을 닫아도 설정한 간격마다 백그라운드에서 자동으로 위치를 기록해요.',
            style: TextStyle(fontSize: 12, color: DottieColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AutoRecordInterval.all.map((interval) {
              final selected = interval == _selectedInterval;
              return ChoiceChip(
                label: Text(AutoRecordInterval.label(interval)),
                selected: selected,
                selectedColor: DottieColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : DottieColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                onSelected: (_) => _onSelect(interval),
              );
            }).toList(),
          ),
          if (AutoRecordInterval.hasBatteryWarning(_selectedInterval)) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.battery_alert_rounded,
                      size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '짧은 간격은 배터리 소모가 큽니다. Android는 상태바에 기록 중 알림이 표시돼요.',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            '* 앱을 강제 종료하면 다음에 앱을 열 때 자동 기록이 다시 시작돼요.',
            style: TextStyle(fontSize: 10, color: DottieColors.textHint),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelect(int interval) async {
    // 탭 즉시 선택 표시 (시각 피드백)
    setState(() => _selectedInterval = interval);

    if (interval != AutoRecordInterval.manual) {
      final granted = await _ensureAlwaysPermission();
      if (!granted) {
        // 권한 거부 시 선택 취소
        if (mounted) setState(() => _selectedInterval = widget.current);
        return;
      }
    }
    await widget.ref
        .read(autoRecordNotifierProvider.notifier)
        .setInterval(interval);
    if (mounted) Navigator.pop(context);
  }

  /// iOS: Geolocator 기준으로 확인 (permission_handler 캐싱 이슈 우회)
  Future<bool> _ensureAlwaysPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) return true;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) _showSettingsGuide();
      return false;
    }

    if (permission == LocationPermission.whileInUse) {
      await Permission.locationAlways.request();

      // request() 결과를 신뢰하지 않고 Geolocator로 재확인
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always) return true;

      if (mounted) _showSettingsGuide();
      return false;
    }

    return false;
  }

  void _showSettingsGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('설정 > Dottie > 위치를 \'항상\'으로 변경한 뒤 다시 선택해 주세요.'),
        action: SnackBarAction(
          label: '설정 열기',
          onPressed: () {
            _waitingForSettings = true;
            openAppSettings();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }
}

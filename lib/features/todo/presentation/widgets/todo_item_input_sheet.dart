import 'dart:io' show Platform;


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/dottie_button.dart';
import '../../../cumulative_map/domain/place.dart';
import '../../../cumulative_map/presentation/widgets/place_search_sheet.dart';
import '../../../recording/data/location_service.dart';
import '../../../recording/presentation/widgets/emotion_picker.dart';
import '../../domain/todo_item_model.dart';
import '../../domain/todo_list_model.dart';
import '../todo_provider.dart';

/// 할일 항목 추가/수정 시트.
///
/// 두 가지 진입 경로:
/// 1. 지도 long-press → 좌표 자동 전달 (place 미선택, 사용자가 검색해서 보강)
/// 2. 리스트 "+ 장소 추가" → place 먼저 검색 → 좌표 / 이름 채워짐
///
/// dot_input_sheet 과 차이:
/// - 현재 위치 자동수집 X (계획용)
/// - 사진 X (체크인 시점에 옵션)
/// - 시간/날짜 picker O
/// - 60초 rate limit X (계획 입력은 자유)
class TodoItemInputSheet extends ConsumerStatefulWidget {
  const TodoItemInputSheet({
    super.key,
    required this.todoList,
    this.initialItem,
    this.initialPlace,
    this.initialLatitude,
    this.initialLongitude,
    this.initialDayIndex,
  });

  final TodoList todoList;

  /// 수정 모드 — 비어있으면 생성 모드.
  final TodoItem? initialItem;

  /// 장소 검색에서 시작한 경우 미리 선택된 Place.
  final Place? initialPlace;

  /// 지도 long-press 에서 시작한 경우 좌표만.
  final double? initialLatitude;
  final double? initialLongitude;

  /// 어떤 dayIndex 에 넣을지. 미지정 시 startDate(0).
  final int? initialDayIndex;

  static Future<bool> show(
    BuildContext context, {
    required TodoList todoList,
    TodoItem? initialItem,
    Place? initialPlace,
    double? initialLatitude,
    double? initialLongitude,
    int? initialDayIndex,
  }) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TodoItemInputSheet(
            todoList: todoList,
            initialItem: initialItem,
            initialPlace: initialPlace,
            initialLatitude: initialLatitude,
            initialLongitude: initialLongitude,
            initialDayIndex: initialDayIndex,
          ),
        ) ??
        false;
  }

  @override
  ConsumerState<TodoItemInputSheet> createState() =>
      _TodoItemInputSheetState();
}

class _TodoItemInputSheetState extends ConsumerState<TodoItemInputSheet> {
  final _notesController = TextEditingController();
  String? _selectedEmotion;
  Place? _selectedPlace;
  double? _latitude;
  double? _longitude;
  String? _placeName;
  String? _placeCategory;
  bool _saving = false;
  bool _hasTime = false;

  late DateTime _plannedAt;
  late int _dayIndex;

  /// 거리 표시용 — 시트 진입 시 미리 GPS fetch (fire-and-forget).
  /// PlaceSearchSheet 가 좌표 미전달(전국 검색)이라 BE 가 distance 안 채움 →
  /// 클라이언트가 결과 row 에 거리 계산해 표시. 실패 시 거리 안 보임 (낮은 부담).
  double? _userLatitude;
  double? _userLongitude;

  @override
  void initState() {
    super.initState();
    final init = widget.initialItem;
    if (init != null) {
      _notesController.text = init.notes ?? '';
      _selectedEmotion = init.emotion;
      _latitude = init.latitude;
      _longitude = init.longitude;
      _placeName = init.placeName;
      _placeCategory = init.placeCategory;
      _dayIndex = init.dayIndex;
      _hasTime = init.plannedAt != null;
      _plannedAt = init.plannedAt ?? DateTime.now();
    } else {
      _selectedPlace = widget.initialPlace;
      _latitude = widget.initialPlace?.latitude ?? widget.initialLatitude;
      _longitude = widget.initialPlace?.longitude ?? widget.initialLongitude;
      _placeName = widget.initialPlace?.name;
      _placeCategory = widget.initialPlace?.category;
      _dayIndex = widget.initialDayIndex ?? 0;
      _plannedAt = DateTime.now();
    }
    _prefetchUserLocation();
  }

  Future<void> _prefetchUserLocation() async {
    try {
      final pos = await ref
          .read(locationServiceProvider)
          .getCurrentPosition()
          .timeout(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _userLatitude = pos.latitude;
        _userLongitude = pos.longitude;
      });
    } catch (_) {
      // 권한 거부 / GPS 비활성 / 타임아웃 — 거리 표시 X. 시트는 정상 동작.
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave => _latitude != null && _longitude != null && !_saving;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    final isEditing = widget.initialItem != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스크롤 영역
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.md,
                  Dimensions.md,
                  Dimensions.md,
                  Dimensions.sm,
                ),
                children: [
                  // 핸들
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DottieColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),

                  // 제목
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: DottieColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? '스팟 수정' : '스팟 추가',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: DottieColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.sm),

                  // 장소
                  const _SectionLabel('어디로?'),
                  const SizedBox(height: Dimensions.sm),
                  _PlaceField(
                    name: _placeName,
                    category: _placeCategory,
                    onTap: _pickPlace,
                  ),
                  const SizedBox(height: Dimensions.lg),

                  // 여행 코스 전용 — 일자 chip + 시간 picker
                  if (widget.todoList.isTrip) ...[
                    const _SectionLabel('날짜'),
                    const SizedBox(height: Dimensions.sm),
                    _DayChipRow(
                      totalDays: widget.todoList.totalDays,
                      selectedDay: _dayIndex,
                      onChanged: (d) => setState(() => _dayIndex = d),
                    ),
                    const SizedBox(height: Dimensions.lg),
                    if (_hasTime) ...[
                      Row(
                        children: [
                          const _SectionLabel('시간'),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() => _hasTime = false),
                            style: TextButton.styleFrom(
                              foregroundColor: DottieColors.textHint,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('제거', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.sm),
                      _TimePickerRow(
                        value: TimeOfDay(
                            hour: _plannedAt.hour, minute: _plannedAt.minute),
                        onChanged: (t) => setState(() {
                          _plannedAt = DateTime(
                            _plannedAt.year,
                            _plannedAt.month,
                            _plannedAt.day,
                            t.hour,
                            t.minute,
                          );
                        }),
                      ),
                    ] else
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _hasTime = true;
                          _plannedAt = DateTime.now();
                        }),
                        icon: const Icon(Icons.schedule_outlined, size: 16),
                        label: const Text('시간 추가 (선택)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DottieColors.textSecondary,
                          side: const BorderSide(color: DottieColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          textStyle: const TextStyle(fontSize: 13),
                          minimumSize: const Size(0, 40),
                        ),
                      ),
                    const SizedBox(height: Dimensions.lg),
                  ],

                  // 감정
                  const _SectionLabel('기분 (선택)'),
                  const SizedBox(height: Dimensions.sm),
                  EmotionPicker(
                    selected: _selectedEmotion,
                    onChanged: (e) => setState(() => _selectedEmotion = e),
                  ),
                  const SizedBox(height: Dimensions.md),

                  // 메모
                  const _SectionLabel('왜 가고 싶어요? (선택)'),
                  const SizedBox(height: Dimensions.sm),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: '기대되는 것, 먹고 싶은 것, 이유...',
                      prefixIcon: const Icon(Icons.edit_outlined, size: 18,
                          color: DottieColors.textHint),
                      prefixIconConstraints: const BoxConstraints(
                          minWidth: 40, minHeight: 0),
                      filled: true,
                      fillColor: DottieColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                        borderSide: const BorderSide(
                            color: DottieColors.primary, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.md, vertical: 12),
                    ),
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) {
                      final over = maxLength != null && currentLength >= maxLength * 0.8;
                      return Text(
                        '$currentLength / $maxLength',
                        style: TextStyle(
                          fontSize: 11,
                          color: over ? DottieColors.error : DottieColors.textHint,
                        ),
                      );
                    },
                    style: GoogleFonts.notoSansKr(fontSize: 14),
                  ),
                ],
              ),
            ),

            // 고정 하단 — 항상 보임
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.md,
                Dimensions.sm,
                Dimensions.md,
                Dimensions.md + bottomPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_latitude == null && !_saving) ...[
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 13, color: DottieColors.textHint),
                        const SizedBox(width: 5),
                        Text(
                          '먼저 위에서 스팟을 골라주세요',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            color: DottieColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  DottieButton(
                    label: isEditing ? '저장' : '추가',
                    isLoading: _saving,
                    onTap: _canSave ? _save : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPlace() async {
    // 갈곳 모음 = 국내 전국 검색 (BE 호출엔 lat/lng 미전달).
    // 사용자 GPS 가 있으면 userLatitude/Longitude 로 *거리 표시 fallback* 만 전달.
    final picked = await PlaceSearchSheet.show(
      context,
      userLatitude: _userLatitude,
      userLongitude: _userLongitude,
    );
    if (picked == null) return;
    setState(() {
      _selectedPlace = picked;
      _latitude = picked.latitude;
      _longitude = picked.longitude;
      _placeName = picked.name;
      _placeCategory = picked.category;
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    // 시간이 설정된 경우에만 plannedAt을 전달. 미설정 시 null.
    DateTime? plannedAt;
    if (_hasTime) {
      if (widget.todoList.isTrip) {
        final base = widget.todoList.dateForDayIndex(_dayIndex);
        plannedAt = DateTime(
          base.year, base.month, base.day,
          _plannedAt.hour, _plannedAt.minute,
        );
      } else {
        plannedAt = _plannedAt;
      }
    }

    final notifier = ref.read(todoNotifierProvider.notifier);
    final init = widget.initialItem;
    try {
      // trimmed 값을 그대로 전달 — "" 도 null 이 아니라 빈 문자열로 전달.
      // BE의 optTextMax가 ""를 NULL로 변환하므로 PATCH에서도 기존 notes를 지울 수 있다.
      // null을 보내면 BE가 "변경 없음"으로 해석해 기존 값을 보존하므로 사용하지 않는다.
      final notesValue = _notesController.text.trim();
      if (init != null) {
        // 수정
        await notifier.updateItem(init.copyWith(
          latitude: _latitude!,
          longitude: _longitude!,
          placeName: _placeName,
          placeCategory: _placeCategory,
          placeId: _selectedPlace?.id ?? init.placeId,
          plannedAt: plannedAt,
          dayIndex: _dayIndex,
          notes: notesValue,
          emotion: _selectedEmotion,
        ));
      } else {
        // 생성
        await notifier.addItem(
          todoListId: widget.todoList.id,
          latitude: _latitude!,
          longitude: _longitude!,
          plannedAt: plannedAt,
          dayIndex: _dayIndex,
          placeName: _placeName,
          placeCategory: _placeCategory,
          placeId: _selectedPlace?.id,
          notes: notesValue.isEmpty ? null : notesValue,
          emotion: _selectedEmotion,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: DottieColors.textPrimary,
        ),
      );
}

class _DayChipRow extends StatelessWidget {
  const _DayChipRow({
    required this.totalDays,
    required this.selectedDay,
    required this.onChanged,
  });
  final int totalDays;
  final int selectedDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalDays.clamp(1, 30),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedDay;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? DottieColors.primary
                    : DottieColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? DottieColors.primary
                      : DottieColors.border,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Day ${i + 1}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : DottieColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  const _TimePickerRow({required this.value, required this.onChanged});
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final label =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => Platform.isIOS
          ? _showCupertinoPicker(context)
          : _showMaterialPicker(context),
      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 14),
        decoration: BoxDecoration(
          color: DottieColors.background,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          border: Border.all(color: DottieColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 18, color: DottieColors.primary),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: DottieColors.textHint),
          ],
        ),
      ),
    );
  }

  void _showCupertinoPicker(BuildContext context) {
    var selected = DateTime(2000, 1, 1, value.hour, value.minute);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onChanged(
                      TimeOfDay(hour: selected.hour, minute: selected.minute));
                },
                child: const Text('확인',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: selected,
                onDateTimeChanged: (dt) => selected = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMaterialPicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}

class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.name,
    required this.category,
    required this.onTap,
  });
  final String? name;
  final String? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPlace = name != null && name!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 12),
        decoration: BoxDecoration(
          color: hasPlace
              ? DottieColors.primary.withValues(alpha: 0.05)
              : DottieColors.background,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          border: Border.all(
            color: hasPlace
                ? DottieColors.primary.withValues(alpha: 0.5)
                : DottieColors.primary.withAlpha(100),
            width: hasPlace ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.place_outlined,
                size: 18,
                color: hasPlace
                    ? DottieColors.primary
                    : DottieColors.primary.withAlpha(160)),
            const SizedBox(width: 10),
            Expanded(
              child: hasPlace
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: name!,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DottieColors.textPrimary,
                            ),
                          ),
                          if (category != null && category!.isNotEmpty)
                            TextSpan(
                              text: ' · $category',
                              style: TextStyle(
                                fontSize: 11,
                                color: DottieColors.textPrimary
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '탭해서 장소 검색',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DottieColors.primary.withAlpha(180),
                      ),
                    ),
            ),
            Icon(Icons.search_rounded,
                size: 18,
                color: hasPlace
                    ? DottieColors.primary
                    : DottieColors.primary.withAlpha(140)),
          ],
        ),
      ),
    );
  }
}

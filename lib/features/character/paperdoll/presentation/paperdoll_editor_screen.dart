import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide colorFromHex;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/utils/text_validators.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../character/presentation/character_provider.dart';
import '../../../onboarding/domain/onboarding_step.dart';
import '../../../onboarding/presentation/onboarding_tour_provider.dart';
import '../../../onboarding/presentation/tour_completion_overlay.dart';
import '../../../onboarding/presentation/tour_content.dart';
import '../data/paperdoll_manifest.dart';
import '../data/paperdoll_renderer.dart';
import '../domain/paperdoll_config.dart';
import '../domain/paperdoll_parts.dart';
import 'widgets/paperdoll_preview.dart';
import 'widgets/part_picker.dart';

/// 도트 캐릭터 에디터 (신규).
///
/// 기존 `character_editor_screen.dart`를 대체할 화면.
/// 통합 시점에 `app_router.dart`의 character 라우트가 이 화면으로 교체된다.
///
/// 외부 의존성을 최소화하기 위해 Riverpod provider 없이 자체 상태로 동작.
/// 통합 시:
/// - `ref.read(paperdollRendererProvider)`로 renderer 주입
/// - `ref.read(paperdollNotifierProvider.notifier).save(config)`로 저장
class PaperdollEditorScreen extends ConsumerStatefulWidget {
  const PaperdollEditorScreen({
    super.key,
    required this.initialConfig,
    required this.onSave,
    this.renderer,
    this.errorMessage,
  });

  final PaperdollConfig initialConfig;

  /// 저장 버튼 누름 시 호출. true 반환 시 성공.
  final Future<bool> Function(PaperdollConfig config) onSave;

  /// 외부에서 renderer 주입 가능 (테스트/캐시 공유용)
  final PaperdollRenderer? renderer;

  /// 저장 실패 시 표시할 메시지를 반환 (provider의 lastError 등 활용).
  final String Function()? errorMessage;

  @override
  ConsumerState<PaperdollEditorScreen> createState() =>
      _PaperdollEditorScreenState();
}

class _PaperdollEditorScreenState extends ConsumerState<PaperdollEditorScreen> {
  late PaperdollRenderer _renderer;
  late PaperdollConfig _config;
  PaperdollManifestData? _manifest;
  EditableSlot _slot = EditableSlot.hair;
  bool _saving = false;

  final _previewKey = GlobalKey();
  bool _tourShown = false;
  TutorialCoachMark? _coachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;

  @override
  void initState() {
    super.initState();
    _renderer = widget.renderer ?? PaperdollRenderer();
    _config = widget.initialConfig;
    _loadManifest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(onboardingTourProvider) == OnboardingStep.character &&
          !_tourShown) {
        _showCharacterCoachMark();
      }
    });
    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _tourShown = false;
      }
      if (next == OnboardingStep.character && !_tourShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showCharacterCoachMark();
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _coachMark?.finish();
    super.dispose();
  }

  void _showCharacterCoachMark() {
    if (_tourShown) return;
    // manifest와 프리뷰 위젯이 모두 준비됐을 때만 표시
    if (_manifest == null || _previewKey.currentContext == null) return;
    _tourShown = true;
    _coachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'characterPreview',
          keyTarget: _previewKey,
          shape: ShapeLightFocus.RRect,
          radius: 20,
          paddingFocus: 10,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '지도 위를 움직이는\n내 캐릭터를 꾸며보세요',
                description: '색상과 스타일을 자유롭게 바꿀 수 있어요',
                actionLabel: '완료',
                onAction: () => controller.next(),
                stepCurrent: 5,
                stepTotal: 5,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.78,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () async {
        if (!mounted) return;
        // 사용자가 캐릭터를 변경했으면 조용히 저장 (snackbar 없이) — tour 완료
        // 화면이 곧 닫히기 때문에 직접 onSave 호출해 변경 사항 손실 방지.
        if (_isDirty) {
          try {
            await widget.onSave(_config);
          } catch (_) {
            // 저장 실패해도 tour 자체는 끝까지 진행
          }
          if (!mounted) return;
        }
        await ref.read(onboardingTourProvider.notifier).advance(); // character → done
        if (mounted) {
          await TourCompletionOverlay.show(context);
        }
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _coachMark!.show(context: context, rootOverlay: true);
  }

  Future<void> _loadManifest() async {
    final m = await PaperdollManifestLoader().load();
    if (!mounted) return;
    setState(() => _manifest = m);
    // manifest 로드 완료 후 프리뷰 위젯이 그려지면 투어 코치마크 재시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(onboardingTourProvider) == OnboardingStep.character) {
        _showCharacterCoachMark();
      }
    });
  }

  bool get _isDirty => _config != widget.initialConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('캐릭터', style: AppTypography.tabHeader()),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        foregroundColor: DottieColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('저장',
                    style: TextStyle(
                        color: DottieColors.primary,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _manifest == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(_manifest!),
    );
  }

  Widget _buildBody(PaperdollManifestData manifest) {
    final nickname = ref.watch(
      currentDottieUserProvider.select((v) => v.valueOrNull?.nickname),
    );

    return Column(
      children: [
        // ── 미리보기 영역 ──
        Container(
          key: _previewKey,
          width: double.infinity,
          color: DottieColors.surface,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.lg),
          child: Column(
            children: [
              PaperdollPreview(
                renderer: _renderer,
                config: _config,
                size: 256, // 64 * 4 — frameSize의 정수배라 nearest-neighbor 다운스케일 없음
                scale: 4.0,
                animate: true,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showNicknameDialog(nickname ?? ''),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nickname ?? '닉네임 없음',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DottieColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: DottieColors.textHint,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 정체성 색 picker (지도/댓글 식별 색) ──
        _IdentityColorPicker(
          selected: _config.colorHex,
          onSelected: (hex) =>
              setState(() => _config = _config.copyWith(colorHex: hex)),
        ),

        // ── 슬롯 탭 ──
        Container(
          color: DottieColors.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.sm),
            child: Row(
              children: EditableSlot.values
                  .map((s) => _SlotTab(
                        slot: s,
                        selected: _slot == s,
                        comingSoon: _isSlotEmpty(s, manifest),
                        onTap: () => setState(() => _slot = s),
                      ))
                  .toList(),
            ),
          ),
        ),
        const Divider(height: 1, color: DottieColors.border),

        // ── 색상 팔레트 (tintable 슬롯에서만) ──
        if (_currentSlotTintable(manifest))
          ColorPalettePicker(
            palette: kDefaultColorPalette,
            selected: _config.currentColorFor(_slot),
            // null 선택 = 슬롯 default 색으로 복귀 (BE는 hex 필수)
            onSelected: (hex) => setState(
              () => _config = _config.withSlotColor(
                _slot,
                hex ?? PaperdollConfig.defaultColorFor(_slot),
              ),
            ),
          ),

        // ── 옵션 그리드 ──
        Expanded(
          child: SingleChildScrollView(
            child: PartPicker(
              items: _slotItems(manifest),
              selectedId: _config.currentIdFor(_slot),
              onSelected: (id) => setState(
                () => _config = _config.withSlot(_slot, id),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PartItem> _slotItems(PaperdollManifestData m) {
    return switch (_slot) {
      EditableSlot.skin => m.parts[PartType.skin] ?? const [],
      EditableSlot.hair => m.parts[PartType.hairFront] ?? const [],
      EditableSlot.face => m.parts[PartType.face] ?? const [],
      EditableSlot.top => m.parts[PartType.top] ?? const [],
      EditableSlot.bottom => m.parts[PartType.bottom] ?? const [],
      EditableSlot.shoes => m.parts[PartType.shoes] ?? const [],
      EditableSlot.accessory => m.parts[PartType.accessory] ?? const [],
    };
  }

  bool _isSlotEmpty(EditableSlot slot, PaperdollManifestData m) {
    final list = switch (slot) {
      EditableSlot.skin => m.parts[PartType.skin],
      EditableSlot.hair => m.parts[PartType.hairFront],
      EditableSlot.face => m.parts[PartType.face],
      EditableSlot.top => m.parts[PartType.top],
      EditableSlot.bottom => m.parts[PartType.bottom],
      EditableSlot.shoes => m.parts[PartType.shoes],
      EditableSlot.accessory => m.parts[PartType.accessory],
    };
    return list == null || list.isEmpty;
  }

  bool _currentSlotTintable(PaperdollManifestData m) {
    if (_slot != EditableSlot.hair &&
        _slot != EditableSlot.top &&
        _slot != EditableSlot.bottom) {
      return false;
    }
    final id = _config.currentIdFor(_slot);
    final items = _slotItems(m);
    for (final item in items) {
      if (item.id == id) return item.tintable;
    }
    return false;
  }

  Future<void> _showNicknameDialog(String current) async {
    final newNickname = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NicknameSheet(current: current),
    );

    if (newNickname == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(characterNotifierProvider.notifier)
          .updateNickname(newNickname);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('닉네임이 변경됐어요!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: DottieColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _save() async {
    // async gap 이후 context가 무효화될 수 있어 messenger를 미리 캡처.
    final messenger = ScaffoldMessenger.of(context);
    if (!_isDirty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('변경된 내용이 없어요'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final ok = await widget.onSave(_config);
      if (!mounted) return;
      if (ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('캐릭터를 저장했어요'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final msg = widget.errorMessage?.call() ?? '저장에 실패했어요';
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: DottieColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SlotTab extends StatelessWidget {
  const _SlotTab({
    required this.slot,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });

  final EditableSlot slot;
  final bool selected;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final labelColor = comingSoon
        ? DottieColors.textHint
        : (selected ? DottieColors.primary : DottieColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 8),
        decoration: BoxDecoration(
          color: selected && !comingSoon
              ? DottieColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              slot.koLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: labelColor,
              ),
            ),
            if (comingSoon) ...[
              const SizedBox(width: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: DottieColors.textHint.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '준비 중',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textHint,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 사용자 정체성 색 picker — 5색 프리셋 동그라미.
///
/// 선택된 색은 흰 외곽 + 컬러 내부, 가운데 체크. 미선택은 컬러 채움만.
/// 캐릭터 옷/머리색과는 별개로, 지도/댓글에서 사용자 식별에 사용된다.
/// 사용자 정체성 색 picker — 5 프리셋 + 자유 색 (+) 버튼.
///
/// 선택값/콜백 모두 `#RRGGBB` hex 문자열. BE의 가독성 제약(S>=0.25, V 0.30~0.95)을
/// 만족하는 색만 선택 가능하며, 위반 시 picker 내부에서 차단됨.
class _IdentityColorPicker extends StatelessWidget {
  const _IdentityColorPicker({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  /// 선택된 hex가 5 프리셋과 다르면 "커스텀 색"으로 간주 — + 버튼 자리에 표시.
  bool get _isCustom {
    final lower = selected.toLowerCase();
    return !kCharacterColorPresetsHex
        .any((p) => p.toLowerCase() == lower);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DottieColors.surface,
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.sm, Dimensions.md, Dimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 색깔',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DottieColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: Dimensions.xs),
          const Text(
            '지도와 댓글에서 나를 구분하는 색이에요',
            style: TextStyle(
              fontSize: 11,
              color: DottieColors.textHint,
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...kCharacterColorPresetsHex.map((hex) {
                final isSelected =
                    hex.toLowerCase() == selected.toLowerCase();
                return _ColorDot(
                  color: colorFromHex(hex),
                  selected: isSelected,
                  onTap: () => onSelected(hex),
                );
              }),
              _CustomColorDot(
                currentHex: _isCustom ? selected : null,
                onPicked: onSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 자유 색 picker 버튼.
/// - 커스텀 색이 선택돼 있으면 그 색을 큰 동그라미로 표시 + check 아이콘
/// - 아니면 회색 outline + 가운데 + 아이콘
/// - 탭하면 HSV picker bottom sheet 오픈
class _CustomColorDot extends StatelessWidget {
  const _CustomColorDot({
    required this.currentHex,
    required this.onPicked,
  });

  final String? currentHex;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentHex != null;
    return GestureDetector(
      onTap: () async {
        final picked = await _CustomColorPickerSheet.show(
          context,
          initial: currentHex ?? '#7EB8F7',
        );
        if (picked != null) onPicked(picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: isSelected ? 40 : 32,
        height: isSelected ? 40 : 32,
        decoration: BoxDecoration(
          color: isSelected ? colorFromHex(currentHex!) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.white
                : DottieColors.border,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorFromHex(currentHex!).withAlpha(120),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isSelected
            ? const Icon(Icons.check_rounded,
                color: Colors.white, size: 18)
            : const Icon(Icons.add_rounded,
                color: DottieColors.textSecondary, size: 18),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: selected ? 40 : 32,
        height: selected ? 40 : 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: selected ? 3 : 0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withAlpha(120),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check_rounded,
                color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

// ── 닉네임 변경 바텀시트 ─────────────────────────────────────────

class _NicknameSheet extends StatefulWidget {
  const _NicknameSheet({required this.current});
  final String current;

  @override
  State<_NicknameSheet> createState() => _NicknameSheetState();
}

class _NicknameSheetState extends State<_NicknameSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = '닉네임을 입력해주세요');
      return;
    }
    if (trimmed.runes.length > 30) {
      setState(() => _errorText = '30자 이하로 입력해주세요');
      return;
    }
    if (!TextValidators.isValidUserText(trimmed)) {
      setState(() => _errorText = '글자를 완성해서 입력해주세요');
      return;
    }
    Navigator.pop(context, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md + bottomPadding),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          ).animate().fadeIn(duration: 200.ms),
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
                '닉네임 변경',
                style: GoogleFonts.notoSansKr(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DottieColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 60.ms)
              .slideY(begin: 0.1, end: 0, duration: 280.ms, delay: 60.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Dimensions.md),

          // 입력 필드
          Form(
            key: _formKey,
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 30,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              onSubmitted: (_) => _submit(),
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                color: DottieColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요',
                hintStyle: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  color: DottieColors.textHint,
                ),
                errorText: _errorText,
                errorStyle: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: DottieColors.error,
                ),
                counterStyle: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: DottieColors.textHint,
                ),
                filled: true,
                fillColor: DottieColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 120.ms)
              .slideY(begin: 0.06, end: 0, duration: 280.ms, delay: 120.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Dimensions.md),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                '변경하기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 180.ms)
              .slideY(begin: 0.08, end: 0, duration: 280.ms, delay: 180.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

// ── 자유 색 picker bottom sheet ─────────────────────────────────

class _CustomColorPickerSheet extends StatefulWidget {
  const _CustomColorPickerSheet({required this.initial});
  final String initial;

  static Future<String?> show(BuildContext context,
      {required String initial}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomColorPickerSheet(initial: initial),
    );
  }

  @override
  State<_CustomColorPickerSheet> createState() =>
      _CustomColorPickerSheetState();
}

class _CustomColorPickerSheetState extends State<_CustomColorPickerSheet> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = colorFromHex(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final hex = hexFromColor(_color);
    final issue = readabilityIssue(hex);
    final isOk = issue == null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md + bottomPadding),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: Dimensions.md),

          // 제목 + 현재 색 미리보기
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  border: Border.all(color: DottieColors.border, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '내 색깔 고르기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DottieColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              Text(
                hex,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: DottieColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.md),

          // HSV picker (drag로 hue + saturation/value 선택)
          ColorPicker(
            pickerColor: _color,
            onColorChanged: (c) => setState(() => _color = c),
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithSaturation,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
            pickerAreaBorderRadius: BorderRadius.circular(12),
          ),

          // 가독성 경고 / OK
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isOk
                ? Row(
                    key: const ValueKey('ok'),
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: DottieColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '딱 좋아요',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: DottieColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: ValueKey(issue),
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: DottieColors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        issue.koLabel,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: DottieColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: Dimensions.md),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isOk ? () => Navigator.pop(context, hex) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DottieColors.primary,
                disabledBackgroundColor:
                    DottieColors.primary.withAlpha(80),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                '이 색으로 저장',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

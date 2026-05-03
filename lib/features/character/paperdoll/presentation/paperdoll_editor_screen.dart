import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
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
class PaperdollEditorScreen extends StatefulWidget {
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
  State<PaperdollEditorScreen> createState() => _PaperdollEditorScreenState();
}

class _PaperdollEditorScreenState extends State<PaperdollEditorScreen> {
  late PaperdollRenderer _renderer;
  late PaperdollConfig _config;
  PaperdollManifestData? _manifest;
  EditableSlot _slot = EditableSlot.hair;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _renderer = widget.renderer ?? PaperdollRenderer();
    _config = widget.initialConfig;
    _loadManifest();
  }

  Future<void> _loadManifest() async {
    final m = await PaperdollManifestLoader().load();
    if (!mounted) return;
    setState(() => _manifest = m);
  }

  bool get _isDirty => _config != widget.initialConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: const Text('내 캐릭터'),
        backgroundColor: DottieColors.surface,
        foregroundColor: DottieColors.textPrimary,
        elevation: 0,
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
    return Column(
      children: [
        // ── 미리보기 영역 ──
        Container(
          width: double.infinity,
          color: DottieColors.surface,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.lg),
          child: Center(
            child: PaperdollPreview(
              renderer: _renderer,
              config: _config,
              size: 196,
              animate: true,
            ),
          ),
        ),

        // ── 정체성 색 picker (지도/댓글 식별 색) ──
        _IdentityColorPicker(
          selected: _config.colorKey,
          onSelected: (key) =>
              setState(() => _config = _config.copyWith(colorKey: key)),
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
  });

  final EditableSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        ),
        child: Text(
          slot.koLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? DottieColors.primary
                : DottieColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 사용자 정체성 색 picker — 5색 프리셋 동그라미.
///
/// 선택된 색은 흰 외곽 + 컬러 내부, 가운데 체크. 미선택은 컬러 채움만.
/// 캐릭터 옷/머리색과는 별개로, 지도/댓글에서 사용자 식별에 사용된다.
class _IdentityColorPicker extends StatelessWidget {
  const _IdentityColorPicker({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

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
          Text(
            '내 색깔',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DottieColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: Dimensions.xs),
          Text(
            '지도와 댓글에서 나를 구분하는 색이에요',
            style: TextStyle(
              fontSize: 11,
              color: DottieColors.textHint,
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: kCharacterColorKeys.map((key) {
              final color =
                  characterColorMap[key] ?? DottieColors.primary;
              final isSelected = key == selected;
              return _ColorDot(
                color: color,
                selected: isSelected,
                onTap: () => onSelected(key),
              );
            }).toList(),
          ),
        ],
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

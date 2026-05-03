import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../map_animation/domain/animation_frame.dart';
import '../../map_animation/presentation/widgets/character_overlay.dart';
import 'character_provider.dart';

class CharacterEditorScreen extends ConsumerWidget {
  const CharacterEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(characterNotifierProvider);
    final notifier = ref.read(characterNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text(
          '캐릭터',
          style: GoogleFonts.notoSansKr(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await notifier.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? '저장됐어요!' : '저장에 실패했어요')),
                );
              }
            },
            child: Text(
              '저장',
              style: GoogleFonts.notoSansKr(
                color: DottieColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 미리보기 카드
            _PreviewCard(config: config)
                .animate()
                .fadeIn(duration: 350.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  duration: 350.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 24),

            // 색상 선택
            _EditorCard(
              label: '색상',
              delay: 80,
              child: _ColorPicker(
                selectedKey: config.colorKey,
                onChanged: notifier.setColor,
              ),
            ),
            const SizedBox(height: 12),

            // 악세서리 선택
            _EditorCard(
              label: '악세서리',
              delay: 140,
              child: _OptionPicker(
                options: const [
                  _Option(key: 'none', label: '없음', emoji: '😶'),
                  _Option(key: 'hat', label: '모자', emoji: '🎩'),
                  _Option(key: 'glasses', label: '안경', emoji: '🕶️'),
                ],
                selectedKey: config.accessoryKey,
                onChanged: notifier.setAccessory,
              ),
            ),
            const SizedBox(height: 12),

            // 표정 선택
            _EditorCard(
              label: '표정',
              delay: 200,
              child: _OptionPicker(
                options: const [
                  _Option(key: 'default', label: '기본', emoji: '😐'),
                  _Option(key: 'happy', label: '웃음', emoji: '😊'),
                  _Option(key: 'sleepy', label: '잠', emoji: '😴'),
                ],
                selectedKey: config.expressionKey,
                onChanged: notifier.setExpression,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── 미리보기 카드 ──────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.config});
  final dynamic config;

  @override
  Widget build(BuildContext context) {
    final color =
        characterColorMap[config.colorKey] ?? DottieColors.primary;
    final state = _expressionToState(config.expressionKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DottieColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CharacterOverlayWidget(
                color: color,
                state: state,
                size: 70,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '내 캐릭터',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DottieColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  CharacterState _expressionToState(String key) => switch (key) {
        'sleepy' => CharacterState.sleeping,
        'happy' => CharacterState.arrived,
        _ => CharacterState.idle,
      };
}

// ── 에디터 카드 래퍼 ──────────────────────────────────────────

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.label,
    required this.child,
    required this.delay,
  });

  final String label;
  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DottieColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DottieColors.textHint,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms, delay: delay.ms, curve: Curves.easeOutCubic);
  }
}

// ─── 색상 피커 ────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selectedKey, required this.onChanged});

  final String selectedKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: characterColorMap.entries.map((e) {
        final isSelected = e.key == selectedKey;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 50 : 42,
            height: isSelected ? 50 : 42,
            decoration: BoxDecoration(
              color: e.value,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: DottieColors.textPrimary, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: e.value.withAlpha(100),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ─── 옵션 피커 ────────────────────────────────────────────────

class _Option {
  const _Option({required this.key, required this.label, required this.emoji});
  final String key;
  final String label;
  final String emoji;
}

class _OptionPicker extends StatelessWidget {
  const _OptionPicker({
    required this.options,
    required this.selectedKey,
    required this.onChanged,
  });

  final List<_Option> options;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options
          .map((opt) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: opt.key == selectedKey
                          ? DottieColors.primary
                          : DottieColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: opt.key == selectedKey
                          ? null
                          : Border.all(color: DottieColors.border, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        Text(opt.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 6),
                        Text(
                          opt.label,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: opt.key == selectedKey
                                ? Colors.white
                                : DottieColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

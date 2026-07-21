import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';
import '../../core/router/app_router.dart';
import '../../features/recording/domain/tag_parser.dart';
import '../../features/search/presentation/tag_search_provider.dart';

/// 메모 본문의 `#태그` 부분만 primary 색 + bold + 클릭 가능 영역으로 렌더.
///
/// SNS 표준 패턴 — Twitter/Instagram 의 본문 안 hashtag 처럼 자연스럽게 강조.
/// 별도 chip row 안 만들고 메모 흐름 안에 강조해 시각 무게 최소화.
///
/// 탭 시 햅틱 → [onBeforeNavigate] 호출 → 검색 화면 push (그 태그 선택 상태).
///
/// **호출 컨텍스트별 사용**:
/// - DotDetailSheet 안: `onBeforeNavigate: () => Navigator.of(context).pop()`
///   로 시트 닫고 검색 화면으로
/// - 피드 카드: `onBeforeNavigate: null` — 카드는 닫지 않고 push 만
class MemoWithInlineTags extends ConsumerStatefulWidget {
  const MemoWithInlineTags({
    super.key,
    required this.memo,
    this.style,
    this.tagStyle,
    this.maxLines,
    this.overflow,
    this.onBeforeNavigate,
  });

  final String memo;

  /// null 이면 default (fontSize 15, textPrimary, height 1.6).
  final TextStyle? style;

  /// 태그 부분만 별도 style. null 이면 default (primary + bold).
  final TextStyle? tagStyle;

  /// null 이면 무제한. 카드 같이 cap 필요한 곳에서 지정.
  final int? maxLines;

  final TextOverflow? overflow;

  /// 탭 직후, 검색 화면 push 직전에 호출. 시트 caller 는 여기서 시트를
  /// 닫음 (`Navigator.pop`). 카드 caller 는 null.
  final VoidCallback? onBeforeNavigate;

  @override
  ConsumerState<MemoWithInlineTags> createState() =>
      _MemoWithInlineTagsState();
}

class _MemoWithInlineTagsState extends ConsumerState<MemoWithInlineTags> {
  // TapGestureRecognizer 는 dispose 에서 해제 필수 (누수 방지).
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ??
        GoogleFonts.notoSansKr(
          fontSize: 15,
          color: DottieColors.textPrimary,
          height: 1.6,
        );
    final tagStyle = widget.tagStyle ??
        const TextStyle(
          color: DottieColors.primary,
          fontWeight: FontWeight.w700,
        );

    final tokens = TagParser.tokenize(widget.memo);
    if (tokens.isEmpty) {
      return Text(
        widget.memo,
        style: baseStyle,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    // 매 build 시점에 recognizer 재생성 (token 갱신에 맞춤).
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final spans = <TextSpan>[];
    for (final t in tokens) {
      if (!t.isTag) {
        spans.add(TextSpan(text: t.text));
        continue;
      }
      // `#` 제외한 태그 본문. lowercase 변환은 검색 측 TagParser.normalize 가 적용.
      final rawTag = t.text.substring(1);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _onTagTap(rawTag);
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: t.text,
          style: tagStyle,
          recognizer: recognizer,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      style: baseStyle,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

  void _onTagTap(String tag) {
    HapticFeedback.lightImpact();
    final router = GoRouter.of(context);
    ref.read(tagSearchProvider.notifier).clear();
    ref.read(tagSearchProvider.notifier).addTag(tag);
    widget.onBeforeNavigate?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.push(AppRoutes.search);
    });
  }
}

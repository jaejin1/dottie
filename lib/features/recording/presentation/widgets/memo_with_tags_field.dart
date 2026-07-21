import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../domain/tag_parser.dart';

/// 한 줄 메모 입력 + 해시태그 실시간 강조 + 자동완성 칩.
///
/// `RichText` 오버레이 대신 [TextEditingController.buildTextSpan] 을 override 한
/// 커스텀 컨트롤러로 작동 — TextField 내부 painter 가 그대로 색칠해 줘서
/// 캐럿/IME 동작이 깨지지 않음.
class MemoWithTagsField extends StatefulWidget {
  const MemoWithTagsField({
    super.key,
    required this.controller,
    required this.suggestionFetcher,
  });

  final HashtagAwareController controller;

  /// prefix 입력 시 호출 — 자동완성 후보 (lowercase) 반환.
  /// 빈 prefix(`#` 직후) 시 인기 태그 노출 용도로도 활용 가능.
  final Future<List<String>> Function(String prefix) suggestionFetcher;

  @override
  State<MemoWithTagsField> createState() => _MemoWithTagsFieldState();
}

class _MemoWithTagsFieldState extends State<MemoWithTagsField> {
  List<String> _suggestions = const [];
  String? _activePrefix;
  int _suggestionToken = 0; // race-condition 방어용
  Timer? _debounce;

  /// keystroke 마다 fetch 하면 BE 호출이 과도 → 200ms 디바운스.
  /// prefix 가 바뀌면(예: `#회` → `#회의`) 직전 타이머 취소 + 새 fetch 예약.
  static const Duration _debounceDelay = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    final value = widget.controller.value;
    final prefix = TagParser.activePrefix(
      value.text,
      value.selection.baseOffset,
    );
    if (prefix == _activePrefix) return;
    _activePrefix = prefix;

    // 활성 prefix 가 사라지면(공백 이동 등) 즉시 칩 제거 — 디바운스 불필요.
    if (prefix == null) {
      _debounce?.cancel();
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = const []);
      }
      return;
    }

    _debounce?.cancel();
    final token = ++_suggestionToken;
    _debounce = Timer(_debounceDelay, () async {
      // 디바운스 중 prefix 가 다시 바뀌면 token 불일치로 결과 무시.
      if (token != _suggestionToken) return;
      final fetched = await widget.suggestionFetcher(prefix);
      if (!mounted || token != _suggestionToken) return;
      setState(() => _suggestions = fetched);
    });
  }

  /// 활성 prefix 자리에 `tag` 토큰을 채워 넣고 캐럿을 토큰 끝으로 이동.
  void _applySuggestion(String tag) {
    final value = widget.controller.value;
    final caret = value.selection.baseOffset;
    if (caret < 0) return;
    // # 위치를 거꾸로 찾는다 — activePrefix 와 동일한 로직.
    var hashIdx = caret - 1;
    while (hashIdx >= 0 && value.text[hashIdx] != '#') {
      hashIdx--;
    }
    if (hashIdx < 0) return;
    final before = value.text.substring(0, hashIdx);
    final after = value.text.substring(caret);
    // 토큰 뒤에 공백 자동 삽입 (이미 공백이면 skip).
    final needsSpace = after.isEmpty || !after.startsWith(' ');
    final inserted = '#$tag${needsSpace ? ' ' : ''}';
    final newText = '$before$inserted$after';
    final newCaret = before.length + inserted.length;
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCaret),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: const InputDecoration(
            hintText: '메모 (선택) · #태그 사용 가능',
            prefixIcon: Icon(Icons.edit_outlined, size: 18),
          ),
          maxLines: 4,
          minLines: 1,
          // BE memo 한도 500자 — 사용자가 BE 거절을 받기 전에 OS 키보드 단에서 차단.
          maxLength: 500,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            // hint 색 톤 다운. 80% 초과 시 강조.
            final ratio = maxLength != null && maxLength > 0
                ? currentLength / maxLength
                : 0.0;
            return Text(
              '$currentLength / ${maxLength ?? 500}',
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                color: ratio >= 0.8
                    ? DottieColors.error.withAlpha(180)
                    : DottieColors.textHint,
              ),
            );
          },
        ),
        if (_suggestions.isNotEmpty) _SuggestionRow(
          suggestions: _suggestions,
          onPick: _applySuggestion,
        ),
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestions, required this.onPick});
  final List<String> suggestions;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final tag = suggestions[i];
            return GestureDetector(
              onTap: () => onPick(tag),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DottieColors.primary.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusFull),
                  border: Border.all(
                      color: DottieColors.primary.withAlpha(60), width: 0.8),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DottieColors.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// `#태그` 토큰을 primary 색으로 강조해 그리는 TextEditingController.
/// caret 동작은 기본 TextField 가 처리.
///
/// IME composing(한글 미확정) 영역은 기본 컨트롤러가 underline 으로 표시한다.
/// 토큰 분할로 새 TextSpan 만 만들면 그 underline 이 사라져 사용자가 어디까지
/// 미확정인지 모르게 됨 → composing 활성 시 강조를 끄고 super 의 default span
/// 을 그대로 사용 (단순/안전 우선).
class HashtagAwareController extends TextEditingController {
  HashtagAwareController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final hasComposing = withComposing && !value.composing.isCollapsed;
    if (hasComposing) {
      // composing 영역의 underline 동작을 보존 — 강조는 IME 확정 후에만 적용.
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final tokens = TagParser.tokenize(text);
    if (tokens.isEmpty) {
      return TextSpan(text: text, style: style);
    }
    return TextSpan(
      style: style,
      children: tokens
          .map((t) => TextSpan(
                text: t.text,
                // 태그 강조는 색 + 옅은 배경만. fontWeight/fontSize 는 상속받아
                // 일반 텍스트와 동일 — 글씨 크기/굵기 변화 없게.
                style: t.isTag
                    ? TextStyle(
                        color: DottieColors.primary,
                        backgroundColor: DottieColors.primary.withAlpha(20),
                      )
                    : null,
              ))
          .toList(),
    );
  }
}

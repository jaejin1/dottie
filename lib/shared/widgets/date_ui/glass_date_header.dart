import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';

/// 지도 화면 상단 글래스 알약 바.
///
/// 룸 / 홈 / 누적 화면이 공통으로 쓰는 헤더. 좌측 뒤로가기, 중앙은 2단 날짜
/// 표시(요일 + "5월 3일") 또는 단일 title, 우측은 trailing(옵셔널) 위젯.
///
/// 모드:
///   - 2단 날짜:  `date` 전달 → 탭하면 `onTapDate` (캘린더 시트 오픈)
///   - 단일 타이틀: `titleText` 전달 → 탭하면 `onTapTitle`
///
/// 둘 중 하나만 사용. `date` 가 있으면 2단 날짜 모드.
class GlassDateHeader extends StatelessWidget {
  const GlassDateHeader.date({
    super.key,
    required this.date,
    required this.onBack,
    required this.onTapDate,
    required this.isDaytime,
    this.trailing,
    this.backButtonKey,
  })  : titleText = null,
        onTapTitle = null;

  const GlassDateHeader.title({
    super.key,
    required this.titleText,
    required this.onBack,
    required this.isDaytime,
    this.onTapTitle,
    this.trailing,
    this.backButtonKey,
  })  : date = null,
        onTapDate = null;

  /// `YYYY-MM-DD` 형태 (2단 날짜 모드).
  final String? date;
  final VoidCallback onBack;
  final VoidCallback? onTapDate;

  /// 단일 타이틀 텍스트 (title 모드).
  final String? titleText;
  final VoidCallback? onTapTitle;

  /// 낮/밤 모드. 낮은 어두운 글래스, 밤은 반투명 흰 글래스.
  final bool isDaytime;

  /// 우측 위젯 (옵셔널). 보통 IconButton.
  final Widget? trailing;

  /// 뒤로가기 버튼에 붙일 key (coach mark 타겟 등에 사용).
  final GlobalKey? backButtonKey;

  @override
  Widget build(BuildContext context) {
    final bg = isDaytime
        ? const Color(0xCC1C1C1E)
        : Colors.white.withAlpha(22);
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(45);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.sm, Dimensions.md, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.xs),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: border, width: 1),
              ),
              child: Row(
                children: [
                  IconButton(
                    key: backButtonKey,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: onBack,
                  ),
                  Expanded(child: _buildCenter()),
                  trailing ?? const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenter() {
    if (date != null) {
      return _DateColumn(
        date: date!,
        onTap: () {
          HapticFeedback.lightImpact();
          onTapDate?.call();
        },
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapTitle == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTapTitle!();
            },
      child: Center(
        child: Text(
          (titleText ?? '').isEmpty ? ' ' : titleText!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.date, required this.onTap});
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date) ?? DottieDateUtils.todayStart();
    final topLabel = DottieDateUtils.relativeLabel(parsed) ??
        DottieDateUtils.toKoreanWeekday(parsed);
    final dateLabel = DottieDateUtils.toKoreanMonthDay(parsed);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topLabel,
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withAlpha(160),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

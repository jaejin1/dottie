import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/location_utils.dart';
import '../../data/places_remote_source.dart';
import '../../domain/place.dart';

/// B8 — 장소 검색 시트. 두 가지 모드:
///   - **근처 검색** (lat/lng 전달): dot 기록 시점의 500m 반경 인증용.
///     BE 가 응답의 `distance` 채워줌.
///   - **국내 전국 검색** (lat/lng null): 갈곳 모음 추가용 — 한국 전역.
///     BE distance 는 null. 호출자가 [userLatitude]/[userLongitude] 를 전달하면
///     클라이언트 측에서 거리 계산해 결과에 표시.
///
/// 해외 검색은 BE backend (카카오 Local Search) 한계로 미지원 — 결과 0/빈약.
class PlaceSearchSheet extends ConsumerStatefulWidget {
  const PlaceSearchSheet({
    super.key,
    this.latitude,
    this.longitude,
    this.userLatitude,
    this.userLongitude,
    this.initialQuery,
  });

  /// **BE 검색용 좌표.** 둘 다 전달되면 500m 반경 + nearest-first 검색.
  /// null 이면 국내 전국 검색.
  final double? latitude;
  final double? longitude;

  /// **거리 표시용 사용자 좌표** (전국 검색 시 fallback).
  /// BE 응답 `distance` 가 null 인 경우 클라이언트가 [LocationUtils.distanceM]
  /// 로 계산해 결과 row 에 표시. dot 흐름엔 보통 [latitude]/[longitude] 만
  /// 전달하면 BE 가 distance 채워주므로 이 인자 불필요.
  final double? userLatitude;
  final double? userLongitude;

  final String? initialQuery;

  static Future<Place?> show(
    BuildContext context, {
    double? latitude,
    double? longitude,
    double? userLatitude,
    double? userLongitude,
    String? initialQuery,
  }) {
    return showModalBottomSheet<Place>(
      context: context,
      backgroundColor: DottieColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PlaceSearchSheet(
        latitude: latitude,
        longitude: longitude,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  ConsumerState<PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<PlaceSearchSheet> {
  late final TextEditingController _controller;
  Timer? _debounce;
  List<Place> _results = const [];
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(widget.initialQuery!));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
        _errorMessage = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final list = await ref
          .read(placesRemoteSourceProvider)
          .search(
            query: query,
            latitude: widget.latitude,
            longitude: widget.longitude,
          );
      if (!mounted) return;
      setState(() {
        _results = list;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      // 서버 4xx/5xx 와 네트워크 오류를 구분해 사용자에게 단서 제공.
      String msg;
      if (e.response == null) {
        msg = '네트워크 연결을 확인해 주세요.';
      } else {
        msg = '검색에 실패했어요. (${e.response?.statusCode ?? '-'})';
      }
      setState(() {
        _results = const [];
        _loading = false;
        _errorMessage = msg;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _loading = false;
        _errorMessage = '검색에 실패했어요.';
      });
    }
  }

  /// 미터 단위 거리 → 사람 친화 표현. <1km 는 "120m", 그 이상은 "1.2km".
  static String _formatDistance(int distanceM) {
    if (distanceM < 1000) return '${distanceM}m';
    final km = distanceM / 1000;
    return '${km.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return ConstrainedBox(
      // 화면 60% 까지만 — 키보드 올라와도 자연스럽게 들어맞도록.
      // 검색 결과 많아도 결과 영역(Flexible) 내부 스크롤로 처리.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Dimensions.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.md),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  color: DottieColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '장소 검색 (예: 스타벅스 강남)',
                  hintStyle: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    color: DottieColors.textHint,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: DottieColors.textHint),
                  filled: true,
                  fillColor: DottieColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 검색 범위 안내 — 좌표 유무로 모드 분기.
            //   좌표 있음: 500m 근처 (dot 인증용)
            //   좌표 없음: 국내 전국 (갈곳 모음용. 해외는 미지원)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensions.md),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 12, color: DottieColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    widget.latitude != null && widget.longitude != null
                        ? '현재 위치 근처에서 검색해요'
                        : '국내 전국에서 검색해요 (해외 미지원)',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: DottieColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.sm),
            const Divider(color: DottieColors.border, height: 1),
            Flexible(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: DottieColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : _results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: Dimensions.md),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _errorMessage != null
                                      ? '검색이 안 돼요'
                                      : _controller.text.trim().isEmpty
                                          ? '검색어를 입력하세요'
                                          : '검색 결과가 없어요',
                                  style: GoogleFonts.notoSansKr(
                                    color: DottieColors.textHint,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.notoSansKr(
                                      color: DottieColors.textHint,
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                ] else if (_controller.text.trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.latitude != null &&
                                            widget.longitude != null
                                        ? '근처에 그 장소가 없어요.\n근처로 이동하거나 다른 검색어로 시도해 보세요.'
                                        : '국내에서 그 장소를 찾지 못했어요.\n해외 장소는 아직 지원되지 않아요.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.notoSansKr(
                                      color: DottieColors.textHint,
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          // 콘텐츠 만큼만 자라게 — 결과 1개일 때 시트가 maxHeight
                          // 까지 펼쳐지지 않음. 결과 많으면 부모 Flexible 의
                          // 한계 안에서 자체 스크롤.
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: DottieColors.border,
                            height: 1,
                            indent: 60,
                          ),
                          itemBuilder: (context, idx) {
                            final p = _results[idx];
                            // 거리: BE 가 채운 distance 우선. 없으면 사용자 좌표로
                            // 클라이언트 측 계산 (전국 검색 흐름).
                            int? distanceM = p.distance;
                            if (distanceM == null &&
                                widget.userLatitude != null &&
                                widget.userLongitude != null) {
                              distanceM = LocationUtils.distanceM(
                                widget.userLatitude!,
                                widget.userLongitude!,
                                p.latitude,
                                p.longitude,
                              ).round();
                            }
                            // subtitle: 거리 · 짧은 카테고리 · 도로명/주소.
                            // categoryGroupName 우선 (예: "카페"), 없으면 풀패스.
                            final parts = <String>[
                              if (distanceM != null)
                                _formatDistance(distanceM),
                              if (p.categoryGroupName != null &&
                                  p.categoryGroupName!.isNotEmpty)
                                p.categoryGroupName!
                              else if (p.category != null)
                                p.category!,
                              if (p.roadAddress != null) p.roadAddress!,
                              if (p.address != null && p.roadAddress == null)
                                p.address!,
                            ];
                            return ListTile(
                              leading: const Icon(
                                Icons.place_outlined,
                                color: DottieColors.primary,
                              ),
                              title: Text(
                                p.name,
                                style: GoogleFonts.notoSansKr(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: DottieColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                parts.join(' · '),
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  color: DottieColors.textHint,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(p);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

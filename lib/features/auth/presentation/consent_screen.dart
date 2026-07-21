import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import 'auth_provider.dart';

/// 필수 약관 문서 버전 — BE `requiredConsents` 와 동기 유지.
/// 약관 개정 시 BE 버전과 함께 올린다 (불일치 시 400 CONSENT_INCOMPLETE).
const kConsentDocVersion = '1.0';

/// 약관 동의 게이트 화면 — 로그인 후 `consent_required == true` 면 진입.
///
/// 위치정보법상 위치기반서비스 약관은 명시적 동의가 필요하므로
/// "로그인 시 동의 간주" 문구로는 부족 — 개별 체크 방식 사용.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  static const _docs = [
    (type: 'terms', label: '서비스 이용약관', path: '/terms'),
    (type: 'privacy', label: '개인정보처리방침', path: '/privacy'),
    (type: 'location', label: '위치기반서비스 이용약관', path: '/location-terms'),
    (type: 'age14', label: '만 14세 이상입니다', path: null),
  ];

  final Set<String> _agreed = {};
  bool _submitting = false;

  bool get _allAgreed => _agreed.length == _docs.length;

  void _toggleAll() {
    setState(() {
      if (_allAgreed) {
        _agreed.clear();
      } else {
        _agreed.addAll(_docs.map((d) => d.type));
      }
    });
  }

  Future<void> _logout() async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
    } finally {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  Future<void> _submit() async {
    if (!_allAgreed || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.post(
        '/users/me/consents',
        data: {
          'consents': _docs
              .map(
                (d) => {'doc_type': d.type, 'doc_version': kConsentDocVersion},
              )
              .toList(),
        },
      );
      // 갱신을 await — invalidate 만 하면 라우터 redirect 가 이전 값
      // (consentRequired=true, AsyncLoading 이 이전 값 보존)을 읽어
      // /home → /consent 로 되돌리는 루프에 걸려 스피너가 멈추지 않음.
      final refreshed =
          await ref.refresh(currentDottieUserProvider.future);
      if (!mounted) return;
      if (refreshed?.consentRequired == true) {
        // BE 가 여전히 미동의로 판정 — 버전 불일치 등. 스피너 해제 후 안내.
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동의 처리에 실패했어요. 다시 시도해 주세요.')),
        );
        return;
      }
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동의 처리에 실패했어요. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 우측 최상단 구석 로그아웃 — 동의하지 않고 나가는 낮은 강조 출구.
            Positioned(
              top: 2,
              right: 6,
              child: TextButton(
                onPressed: _submitting ? null : _logout,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '로그아웃',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DottieColors.textHint,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.xl),
                  Text(
                    'Dottie를 시작하려면\n동의가 필요해요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: DottieColors.textPrimary,
                      height: 1.35,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '위치 기록 서비스 제공을 위해 아래 약관 동의가 필요합니다',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      color: DottieColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Dimensions.xl),

                  // 전체 동의
                  GestureDetector(
                    onTap: _toggleAll,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.md,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _allAgreed
                            ? DottieColors.primary.withValues(alpha: 0.08)
                            : DottieColors.surface,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusMd,
                        ),
                        border: Border.all(
                          color: _allAgreed
                              ? DottieColors.primary.withValues(alpha: 0.5)
                              : DottieColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          _CheckCircle(checked: _allAgreed),
                          const SizedBox(width: 10),
                          Text(
                            '전체 동의',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DottieColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.sm),

                  // 개별 항목
                  for (final doc in _docs)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _agreed.contains(doc.type)
                                    ? _agreed.remove(doc.type)
                                    : _agreed.add(doc.type);
                              }),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.md,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    _CheckCircle(
                                      checked: _agreed.contains(doc.type),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        '(필수) ${doc.label}',
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 14,
                                          color: DottieColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (doc.path != null)
                            GestureDetector(
                              onTap: () => launchUrl(
                                Uri.parse('${AppConfig.webHost}${doc.path}'),
                                mode: LaunchMode.externalApplication,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '보기',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 12,
                                    color: DottieColors.textSecondary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: DottieColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _allAgreed && !_submitting ? _submit : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary,
                        disabledBackgroundColor: DottieColors.primary
                            .withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusMd,
                          ),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              '동의하고 시작하기',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? DottieColors.primary : Colors.transparent,
        border: Border.all(
          color: checked ? DottieColors.primary : DottieColors.textHint,
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

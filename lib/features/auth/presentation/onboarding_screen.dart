import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/router/app_router.dart';
import 'auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🔵',
      title: '하루를 점으로 기록해요',
      subtitle: '하루 동안 이동한 곳마다 dot을 찍어\n나만의 하루 지도를 만들어요',
    ),
    _OnboardingPage(
      emoji: '🗺️',
      title: '캐릭터가 하루를 되짚어요',
      subtitle: '귀여운 캐릭터가 내 발자국을 따라\n지도 위를 움직여요',
    ),
    _OnboardingPage(
      emoji: '💕',
      title: '친구와 같은 지도 위에서',
      subtitle: '같은 날 기록을 합치면\n우리의 하루가 한 지도에 펼쳐져요',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.md),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('건너뛰기',
                      style: TextStyle(color: DottieColors.textSecondary)),
                ),
              ),
            ),

            // 페이지
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? DottieColors.primary
                        : DottieColors.textHint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.lg),

            // 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
              child: _currentPage < _pages.length - 1
                  ? FilledButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusMd),
                        ),
                      ),
                      child: const Text('다음',
                          style: TextStyle(fontSize: 16)),
                    )
                  : FilledButton(
                      onPressed: () => context.go(AppRoutes.login),
                      style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusMd),
                        ),
                      ),
                      child: const Text('시작하기',
                          style: TextStyle(fontSize: 16)),
                    ),
            ),
            const SizedBox(height: Dimensions.lg),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 96)),
          const SizedBox(height: Dimensions.xl),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: DottieColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.md),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: DottieColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── 로그인 화면 ──────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _login(Future<bool> Function() loginFn) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await loginFn();
      if (success && mounted) {
        context.go(AppRoutes.home);
      } else if (mounted) {
        final authState = ref.read(authNotifierProvider);
        if (authState is AsyncError) {
          _showError(_friendlyError(authState.error));
        }
      }
    } catch (e) {
      if (mounted) _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-disabled' => '비활성화된 계정이에요.',
        'network-request-failed' => '네트워크 연결을 확인해주세요.',
        'too-many-requests' => '잠시 후 다시 시도해주세요.',
        _ => '로그인에 실패했어요. 다시 시도해주세요.',
      };
    }
    if (error is DioException) return '서버 연결에 실패했어요. 잠시 후 다시 시도해주세요.';
    return '로그인에 실패했어요. 다시 시도해주세요.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: DottieColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.xl),
          child: Column(
            children: [
              const Spacer(),
              const Text('🔵', style: TextStyle(fontSize: 80)),
              const SizedBox(height: Dimensions.md),
              const Text('Dottie',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: DottieColors.primary,
                      letterSpacing: -1)),
              const SizedBox(height: Dimensions.sm),
              const Text('같은 하루, 다른 발자국',
                  style: TextStyle(
                      fontSize: 15, color: DottieColors.textSecondary)),
              const Spacer(),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.md),
                  child: CircularProgressIndicator(),
                ),

              _SocialLoginButton(
                color: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                emoji: '💬',
                label: '카카오로 시작하기',
                onTap: _isLoading ? null : () => _login(auth.loginWithKakao),
              ),
              const SizedBox(height: Dimensions.sm),

              _SocialLoginButton(
                color: Colors.black,
                textColor: Colors.white,
                emoji: '🍎',
                label: 'Apple로 시작하기',
                onTap: _isLoading ? null : () => _login(auth.loginWithApple),
              ),
              const SizedBox(height: Dimensions.sm),

              _SocialLoginButton(
                color: DottieColors.surface,
                textColor: DottieColors.textPrimary,
                emoji: '🌐',
                label: 'Google로 시작하기',
                onTap: _isLoading ? null : () => _login(auth.loginWithGoogle),
                border: Border.all(color: DottieColors.textHint),
              ),

              const SizedBox(height: Dimensions.xl),
              const Text('로그인하면 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                  style: TextStyle(fontSize: 11, color: DottieColors.textHint),
                  textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.color,
    required this.textColor,
    required this.emoji,
    required this.label,
    required this.onTap,
    this.border,
  });

  final Color color;
  final Color textColor;
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: Dimensions.sm),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}

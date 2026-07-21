import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/todo_remote_source.dart';
import '../domain/course_exceptions.dart';
import 'todo_provider.dart';

/// 코스 초대 미리보기 — 인증 불필요. 로그인 후 "함께 편집하기" 로 멤버 참여.
final _courseInvitePreviewProvider = FutureProvider.autoDispose.family<
    ({
      String todoListId,
      String name,
      String? coverEmoji,
      String ownerNickname,
      int memberCount,
      DateTime expiresAt,
      String role,
    })?,
    String>(
  (ref, code) async {
    final preview =
        await ref.read(todoRemoteSourceProvider).getCourseInvitePreview(code);
    if (preview == null) return null;
    return (
      todoListId: preview.todoListId,
      name: preview.name,
      coverEmoji: preview.coverEmoji,
      ownerNickname: preview.ownerNickname,
      memberCount: preview.memberCount,
      expiresAt: preview.expiresAt,
      role: preview.role,
    );
  },
);

class CourseInviteScreen extends ConsumerStatefulWidget {
  const CourseInviteScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<CourseInviteScreen> createState() => _CourseInviteScreenState();
}

class _CourseInviteScreenState extends ConsumerState<CourseInviteScreen> {
  bool _loading = false;
  String? _errorMessage;
  bool _alreadyMember = false;

  Future<void> _join() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final id = await ref
          .read(todoNotifierProvider.notifier)
          .joinCourse(widget.code);
      if (!mounted) return;

      if (id == null) {
        setState(() {
          _loading = false;
          _errorMessage = '네트워크 연결을 확인하고 다시 시도해 주세요.';
        });
        return;
      }

      context.go('/todos/$id');
    } on JoinCourseException catch (e) {
      if (!mounted) return;
      if (e.code == 'COURSE_ALREADY_MEMBER') {
        setState(() {
          _loading = false;
          _alreadyMember = true;
        });
      } else {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = '코스 참여에 실패했어요. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final preview = ref.watch(_courseInvitePreviewProvider(widget.code));

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        backgroundColor: DottieColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/todos');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // 코스 이모지 or 기본 아이콘
              preview.when(
                loading: () => _iconCircle(null),
                error: (_, __) => _iconCircle(null),
                data: (info) => _iconCircle(info?.coverEmoji),
              ),
              const SizedBox(height: 24),
              // 코스 이름 or 스켈레톤
              preview.when(
                loading: () => _SkeletonBox(width: 180, height: 28, radius: 6),
                error: (_, __) => const Text(
                  '코스 초대',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: DottieColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                data: (info) => Text(
                  info != null ? info.name : '코스 초대',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: DottieColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 소유자 · 멤버수 · 만료일
              preview.when(
                loading: () => _SkeletonBox(width: 220, height: 18, radius: 4),
                error: (_, __) => const Text(
                  '네트워크 연결을 확인하고 다시 시도해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: DottieColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                data: (info) {
                  if (info == null) {
                    return const Text(
                      '초대 코드가 만료됐거나 올바르지 않아요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: DottieColors.error,
                        height: 1.5,
                      ),
                    );
                  }
                  final expireStr =
                      DottieDateUtils.toDateString(info.expiresAt);
                  final isViewer = info.role == 'viewer';
                  return Column(
                    children: [
                      Text(
                        '${info.ownerNickname}님이 초대했어요',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DottieColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (isViewer) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DottieColors.textHint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '👁 보기 전용으로 초대됐어요',
                            style: TextStyle(
                              fontSize: 12,
                              color: DottieColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '멤버 ${info.memberCount}명 · 초대 링크는 $expireStr까지 유효해요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              DottieColors.textPrimary.withValues(alpha: 0.45),
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              const Spacer(),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 13, color: DottieColors.error),
                ),
                const SizedBox(height: 12),
              ],
              if (_alreadyMember) ...[
                const Text(
                  '이미 참여 중인 코스예요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: DottieColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: '코스 목록 보기',
                  onPressed: () => context.go('/todos'),
                ),
              ] else if (!isAuth) ...[
                const Text(
                  '로그인 후 코스에 참여할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: DottieColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: '로그인하기',
                  onPressed: () => context.go('/onboarding'),
                ),
              ] else ...[
                _ActionButton(
                  label: preview.valueOrNull?.role == 'viewer'
                      ? '보기로 참여하기'
                      : '함께 편집하기',
                  loading: _loading,
                  onPressed: preview.valueOrNull == null && preview.hasValue
                      ? null
                      : _join,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconCircle(String? emoji) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: DottieColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: emoji != null
          ? Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)))
          : const Icon(
              Icons.route_rounded,
              size: 36,
              color: DottieColors.primary,
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DottieColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox(
      {required this.width, required this.height, required this.radius});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DottieColors.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

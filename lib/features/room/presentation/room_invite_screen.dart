import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/room_remote_source.dart';
import 'room_provider.dart';

/// 초대 코드 미리보기 (방 이름, 멤버 수, 만료일) — 인증 불필요.
final _invitePreviewProvider = FutureProvider.autoDispose
    .family<({String roomName, int memberCount, DateTime expiresAt})?, String>(
  (ref, code) => ref.read(roomRemoteSourceProvider).getRoomInvitePreview(code),
);

class RoomInviteScreen extends ConsumerStatefulWidget {
  const RoomInviteScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<RoomInviteScreen> createState() => _RoomInviteScreenState();
}

class _RoomInviteScreenState extends ConsumerState<RoomInviteScreen> {
  bool _loading = false;
  String? _errorMessage;
  bool _alreadyMember = false;

  Future<void> _join() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final room =
          await ref.read(roomNotifierProvider.notifier).joinRoom(widget.code);
      if (!mounted) return;

      if (room == null) {
        setState(() {
          _loading = false;
          _errorMessage = '초대 코드가 만료됐거나 올바르지 않아요.';
        });
        return;
      }

      context.go('/rooms/${room.id}');
    } on JoinRoomException catch (e) {
      if (!mounted) return;
      if (e.code == 'ROOM_ALREADY_MEMBER') {
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
        _errorMessage = '방 참여에 실패했어요. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  static String _formatExpiry(DateTime expiresAt) {
    final diff = expiresAt.toLocal().difference(DateTime.now());
    if (diff.isNegative) return '만료됨';
    if (diff.inHours < 1) return '${diff.inMinutes.clamp(1, 59)}분 후 만료';
    if (diff.inHours < 24) return '${diff.inHours}시간 후 만료';
    return '${diff.inDays}일 후 만료';
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final preview = ref.watch(_invitePreviewProvider(widget.code));

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
              context.go('/home');
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
              // 방 아이콘 서클
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: DottieColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 36,
                  color: DottieColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // 방 이름
              preview.when(
                loading: () => _SkeletonBox(width: 160, height: 28, radius: 6),
                error: (_, __) => const Text(
                  '방 초대',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: DottieColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                data: (info) => Text(
                  info != null ? info.roomName : '방 초대',
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
              // 멤버 수 + 만료 안내
              preview.when(
                loading: () => _SkeletonBox(width: 200, height: 18, radius: 4),
                error: (_, __) => const Text(
                  '초대 링크로 방에 참여해 보세요!',
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
                  final expiryStr = _formatExpiry(info.expiresAt);
                  return Column(
                    children: [
                      Text(
                        '멤버 ${info.memberCount}명이 함께하고 있어요',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DottieColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '초대 링크는 $expiryStr',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: DottieColors.textPrimary.withValues(alpha: 0.45),
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
                  '이미 참여 중인 방이에요.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: DottieColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: '방 목록으로',
                  onPressed: () => context.go('/rooms'),
                ),
              ] else if (!isAuth) ...[
                const Text(
                  '로그인 후 방에 참여할 수 있어요.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: DottieColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: '로그인하기',
                  onPressed: () => context.go('/onboarding'),
                ),
              ] else ...[
                _ActionButton(
                  label: '방 참여하기',
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

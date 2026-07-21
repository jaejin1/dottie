import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/onboarding_step.dart';

part 'onboarding_tour_provider.g.dart';

@Riverpod(keepAlive: true)
class OnboardingTour extends _$OnboardingTour {
  String? _uid;

  static String _key(String uid) => 'onboarding.tour_completed_v1.$uid';

  @override
  OnboardingStep build() => OnboardingStep.idle;

  Future<void> init(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    state = OnboardingStep.idle;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_key(uid)) ?? false;
    if (!done) {
      state = OnboardingStep.dotFab;
    }
  }

  Future<void> advance() async {
    HapticFeedback.lightImpact();
    final next = switch (state) {
      OnboardingStep.idle => OnboardingStep.idle,
      OnboardingStep.dotFab => OnboardingStep.dotSheet,
      OnboardingStep.dotSheet => OnboardingStep.mapHint,
      OnboardingStep.mapHint => OnboardingStep.calendarDay,
      OnboardingStep.calendarDay => OnboardingStep.bottomTabRoom,
      OnboardingStep.bottomTabRoom => OnboardingStep.room,
      OnboardingStep.room => OnboardingStep.character,
      OnboardingStep.character || OnboardingStep.done => OnboardingStep.done,
    };
    state = next;
    if (next == OnboardingStep.done) await _markDone();
  }

  Future<void> skip() async {
    state = OnboardingStep.done;
    await _markDone();
  }

  Future<void> restart() async {
    final prefs = await SharedPreferences.getInstance();
    if (_uid != null) await prefs.remove(_key(_uid!));
    state = OnboardingStep.dotFab;
  }

  bool get isActive =>
      state != OnboardingStep.idle && state != OnboardingStep.done;

  Future<void> _markDone() async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_uid!), true);
  }
}

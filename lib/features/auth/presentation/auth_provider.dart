import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

// Firebase Auth 인스턴스
@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

// 현재 로그인 상태 스트림
@riverpod
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

// 현재 유저
@riverpod
User? currentUser(Ref ref) =>
    ref.watch(firebaseAuthProvider).currentUser;

// 로그인 여부
@riverpod
bool isAuthenticated(Ref ref) =>
    ref.watch(currentUserProvider) != null;

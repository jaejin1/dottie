# Dottie ProGuard/R8 규칙
# release 빌드에서 R8 코드 축소/난독화 활성화(build.gradle.kts) 시 필요한 keep.
# 리플렉션/직렬화/네이티브 브릿지를 쓰는 플러그인이 stripping 으로 깨지지 않도록 보호.

# ── Flutter ──────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ── Flutter deferred components (Play Core) ──
# 미사용이라도 R8 이 참조 못 찾으면 빌드 실패하는 대표적 케이스 → 경고 무시.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# ── Firebase (Auth / Messaging / Core) ──
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Kakao SDK (리플렉션 기반 모델 직렬화) ──
-keep class com.kakao.sdk.** { *; }
-keep interface com.kakao.sdk.** { *; }
-dontwarn com.kakao.sdk.**

# ── geolocator / 위치 ──
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# ── SQLCipher (네이티브 라이브러리 로딩) ──
-keep class net.sqlcipher.** { *; }
-dontwarn net.sqlcipher.**

# ── flutter_local_notifications (Gson 직렬화) ──
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Gson (직렬화 대상 필드 리플렉션 접근)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# 네이티브 메서드 시그니처 유지
-keepclasseswithmembernames class * {
    native <methods>;
}

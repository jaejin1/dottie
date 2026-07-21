# 보안 하드닝 적용 내역 & 남은 작업

배포 전 보안 감사(공격자 관점) 후 적용한 조치 정리. 감사 결론: 원격 서버 장악급 취약점 없음. 실질 위험은 (1) release 로그 PII 유출, (2) 무암호 로컬 위치 DB, (3) 바이너리 하드닝 부재 — 아래 모두 조치.

## 적용 완료 (코드/설정)

| # | 항목 | 변경 파일 |
|---|------|-----------|
| P0 | release 로그 전역 차단 + 민감 로그 assert 가드 | `lib/main.dart`, `dot_remote_source.dart`, `push_notification_service.dart`, `push_token_remote_source.dart` |
| P1-1 | 로그아웃/탈퇴 시 로컬 DB 전체 삭제(`wipeAll`) | `app_database.dart`, `auth_provider.dart` |
| P1-2 | 로컬 DB SQLCipher 암호화 + 평문→암호화 마이그레이션 | `app_database.dart`, `pubspec.yaml` |
| P1-3 | Android 백업 차단(`allowBackup=false` + dataExtractionRules) | `AndroidManifest.xml`, `res/xml/data_extraction_rules.xml` |
| P2-2 | 난독화(`--obfuscate`) + R8 코드 축소 | `Makefile`, `build.gradle.kts`, `proguard-rules.pro` |
| P2-3 | 인증서 피닝 (Android, 체인 기반 루트 핀) | `AndroidManifest.xml`, `res/xml/network_security_config.xml` |
| P2-4 | secure storage 옵션 하드닝(공유 상수) | `lib/core/storage/secure_storage.dart` + 3개 사용처 |
| P2-5 | prod https 강제(시작 시 fail-fast) | `app_config.dart`, `main.dart` |

검증: `flutter analyze` 클린, `flutter test` 27건 통과, obfuscated release APK 빌드 성공(R8+SQLCipher+network config 병합 확인).

## ⚠ 사용자 수동 작업 필요

### 1. 릴리스 서명 키 생성 (P2-1) — Play Store 배포 전 필수
현재 release 는 `key.properties` 가 없으면 **디버그 키로 폴백**(테스트 배포는 동작, 정식 배포 불가).
```bash
keytool -genkey -v -keystore ~/dottie-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
→ `android/key.properties.example` 를 복사해 `android/key.properties` 작성(값 채우기). 둘 다 gitignore 됨. keystore 비밀번호는 안전한 곳에 백업(분실 시 앱 업데이트 불가).

### 2. iOS 인증서 피닝 (P2-3 나머지)
Android 는 `network_security_config` 로 적용됨. iOS 는 동등 기능이 없어 **TrustKit**(pod) 또는 네이티브 `URLSession` delegate 로 별도 구현 필요 — pod 추가 + Swift 코드 + 실기기 검증이 필요해 이번 자동 적용에서 제외. 우선순위 낮으면 Android 만으로도 주요 MITM(사용자 설치 CA) 위협은 커버됨.

### 3. 콘솔 측 토큰 제한 (감사 BE/콘솔 항목)
`--obfuscate` 는 **문자열 상수를 못 가린다** — Mapbox pk 토큰·API URL 은 여전히 `strings` 로 추출됨(런타임에 써야 하는 값이라 원천적 한계). 실효 방어는:
- **Mapbox 콘솔**: pk 토큰에 URL(도메인) 제한 설정.
- **GCP 콘솔**: Firebase API 키에 App Check·앱 번들ID 제한.

## 실기기 검증 체크리스트 (배포 전 반드시)

SQLCipher·secure storage·피닝은 호스트 테스트로는 완전 검증 불가 — 실기기 필요:

- [ ] **DB 암호화**: 기존 평문 DB 있는 상태로 업데이트 설치 → 앱 정상 실행 + 기존 dot 유지(마이그레이션 성공). 신규 설치도 정상.
- [ ] **DB 파일 확인**: 루팅/시뮬레이터에서 `dottie.db` 를 `sqlite3` 로 열면 "file is not a database"(암호화됨).
- [ ] **로그아웃 삭제**: 로그아웃 후 재로그인 시 이전 데이터 미노출.
- [ ] **secure storage 전환**: Android `encryptedSharedPreferences` 전환으로 기존 로그인 사용자의 미러 토큰이 한 번 초기화될 수 있음 → 앱 재실행 시 자동 재기록되는지(백그라운드 sync 포함) 확인.
- [ ] **인증서 피닝**: mitmproxy 등에 신뢰 CA 설치 후 앱 실행 → API 호출이 **실패**해야 정상(피닝 동작). 정상 네트워크에선 문제없이 동작.
- [ ] **로그 유출**: `adb logcat | grep -iE 'lat|lng|raw=|token'` — dot 저장/푸시 수신 시 좌표·payload 미출력.

## 핀 갱신 (중요)

`network_security_config.xml` 의 핀은 **Let's Encrypt 상위 CA** 기준(leaf 는 90일마다 바뀌므로 핀 안 함). expiration=2027-01-01 이후 자동 해제(fail-open)되어 CA 교체 시 앱이 죽는 것을 방지. 만료 전 재검토:
```bash
openssl s_client -connect app.dottie.today:443 -servername app.dottie.today -showcerts </dev/null \
  | # 각 인증서 SPKI SHA-256 base64 재계산해 pin 값 갱신
```

## 서버(BE) 확인 항목 — FE 수정 불가

1. 모든 `:id` 경로 멤버십/소유권 검증(IDOR).
2. 초대 코드(8-hex) 만료·rate-limit·enumeration 방어.
3. client-supplied `photo_url` 호스트 검증(악성 URL 저장 차단).
4. 카카오 access token 서버 검증, ID 토큰 revoke 반영.
5. presigned 미디어 URL 스코프·만료.

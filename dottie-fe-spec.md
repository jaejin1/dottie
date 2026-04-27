# Dottie Frontend Specification
## Flutter Mobile App — Project Setup & MVP Development Guide

---

## 1. 프로젝트 개요

### 1.1 앱 이름 & 컨셉
- **이름:** Dottie (도티)
- **슬로건:** "같은 하루, 다른 발자국" / "Connect the Dots"
- **컨셉:** 하루 동안의 위치를 시간별로 기록(dot)하고, 지도 위에 귀여운 캐릭터가 시간순으로 움직이는 애니메이션을 자동 생성하는 앱. 친구/연인과 공유하면 한 지도 위에 각자의 캐릭터가 동시에 움직이며 하루를 회고하는 "지도 브이로그".
- **레퍼런스 앱:** setlog (시간별 2초 영상 → 자동 브이로그), Polarsteps (여행 동선 지도), Zenly (소셜 지도, 서비스 종료)

### 1.2 타겟 사용자
- 한국인 MZ세대 (20~35세)
- 사용 시나리오: 여행 기록, 데이트 코스, 등산 모임, 일상 공유

### 1.3 개발 환경
- **1인 개발자** (풀스택)
- FE/BE 각각 Claude agent로 개발 보조

---

## 2. 기술 스택

### 2.1 Framework
- **Flutter 3.x** (latest stable)
- Dart 3.x
- iOS 17.0+ / Android API 26+ (Android 8.0)

### 2.2 지도 엔진 — Mapbox
- **패키지:** `mapbox_maps_flutter` (공식 Mapbox SDK, v2.22.0+)
- **Mapbox 한국 지원 상태:**
  - 한국어(CJK) 라벨 완벽 지원 (name_ko 필드)
  - 한국 위성 이미지 30cm 해상도 업데이트 완료 (2026.01)
  - POI(관심 지점) 데이터 한국 커버리지 양호
  - 한국 도로명 주소 지오코딩 지원
  - **주의:** 한국 정밀 도로 데이터는 네이버/카카오맵 대비 약간 부족할 수 있으나, Dottie는 내비게이션이 아니라 위치 기록이므로 충분함
- **Mapbox Studio:** 커스텀 지도 스타일 생성 (Dottie 브랜드에 맞는 미니멀/일러스트 스타일)
- **무료 티어:** 월 25,000 MAU 무료 → MVP에 충분

### 2.3 상태 관리
- **Riverpod 2.x** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
- 코드 생성 기반으로 boilerplate 최소화

### 2.4 라우팅
- **go_router** (Flutter 공식 추천)

### 2.5 인증
- **Firebase Auth** (`firebase_auth`, `google_sign_in`, `sign_in_with_apple`)
- 소셜 로그인: 카카오 로그인 (`kakao_flutter_sdk`), Apple Sign In, Google Sign In
- Firebase Auth Custom Token 방식으로 백엔드 Go 서버와 연동

### 2.6 위치 수집
- **geolocator** — 위치 권한 & 현재 위치 가져오기
- **flutter_local_notifications** — 시간별 dot 알림
- 배터리 최적화: 상시 GPS 아님. 알림 → 앱 열기 → 그때 위치 1회 수집 (setlog 방식)
- 별도 백그라운드 위치 추적 없음 (v1에서는)

### 2.7 네트워크 / API
- **dio** — HTTP 클라이언트 (interceptor, retry, token refresh)
- **retrofit** (선택) — API 코드 생성

### 2.8 로컬 저장소
- **drift** (SQLite 래퍼) — 오프라인 dot 데이터 캐싱
- **shared_preferences** — 간단한 설정값
- **flutter_secure_storage** — 토큰 저장

### 2.9 이미지/미디어
- **image_picker** — 사진 촬영/선택
- **cached_network_image** — 이미지 캐싱

### 2.10 애니메이션
- **rive** 또는 **lottie** — 캐릭터 모션 애니메이션
- Mapbox AnnotationManager — 지도 위 캐릭터 오버레이
- **AnimationController + Ticker** — 지도 카메라 & 캐릭터 시간순 이동 애니메이션

### 2.11 기타
- **freezed** + **json_serializable** — 모델 클래스 코드 생성
- **flutter_screenutil** — 반응형 UI
- **intl** — 날짜/시간 포맷

---

## 3. 프로젝트 구조

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, Router, Theme
├── core/
│   ├── config/
│   │   ├── app_config.dart     # 환경변수, API URL 등
│   │   └── mapbox_config.dart  # Mapbox access token, 스타일 URL
│   ├── constants/
│   │   ├── colors.dart         # Dottie 브랜드 컬러
│   │   └── dimensions.dart
│   ├── network/
│   │   ├── api_client.dart     # Dio 설정, interceptor
│   │   └── api_endpoints.dart
│   ├── router/
│   │   └── app_router.dart     # GoRouter 설정
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_utils.dart
│       └── location_utils.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_remote_source.dart
│   │   ├── domain/
│   │   │   └── user_model.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── onboarding_screen.dart
│   │       └── auth_provider.dart
│   ├── recording/
│   │   ├── data/
│   │   │   ├── dot_repository.dart
│   │   │   ├── dot_local_source.dart   # drift DB
│   │   │   └── dot_remote_source.dart  # API 호출
│   │   ├── domain/
│   │   │   ├── dot_model.dart          # {lat, lng, timestamp, photo?, memo?, emotion?}
│   │   │   └── recording_session.dart
│   │   └── presentation/
│   │       ├── recording_screen.dart   # 기록 중 메인 화면
│   │       ├── dot_input_sheet.dart     # dot 찍을 때 사진/메모 입력 바텀시트
│   │       ├── recording_provider.dart
│   │       └── widgets/
│   │           ├── recording_fab.dart   # 기록 시작/종료 FAB
│   │           └── dot_marker.dart
│   ├── timeline/
│   │   ├── data/
│   │   │   └── timeline_repository.dart
│   │   ├── domain/
│   │   │   └── day_log_model.dart       # 하루치 dot 리스트 + 통계
│   │   └── presentation/
│   │       ├── timeline_screen.dart      # 내 기록 리스트
│   │       ├── day_detail_screen.dart    # 특정 날짜 지도 상세
│   │       └── timeline_provider.dart
│   ├── map_animation/
│   │   ├── data/
│   │   │   └── animation_builder.dart   # dot 리스트 → 애니메이션 시퀀스 변환
│   │   ├── domain/
│   │   │   ├── animation_frame.dart
│   │   │   └── character_model.dart
│   │   └── presentation/
│   │       ├── map_animation_screen.dart # 지도 애니메이션 재생 화면
│   │       ├── animation_controls.dart   # 재생/일시정지/스크럽
│   │       ├── animation_provider.dart
│   │       └── widgets/
│   │           ├── character_overlay.dart  # 지도 위 캐릭터
│   │           ├── time_scrubber.dart      # 시간 슬라이더
│   │           └── dot_popup.dart          # 사진/메모 팝업
│   ├── room/
│   │   ├── data/
│   │   │   └── room_repository.dart
│   │   ├── domain/
│   │   │   ├── room_model.dart          # {id, name, members[], created_at}
│   │   │   └── invite_model.dart
│   │   └── presentation/
│   │       ├── room_list_screen.dart     # 내 방 목록
│   │       ├── room_detail_screen.dart   # 방 안에서 멤버들 기록 보기
│   │       ├── create_room_screen.dart
│   │       ├── room_provider.dart
│   │       └── widgets/
│   │           └── member_avatar.dart
│   ├── shared_map/
│   │   ├── data/
│   │   │   └── shared_map_repository.dart
│   │   └── presentation/
│   │       ├── shared_map_screen.dart    # 여러 명 캐릭터가 동시에 움직이는 합본 지도
│   │       └── shared_map_provider.dart
│   ├── character/
│   │   ├── domain/
│   │   │   └── character_config.dart    # 색상, 악세서리, 표정
│   │   └── presentation/
│   │       ├── character_editor_screen.dart
│   │       └── character_preview.dart
│   └── settings/
│       └── presentation/
│           └── settings_screen.dart
└── shared/
    ├── widgets/
    │   ├── dottie_button.dart
    │   ├── dottie_app_bar.dart
    │   └── loading_indicator.dart
    └── extensions/
        └── context_extensions.dart
```

---

## 4. 핵심 데이터 모델

### 4.1 Dot (위치 점 하나)
```dart
@freezed
class Dot with _$Dot {
  const factory Dot({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    String? placeName,        // 역지오코딩으로 얻은 장소명
    String? placeCategory,    // cafe, restaurant, park 등
    String? photoUrl,
    String? memo,
    String? emotion,          // happy, tired, excited 등 이모지 키
  }) = _Dot;
}
```

### 4.2 DayLog (하루 기록)
```dart
@freezed
class DayLog with _$DayLog {
  const factory DayLog({
    required String id,
    required String userId,
    required DateTime date,
    required List<Dot> dots,
    required DateTime startedAt,
    DateTime? endedAt,
    // 통계 (서버에서 계산)
    double? totalDistanceKm,
    int? placeCount,
    Duration? totalDuration,
  }) = _DayLog;
}
```

### 4.3 Room (공유 방)
```dart
@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    required String ownerId,
    required List<RoomMember> members,
    required DateTime createdAt,
    String? inviteCode,
  }) = _Room;
}

@freezed
class RoomMember with _$RoomMember {
  const factory RoomMember({
    required String userId,
    required String nickname,
    required CharacterConfig character,
    required DateTime joinedAt,
  }) = _RoomMember;
}
```

### 4.4 CharacterConfig
```dart
@freezed
class CharacterConfig with _$CharacterConfig {
  const factory CharacterConfig({
    @Default('blue') String colorKey,
    @Default('none') String accessoryKey,
    @Default('default') String expressionKey,
  }) = _CharacterConfig;
}
```

---

## 5. 화면별 상세 명세

### 5.1 온보딩 & 로그인 (auth)

**온보딩 (3 페이지 스와이프)**
1. "하루를 점으로 기록해요" — dot 찍기 일러스트
2. "캐릭터가 하루를 되짚어요" — 지도 애니메이션 일러스트
3. "친구와 같은 지도 위에서" — 합본 일러스트

**로그인**
- 카카오 로그인 (한국 1순위)
- Apple Sign In (iOS 필수)
- Google Sign In
- Firebase Auth Custom Token 방식:
  1. 클라이언트에서 소셜 로그인 → OAuth token 획득
  2. Go 백엔드로 token 전송 → 검증 → Firebase Custom Token 발급
  3. 클라이언트에서 `signInWithCustomToken`

**최초 로그인 후**
- 닉네임 입력
- 캐릭터 커스터마이징 (색상/악세서리 선택)
- 위치 권한 요청 (한 번 or 앱 사용 중)

### 5.2 홈 화면 (timeline)

**레이아웃:**
- 상단: 프로필 아이콘 + "Dottie" 로고
- 중앙: 캘린더 뷰 (기록한 날에 dot 표시) 또는 리스트 뷰 토글
- 하단: 기록 시작 FAB (크게, 눈에 띄게)
- 바텀 내비: 홈(타임라인) | 방 목록 | 캐릭터 | 설정

**캘린더 뷰:**
- 기록한 날짜에 작은 dot 아이콘 표시
- 날짜 탭 → 해당 날 지도 애니메이션 상세로 이동

### 5.3 기록 화면 (recording)

**기록 시작 시:**
- "오늘 하루를 기록할게요!" 토스트
- 상태바 또는 앱 내 인디케이터로 기록 중 표시
- 1시간마다 로컬 알림: "지금 어디에 있어요? dot을 찍어보세요 🔵"

**Dot 찍기 (알림 탭 또는 수동):**
1. 앱 열기 → 현재 위치 자동 수집
2. 바텀 시트 올라옴:
   - 현재 위치 지도 미리보기 (작은 맵)
   - 역지오코딩 장소명 자동 표시
   - 사진 추가 버튼 (선택)
   - 한 줄 메모 입력 (선택)
   - 감정 이모지 선택 (선택): 😊😴🎉🍽️☕ 등
3. "dot 찍기" 버튼 탭 → 저장 → 로컬 DB에 즉시 저장, 네트워크 있으면 서버 동기화

**기록 종료:**
- 수동: "기록 끝내기" 버튼
- 자동: 자정에 자동 종료
- 종료 시 "오늘의 지도를 만들어볼까요?" → 애니메이션 화면으로 이동

### 5.4 지도 애니메이션 화면 (map_animation)

**핵심 화면 — Dottie의 메인 경험**

**레이아웃:**
- 전체 화면 Mapbox 지도
- 상단: 날짜 + "OOO의 하루" 타이틀
- 하단: 타임라인 스크럽 바 (09:00 ─────●──── 22:00)
- 재생/일시정지 버튼
- 속도 조절 (1x, 2x, 4x)

**애니메이션 로직:**
1. 서버에서 해당 날의 dot 리스트 로드 (시간순 정렬)
2. 지도 카메라: 모든 dot이 보이는 bounds로 초기 세팅
3. 재생 시작:
   - 캐릭터가 첫 번째 dot에서 시작
   - 시간 흐름에 따라 다음 dot으로 이동 (카메라도 따라감)
   - 이동 중: 캐릭터가 걷기/뛰기/차 타기 모션 (dot 간 거리에 따라)
   - dot 도착 시: 잠깐 멈춤 + 사진/메모가 있으면 말풍선 팝업
   - 장소 카테고리에 따라 캐릭터 모션 변경 (카페→커피, 음식점→먹기)
4. 이동 궤적: 지도 위에 점선/부드러운 곡선으로 표시 (Mapbox LineLayer)
5. 타임라인 스크럽: 사용자가 드래그하면 해당 시점으로 점프

**영상 내보내기 (P1):**
- 애니메이션을 mp4로 캡처
- 인스타 릴스/스토리 비율 선택 (9:16, 1:1)
- 공유 시트 (카카오톡, 인스타, 저장)

### 5.5 방 (room)

**방 목록:**
- 내가 속한 방 카드 리스트
- 각 카드: 방 이름 + 멤버 캐릭터 아이콘들 + 최근 기록 날짜
- "+ 방 만들기" 버튼

**방 만들기:**
- 방 이름 입력 (예: "나와 여자친구", "등산 모임")
- 초대 링크 생성 → 카카오톡/메시지로 공유
- 최대 인원: 4명 (MVP)

**방 상세:**
- 멤버 목록 + 각자 캐릭터
- 캘린더에 각 멤버가 기록한 날 표시 (색상으로 구분)
- 날짜 선택 → 공유 지도 보기
- "내 오늘 기록을 이 방에 공유하기" 버튼

### 5.6 공유 지도 (shared_map)

**합본 애니메이션:**
- 같은 날 2명 이상의 기록이 있을 때 활성화
- 한 지도 위에 각자의 캐릭터가 각자의 색상으로 동시에 움직임
- 같은 시간대에 반경 100m 이내 → "만남" 이벤트 표시 (하트 or 하이파이브 이모션)
- 각 캐릭터의 궤적은 다른 색상 라인으로 표시

### 5.7 캐릭터 편집기 (character)

**커스터마이징 옵션 (MVP):**
- 색상: 5가지 (블루, 민트, 코랄, 라벤더, 옐로우)
- 악세서리: 3가지 (없음, 모자, 안경)
- 표정: 3가지 (기본, 웃음, 잠)
- 실시간 미리보기

---

## 6. 위치 수집 전략 (배터리 최적화)

### 6.1 핵심 원칙
- **상시 백그라운드 GPS 추적 안 함** (v1)
- setlog 방식: 알림 → 사용자가 앱 열기 → 그때 위치 1회 수집
- 배터리 영향 최소

### 6.2 알림 스케줄
```
기록 시작 후:
- 1시간 간격 로컬 알림 (flutter_local_notifications)
- 알림 텍스트: "지금 어디? dot 찍어봐 🔵" / "뭐하고 있어? 📍" (랜덤)
- 사용자가 알림 무시해도 OK (강제 아님)
- 자정에 자동 종료
```

### 6.3 위치 수집 코드 흐름
```
1. 사용자가 앱 열기 (알림 탭 or 직접)
2. geolocator.getCurrentPosition(
     desiredAccuracy: LocationAccuracy.high,
     timeLimit: Duration(seconds: 10),
   )
3. Mapbox Reverse Geocoding API → 장소명 획득
4. Dot 객체 생성 → 로컬 DB 저장
5. 네트워크 가능 시 서버 sync
```

### 6.4 v2 확장 (선택적 백그라운드)
- 사용자 선택 옵션으로 "자동 dot 수집" 추가
- Significant Location Change API (iOS) / Fused Location Provider (Android)
- 큰 이동(500m+) 감지 시에만 자동 dot 생성
- 배터리 소모 최소

---

## 7. Mapbox 커스텀 스타일

### 7.1 Mapbox Studio에서 커스텀 스타일 생성
- 기본: Mapbox Light 또는 Outdoors 기반
- 색상 톤: Dottie 브랜드 (파스텔/미니멀)
- 한국어 라벨 설정: `name_ko` 필드 사용
- 불필요한 레이어 제거 (교통, 건물 높이 등 간소화)
- 스타일 URL을 앱에서 참조

### 7.2 지도 위 오버레이
- **궤적 라인:** GeoJsonSource + LineLayer (dash-array 스타일)
- **Dot 마커:** SymbolLayer 또는 CircleLayer
- **캐릭터:** Point Annotation with custom image (Rive/Lottie에서 렌더링 → 이미지로 변환 → Mapbox에 올리기)
- **말풍선 팝업:** Flutter Overlay Widget (지도 좌표 → 화면 좌표 변환)

---

## 8. API 통신 명세 (Backend와의 인터페이스)

### 8.1 Base URL
```
Production: https://api.dottie.app/v1
Development: http://localhost:8080/v1
```

### 8.2 인증 헤더
```
Authorization: Bearer <firebase_id_token>
```

### 8.3 주요 엔드포인트 (FE가 호출할 API)

```
# 인증
POST   /auth/login              # 소셜 토큰 → Firebase Custom Token
POST   /auth/refresh             # 토큰 갱신

# 사용자
GET    /users/me                 # 내 프로필
PUT    /users/me                 # 프로필 수정 (닉네임, 캐릭터)
PUT    /users/me/character       # 캐릭터 설정 변경

# 기록
POST   /recordings/start         # 기록 세션 시작
POST   /recordings/end           # 기록 세션 종료
POST   /dots                     # dot 하나 저장
GET    /dots?date=2026-04-27     # 특정 날짜 dot 리스트
POST   /dots/batch               # 오프라인 동기화 (여러 dot 일괄 업로드)

# 하루 기록
GET    /daylogs                  # 내 기록 목록 (페이지네이션)
GET    /daylogs/:id              # 특정 하루 기록 상세 (dots + 통계)
DELETE /daylogs/:id              # 기록 삭제

# 방
POST   /rooms                   # 방 생성
GET    /rooms                   # 내 방 목록
GET    /rooms/:id               # 방 상세 (멤버 목록)
POST   /rooms/:id/invite        # 초대 코드 생성
POST   /rooms/join              # 초대 코드로 참여
DELETE /rooms/:id/leave          # 방 나가기

# 공유 지도
POST   /rooms/:id/share          # 내 daylog을 방에 공유
GET    /rooms/:id/shared-map?date=2026-04-27  # 해당 날짜 멤버들 합본 데이터

# 미디어
POST   /media/upload             # 사진 업로드 → presigned URL 반환
```

---

## 9. 로컬 DB 스키마 (drift/SQLite)

```dart
// 오프라인 우선: dot은 로컬에 먼저 저장, 이후 서버 sync
class DotTable extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get placeName => text().nullable()();
  TextColumn get placeCategory => text().nullable()();
  TextColumn get photoLocalPath => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get emotion => text().nullable()();
  TextColumn get dayLogId => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DayLogTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get isRecording => boolean().withDefault(const Constant(false))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 10. 빌드 & 배포

### 10.1 환경 분리
- `--dart-define` 으로 환경변수 주입
  - `API_URL`, `MAPBOX_ACCESS_TOKEN`, `FIREBASE_PROJECT_ID`
- flavor: dev / staging / prod

### 10.2 CI/CD
- GitHub Actions
- fastlane (iOS/Android 자동 빌드 & 배포)

### 10.3 코드 생성
```bash
# freezed, json_serializable, riverpod_generator, drift 등
dart run build_runner build --delete-conflicting-outputs
```

---

## 11. MVP 개발 우선순위

### Phase 1 (2주) — 코어 인프라
- [ ] Flutter 프로젝트 생성 & 폴더 구조 세팅
- [ ] Firebase 연동 (Auth)
- [ ] 카카오/Apple/Google 소셜 로그인
- [ ] Mapbox 연동 & 커스텀 스타일 적용
- [ ] Dio + API client 세팅
- [ ] drift 로컬 DB 세팅
- [ ] go_router 네비게이션 세팅
- [ ] 기본 테마 & 컴포넌트 (버튼, 앱바 등)

### Phase 2 (2주) — 기록 기능
- [ ] 기록 시작/종료 플로우
- [ ] 알림 스케줄링 (1시간 간격)
- [ ] Dot 수집 & 로컬 저장
- [ ] Dot 서버 동기화
- [ ] 역지오코딩 (장소명 자동)
- [ ] 사진 첨부 & 업로드
- [ ] 타임라인 (캘린더 + 리스트)

### Phase 3 (3주) — 지도 애니메이션
- [ ] 캐릭터 디자인 & Rive/Lottie 적용
- [ ] 지도 위 궤적 라인 그리기
- [ ] 캐릭터 이동 애니메이션 엔진
- [ ] 타임라인 스크럽 바
- [ ] 재생 컨트롤 (재생/일시정지/속도)
- [ ] Dot 도착 시 말풍선 팝업

### Phase 4 (2주) — 소셜 (방 & 공유)
- [ ] 방 CRUD
- [ ] 초대 링크 (딥링크)
- [ ] 기록 공유하기
- [ ] 합본 지도 (멀티 캐릭터)
- [ ] 만남 감지

### Phase 5 (1주) — 폴리싱
- [ ] 온보딩 화면
- [ ] 캐릭터 편집기
- [ ] 에러 핸들링 & 로딩 상태
- [ ] 오프라인 모드 안정화
- [ ] 성능 테스트 & 최적화

---

## 12. 캐릭터 시스템 상세

### 12.1 캐릭터 형태
- 동그란 "점(dot)" 기반 미니 캐릭터
- 머리 = 큰 원, 몸체 = 작은 원 (or 없음) → 심플한 2등신
- 눈 + 표정으로 감정 표현
- 크기: 지도 위에서 약 40x40dp

### 12.2 모션 정의 (Rive 또는 Lottie)
| 상태 | 모션 |
|------|------|
| idle (정지) | 가만히 서서 위아래로 살짝 바운스 |
| walking | 뒤뚱뒤뚱 걷기 (dot 간 거리 < 2km) |
| driving | 앞으로 쏙 날아가기 (dot 간 거리 > 2km) |
| sleeping | 눈 감고 zZz 말풍선 (30분+ 같은 위치) |
| cafe | 커피잔 들기 (placeCategory == 'cafe') |
| restaurant | 먹기 모션 (placeCategory == 'restaurant') |
| arrived | 깜짝 등장 + 손 흔들기 (dot 도착 시) |

### 12.3 구현 방식
- Rive 파일로 캐릭터 + 모션 제작 (state machine)
- 런타임에 색상 파라미터 변경 (Rive의 color input)
- 지도 위 표시: Rive 위젯 렌더 → 이미지로 변환 → Mapbox PointAnnotation에 set
- 위치 이동: `mapboxMap.flyTo()` + annotation 좌표 업데이트를 AnimationController로 동기화

---

## 13. 주의사항 & 제약

### 13.1 한국 위치정보법
- 위치기반서비스사업자 신고 필요 (방송통신위원회)
- 개인위치정보 수집·이용 동의 UI 필수
- 위치정보 보유 기간 명시 & 파기 절차

### 13.2 Mapbox 제약
- Mapbox 로고 & 출처 표시 필수 (제거 불가)
- 월 25,000 MAU 초과 시 과금 시작
- 오프라인 맵 캐싱은 무료 티어에서 제한적

### 13.3 Flutter 제약
- Mapbox Flutter SDK는 Web 미지원 (iOS/Android only) — 문제 없음
- 지도 위 캐릭터 애니메이션은 Flutter 오버레이 방식으로 구현 시 성능 주의 → 가능한 한 Mapbox AnnotationManager 활용

---

*이 문서는 Claude agent가 Dottie Flutter 프로젝트를 초기 설정하고 MVP를 개발하는 데 필요한 모든 컨텍스트를 담고 있습니다. 각 Phase별로 작업 시 이 문서를 참조하세요.*


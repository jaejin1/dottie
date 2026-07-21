# 안드로이드 테스트 배포 — Firebase App Distribution

TestFlight의 안드로이드 대응 방법. 테스터 10명 미만, 스토어 등록 전 단계에 적합.

## TestFlight vs Firebase App Distribution

| | TestFlight | Firebase App Distribution |
|---|---|---|
| 테스터 등록 | Apple ID | Google 계정 or 이메일만 |
| 심사 | 첫 빌드는 간단 심사 | **심사 없음**, 업로드 즉시 배포 |
| 설치 | TestFlight 앱 | 이메일 링크 → "Firebase App Tester" 앱(최초 1회) → APK 자동 설치 |
| 스토어 계정 필요 | Apple Developer ($99/년) | **불필요** |

## 사전 준비 (완료됨)

- Firebase 프로젝트 `dottie-46886`에 Android 앱 등록 완료 (`android/app/google-services.json` 존재).
- Firebase CLI 로그인 완료 (`firebase projects:list`로 확인 가능).
- Android App ID: `1:417852363208:android:ec053a0c0de7ca7409b0fd`
- `.env`에 `MAPBOX_ACCESS_TOKEN`, `KAKAO_NATIVE_APP_KEY` 존재 — Makefile이 자동으로 읽어서 주입.

## Makefile 타겟

`Makefile`에 iOS `build-ipa`와 동일한 패턴으로 추가됨:

```makefile
## Firebase App Distribution 용 APK 빌드
build-apk:
	flutter build apk \
		--release \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

## Firebase App Distribution 으로 테스터 배포
distribute-android: build-apk
	firebase appdistribution:distribute \
		build/app/outputs/flutter-apk/app-release.apk \
		--app 1:417852363208:android:ec053a0c0de7ca7409b0fd \
		--testers "$(TESTERS)" \
		--release-notes "$(NOTES)"

## Firebase App Distribution 에 업로드만 (테스터 미지정 — 콘솔에서 나중에 추가)
upload-android: build-apk
	firebase appdistribution:distribute \
		build/app/outputs/flutter-apk/app-release.apk \
		--app 1:417852363208:android:ec053a0c0de7ca7409b0fd \
		--release-notes "$(NOTES)"
```

## 이메일 없이 먼저 업로드 후 콘솔에서 테스터 추가

CLI에서 `--testers`/`--groups`를 생략하면 초대 메일 없이 릴리스만 App Distribution에 올라간다.

```bash
make upload-android NOTES="첫 빌드"
```

이후:
1. [Firebase 콘솔](https://console.firebase.google.com) → `dottie` 프로젝트 → 좌측 메뉴 **App Distribution**
2. 방금 업로드된 릴리스가 목록에 보임 (버전/빌드 번호로 식별)
3. 그 릴리스를 열어 **테스터 추가**(Add testers) → 이메일 입력 또는 그룹 선택
4. **이 시점에** 입력한 이메일로 초대 메일이 발송됨 — 업로드 시점이 아니라 테스터를 추가하는 순간에 나감

## 실행 방법 (이메일을 바로 지정해 배포하는 경우)

프로젝트 루트에서:

```bash
make distribute-android TESTERS="tester1@gmail.com,tester2@gmail.com" NOTES="첫 테스트 빌드입니다"
```

이 한 줄이 하는 일:
1. `flutter build apk --release`로 릴리스 APK 빌드 (1~3분 소요)
2. Firebase App Distribution에 업로드
3. `TESTERS`에 적은 이메일로 초대 메일 발송 (심사 없이 즉시)

APK만 빌드하고 배포는 나중에 하려면 `make build-apk`만 실행.

## 테스터가 받는 경험

1. 초대 이메일(`firebase.google.com` 발송) 수신 → "테스트에 초대되었습니다" 링크 클릭
2. Google 계정으로 로그인 (초대받은 이메일 계정이면 됨, 별도 가입 불필요)
3. 최초 1회: "Firebase App Tester" 앱 설치 안내 → 설치
4. App Tester 앱 안에서 Dottie 최신 빌드 다운로드 → 설치
   - 안드로이드가 "출처를 알 수 없는 앱" 경고를 띄우면 → 설정에서 허용 (App Tester 앱에 대해서만 1회 허용하면 됨)
5. 이후 새 빌드를 배포하면 App Tester 앱에 알림이 오고, 테스터는 앱을 열어 업데이트 버튼만 누르면 됨 (TestFlight와 거의 동일한 흐름)

## 테스터 관리 (그룹, 초대 취소 등)

Firebase 콘솔 → 프로젝트 `dottie` → **App Distribution** 탭에서 GUI로도 가능. 매번 이메일을 직접 타이핑하기 번거로우면 콘솔에서 그룹(예: `internal-testers`)을 만들어 두고 `--groups internal-testers`로 배포 가능.

## 알아둘 점 — Play 스토어 정식 출시 전 필수 작업

현재 `android/app/build.gradle.kts`의 release 빌드는 **디버그 키로 서명**되고 있음:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

App Distribution 테스트 단계에서는 문제없지만, **Play 스토어에 실제 출시할 때는 반드시 release 서명 키를 별도로 생성해 교체**해야 함. (`keytool`로 keystore 생성 → `key.properties` → `signingConfigs.create("release")`로 교체하는 표준 Flutter 안드로이드 릴리스 서명 절차.)

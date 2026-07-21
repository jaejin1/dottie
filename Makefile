MAPBOX_TOKEN   ?= $(shell grep MAPBOX_ACCESS_TOKEN .env | cut -d'=' -f2)
KAKAO_KEY      ?= $(shell grep KAKAO_NATIVE_APP_KEY .env | cut -d'=' -f2)
DEVICE_ID      ?= $(shell grep DEVICE_ID .env | cut -d'=' -f2)
# App Store Connect API — https://appstoreconnect.apple.com → 사용자 및 액세스 → 통합 → API 키
# .p8 파일은 ~/private_keys/AuthKey_<KEY_ID>.p8 에 저장
ASC_KEY_ID     ?= $(shell grep ASC_KEY_ID .env | cut -d'=' -f2)
ASC_ISSUER_ID  ?= $(shell grep ASC_ISSUER_ID .env | cut -d'=' -f2)
# Firebase Android App ID (Firebase 콘솔 → 앱 설정 → 일반 → 앱 ID)
FIREBASE_APP_ID ?= 1:417852363208:android:ec053a0c0de7ca7409b0fd

.PHONY: run run-debug \
        build-ipa upload-ios distribute-ios \
        build-apk build-aab \
        distribute-android upload-android \
        gen

# ──────────────────────────────────────────────────
# 로컬 실행
# ──────────────────────────────────────────────────

## 실기기 직접 배포 (release)
run:
	flutter run \
		-d $(DEVICE_ID) \
		--release \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

## 디버그 실행 (debugPrint 로그 노출 — 애플 로그인 등 디버깅용)
run-debug:
	flutter run \
		-d $(DEVICE_ID) \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

# ──────────────────────────────────────────────────
# iOS — TestFlight
# ──────────────────────────────────────────────────

# 난독화 심볼 저장 위치 — 크래시 스택트레이스 해독(flutter symbolize)에 필요.
SYMBOLS := build/debug-symbols

## IPA 빌드 (난독화)
build-ipa:
	flutter build ipa \
		--release \
		--obfuscate --split-debug-info=$(SYMBOLS) \
		--dart-define=ENV=prod \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

## TestFlight 업로드 (IPA 이미 빌드된 상태에서 단독 실행 가능)
## 사전 조건: .env에 ASC_KEY_ID, ASC_ISSUER_ID 설정
##            ~/private_keys/AuthKey_<ASC_KEY_ID>.p8 파일 존재
upload-ios:
	@if [ -z "$(ASC_KEY_ID)" ] || [ -z "$(ASC_ISSUER_ID)" ]; then \
		echo "❌ .env에 ASC_KEY_ID, ASC_ISSUER_ID 를 추가해주세요"; exit 1; fi
	xcrun altool --upload-app \
		-f build/ios/ipa/dottie.ipa \
		-t ios \
		--apiKey $(ASC_KEY_ID) \
		--apiIssuer $(ASC_ISSUER_ID) \
		--verbose

## IPA 빌드 + TestFlight 업로드 (원스텝)
distribute-ios: build-ipa upload-ios

# ──────────────────────────────────────────────────
# Android — Firebase App Distribution
# ──────────────────────────────────────────────────

## Firebase App Distribution 용 APK 빌드 (난독화)
build-apk:
	flutter build apk \
		--release \
		--obfuscate --split-debug-info=$(SYMBOLS) \
		--dart-define=ENV=prod \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

## Google Play 용 AAB 빌드 (난독화)
build-aab:
	flutter build appbundle \
		--release \
		--obfuscate --split-debug-info=$(SYMBOLS) \
		--dart-define=ENV=prod \
		--dart-define=MAPBOX_ACCESS_TOKEN=$(MAPBOX_TOKEN) \
		--dart-define=API_URL=https://app.dottie.today/v1 \
		--dart-define=KAKAO_NATIVE_APP_KEY=$(KAKAO_KEY)

## Firebase App Distribution 으로 테스터 배포 (TESTERS="a@x.com,b@x.com" make distribute-android)
distribute-android: build-apk
	firebase appdistribution:distribute \
		build/app/outputs/flutter-apk/app-release.apk \
		--app $(FIREBASE_APP_ID) \
		--testers "$(TESTERS)" \
		--release-notes "$(NOTES)"

## Firebase App Distribution 에 업로드만 (테스터 미지정 — 콘솔에서 나중에 추가)
upload-android: build-apk
	firebase appdistribution:distribute \
		build/app/outputs/flutter-apk/app-release.apk \
		--app $(FIREBASE_APP_ID) \
		--release-notes "$(NOTES)"

# ──────────────────────────────────────────────────
# 코드 생성
# ──────────────────────────────────────────────────

## freezed / riverpod / drift 변경 후 코드 재생성
gen:
	dart run build_runner build --delete-conflicting-outputs

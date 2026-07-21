# BE 작업 요청 — 코스 경로 캐시 API

> FE는 현재 Mapbox Directions 를 직접 호출하도록 구현 완료 (동작 중).
> 아래 엔드포인트가 생기면 `lib/features/todo/data/route_remote_source.dart` 의
> `fetchDayRoute` 내부만 교체하면 됨. 응답 스펙만 맞으면 FE 수정 최소화.

## 배경

스팟 지도에 "day 별 색상 + 실제 도로를 따라가는 경로 라인" 기능 추가됨.
- 지금: FE → Mapbox Directions API 직접 호출 (public 토큰, 월 10만 건 무료)
- BE 캐시 도입 시 장점: 멤버 간 경로 공유(같은 코스를 보는 N명이 각자 계산 안 함),
  중복 계산 제거, FE 의 외부 API 의존 축소

## 엔드포인트

```
GET /v1/todo-lists/:id/route?day_index=0
```

- 인증: 멤버 권한 (owner/member/viewer 모두 조회 가능 — resolveListMember)
- `day_index`: 0부터. 컬렉션(비여행) 코스는 0 고정.

### 응답

```json
200 → {
  "data": {
    "day_index": 0,
    "profile": "walking",
    "distance_m": 5321,
    "duration_s": 4120,
    "geometry": {
      "type": "LineString",
      "coordinates": [[126.9780, 37.5665], [126.9791, 37.5670]]
    }
  }
}
```

- `profile`: `"walking"` | `"driving"`
- `geometry.coordinates`: **[lng, lat] 순서** (GeoJSON 표준)
- 스팟 2개 미만 → `{ "data": null }`
- Mapbox 호출 실패 → 502 대신 `{ "data": null }` 권장 (FE 가 직선 폴백 처리)

## 구현 가이드

### 1. 좌표 목록 구성

해당 day 의 todo_items 를 `order_in_day` ASC 정렬 → (lat, lng) 목록.
Directions API waypoint 상한이 **25개**이므로 초과 시 앞 25개만 사용.

### 2. 프로필 휴리스틱 (FE 와 동일 규칙)

인접 좌표 간 haversine 거리가 **전부 2,500m 이하 → `walking`**, 하나라도 초과 → `driving`.

### 3. Mapbox Directions 호출

```
GET https://api.mapbox.com/directions/v5/mapbox/{profile}/{lng},{lat};{lng},{lat}...
    ?geometries=geojson&overview=full&access_token={MAPBOX_ACCESS_TOKEN}
```

- 토큰: fly secrets 에 이미 있는 `MAPBOX_ACCESS_TOKEN` 사용
- 응답에서 `routes[0].geometry` (GeoJSON LineString), `routes[0].distance`(m),
  `routes[0].duration`(s) 추출

### 4. 캐시 테이블 (마이그레이션 000020 제안)

```sql
CREATE TABLE todo_route_cache (
    todo_list_id UUID NOT NULL REFERENCES todo_lists(id) ON DELETE CASCADE,
    day_index    INT NOT NULL,
    items_hash   TEXT NOT NULL,      -- 정렬된 "lat,lng" 목록의 sha256
    profile      VARCHAR(10) NOT NULL,
    distance_m   INT NOT NULL,
    duration_s   INT NOT NULL,
    geometry     JSONB NOT NULL,
    computed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (todo_list_id, day_index)
);
```

### 5. 캐시 로직

1. 요청 시 해당 day 의 items 로 `items_hash` 계산
2. 캐시 row 존재 + hash 일치 → 캐시 반환 (Mapbox 호출 없음)
3. 불일치/미존재 → Mapbox 호출 → upsert 후 반환

스팟 추가/수정/삭제/순서변경 시 hash 가 자연히 바뀌므로 **별도 무효화 훅 불필요**.

### 6. 에러 처리

| 상황 | 응답 |
|------|------|
| 리스트 없음 | 404 `TODO_LIST_NOT_FOUND` |
| 비멤버 | 403 `FORBIDDEN` |
| 스팟 < 2개 | 200 `{ "data": null }` |
| Mapbox 실패 (타임아웃/4xx/5xx) | 200 `{ "data": null }` — FE 직선 폴백 |

## FE 참고 (교체 지점)

- `lib/features/todo/data/route_remote_source.dart` → `fetchDayRoute()` 내부를
  `GET /v1/todo-lists/:id/route?day_index=N` 호출로 교체
- 반환 모델 `DayRoute { coordinates([[lng,lat]]), distanceM, durationS, profile }` 그대로 유지
- 이때는 앱 공용 ApiClient(Authorization 인터셉터 포함) 사용으로 전환

## 비용 참고

- Mapbox Directions: 월 100,000건 무료, 초과 시 $2/1,000건
- 캐시 도입 시 코스 저장/수정당 1회 수준이라 사실상 무료 구간을 벗어날 일 없음

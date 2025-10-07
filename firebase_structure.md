# 🧱 Firebase Firestore 스키마 — Koofy Sichuan (사천성)

---

## 👤 Collection: `users`

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `uid` | string | Firebase Auth 사용자 고유 ID | `"8aYtL3sd..."` |
| `nickname` | string | 사용자 표시명 | `"라온"` |
| `email` | string | 로그인한 이메일 (게스트는 placeholder) | `"guest@koofy.games"` |
| `login_type` | string | `"google"` / `"guest"` | `"google"` |
| `created_at` | timestamp | 가입 시각 | `"2025-10-07T13:00:00Z"` |
| `last_login` | timestamp | 마지막 로그인 시각 | `"2025-10-07T14:21:10Z"` |
| `gold` | int | 보유 골드 | `1500` |
| `gems` | int | 보유 보석 | `12` |
| `hearts` | int | 하트 수 (에너지 개념) | `4` |
| `hints` | int | 힌트 아이템 개수 | `3` |
| `bombs` | int | 폭탄 아이템 개수 | `2` |
| `shuffle` | int | 섞기 아이템 개수 | `2` |
| `current_stage` | int | 현재 클리어 스테이지 번호 | `8` |

> 🔹 이메일은 사용자가 입력하지 않고, **Firebase Auth 자동 제공**  
> 🔹 게스트 로그인은 `guest@koofy.games` 으로 저장  

---

## 🧩 Collection: `records` (랭킹/기록)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `uid` | string | 사용자 ID (users.uid 참조) | `"8aYtL3sd..."` |
| `stage_id` | string | 플레이한 스테이지 ID | `"stage_10"` |
| `clear_time` | int | 클리어 시간 (초 단위) | `85` |
| `mistake_count` | int | 틀린 횟수 | `2` |
| `hint_used` | int | 힌트 사용 횟수 | `1` |
| `bomb_used` | int | 폭탄 사용 횟수 | `0` |
| `shuffle_used` | int | 섞기 사용 횟수 | `1` |
| `score` | int | 최종 점수 | `920` |
| `rank` | int | 랭킹 순위 | `7` |
| `created_at` | timestamp | 기록 저장 시각 | `"2025-10-07T14:32:00Z"` |

---

## 🗺️ Collection: `stages`

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `stage_id` | string | 스테이지 ID | `"stage_10"` |
| `difficulty` | string | `"easy"`, `"normal"`, `"hard"` | `"normal"` |
| `layer_count` | int | 단 수 (층 수) | `2` |
| `tile_rows` | int | 가로 칸 수 | `10` |
| `tile_cols` | int | 세로 칸 수 | `14` |
| `orientation` | string | `"portrait"` | `"portrait"` |
| `tile_set` | string | `"fruit"`, `"animal"`, `"mahjong"` | `"fruit"` |
| `initial_map` | map / json | 초기 타일 배열 정의 (optional) | `{ "0,0": "apple", "0,1": "pear" }` |
| `obstacles` | array | 장애물 좌표 | `[{"x":4,"y":2}, {"x":7,"y":8}]` |
| `flipped_tiles` | array | 뒤집힌 타일 좌표 | `[{"x":1,"y":2}]` |
| `created_at` | timestamp | 등록 시각 | `"2025-10-07T13:00:00Z"` |

> 🔹 세로형 기본 구조: **10 × 14**, `orientation = "portrait"`  
> 🔹 가로형 확장 시 `"landscape"` 로 추가 가능  

---

## 🏪 Collection: `shop_items`

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `item_id` | string | 아이템 ID | `"char_fox"` |
| `category` | string | `"character"`, `"tile"`, `"background"` | `"character"` |
| `name` | string | 아이템명 | `"여우 캐릭터"` |
| `description` | string | 설명 | `"기뻐하며 꼬리를 흔드는 여우"` |
| `price_gold` | int | 골드 가격 | `1000` |
| `price_gem` | int | 보석 가격 | `2` |
| `image_url` | string | Firebase Storage URL | `"https://firebasestorage..."` |
| `rarity` | string | `"normal"`, `"rare"`, `"epic"` | `"rare"` |
| `animation_type` | string | `"happy"`, `"sad"`, `"thinking"` | `"happy"` |
| `created_at` | timestamp | 등록 시각 | `"2025-10-07T13:00:00Z"` |

---

## ⚙️ Collection: `settings_global`

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `latest_version` | string | 최신 앱 버전 | `"1.0.0+10"` |
| `maintenance_mode` | bool | 점검 여부 | `false` |
| `notice_message` | string | 공지 내용 | `"새로운 캐릭터 업데이트!"` |
| `ad_reward_config` | map | 광고 보상 설정 | `{ "gold": 100, "gems": 1 }` |

---

## 🔗 관계 요약

- `users.uid` ↔ `records.uid` : 1:N  
- `records.stage_id` ↔ `stages.stage_id` : 1:N  
- `users.uid` ↔ `user_items.uid` : 1:N  
- `user_items.item_id` ↔ `shop_items.item_id` : N:1  

---

## 📊 인덱스 권장

| 인덱스 | 목적 |
|---------|------|
| `records (stage_id, score DESC)` | 스테이지별 랭킹 조회 |
| `users (gold DESC)` | 상위 보유자 조회 |
| `records (uid, stage_id)` | 유저별 진행도 조회 |
| `user_items (uid, category)` | 유저별 아이템 카테고리 조회 |
| `user_items (uid, equipped)` | 착용 중인 아이템 빠른 조회 |

---

## 🎒 Collection: `user_items` (유저 보유 아이템)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `uid` | string | 사용자 UID (`users.uid` 참조) | `"8aYtL3sd..."` |
| `item_id` | string | 상점 아이템 ID (`shop_items.item_id` 참조) | `"char_fox"` |
| `category` | string | `"character"`, `"tile"`, `"background"` | `"character"` |
| `owned_at` | timestamp | 구매 또는 획득 시간 | `"2025-10-07T13:20:00Z"` |
| `equipped` | bool | 현재 장착 여부 | `true` |
| `source` | string | `"shop"`, `"reward"`, `"event"` | `"shop"` |
| `upgrade_level` | int | 강화/진화 단계 (옵션) | `1` |

> 🔹 Firestore 구조 예시  
> ```
> users/
>  └── 8aYtL3sd.../
>       └── user_items/
>            ├── char_fox/
>            │    ├── category: "character"
>            │    ├── equipped: true
>            │    └── owned_at: 2025-10-07T13:20:00Z
>            └── bg_forest/
>                 ├── category: "background"
>                 ├── equipped: false
>                 └── owned_at: 2025-10-07T13:30:00Z
> ```
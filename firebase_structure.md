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
| `energy` | int | 플레이에 필요한 에너지 수 (기본 7개, 10분마다 1개 자동 충전) | `4` |
| `energy_last_refill` | timestamp | 마지막 충전 계산 기준 시각 | `"2025-10-07T13:00:00Z"` |
| `energy_max` | int | 최대 에너지 제한 | `7` |
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
| `difficulty` | string | 난이도 (`easy`, `normal`, `hard`) | `"easy"` |
| `clear_time` | int | 클리어 시간 (초 단위) | `85` |
| `mistake_count` | int | 틀린 횟수 | `2` |
| `hint_used` | int | 힌트 사용 횟수 | `1` |
| `bomb_used` | int | 폭탄 사용 횟수 | `0` |
| `shuffle_used` | int | 섞기 사용 횟수 | `1` |
| `score` | int | 최종 점수 | `920` |
| `rank` | int | 랭킹 순위 | `7` |
| `created_at` | timestamp | 기록 저장 시각 | `"2025-10-07T14:32:00Z"` |

> stage_id + difficulty 조합으로 유니크 관리됨. 예: stage_03 + easy 클리어 시 stage_03 + normal 해금.

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
| `unlock_condition` | map | 다음 난이도 해금 조건 | `{ "difficulty": "normal", "requires_clear": "easy" }` |

> 🔹 세로형 기본 구조: **10 × 14**, `orientation = "portrait"`  
> 🔹 가로형 확장 시 `"landscape"` 로 추가 가능  
> 🔹 각 stage 문서는 여러 난이도 변형을 포함할 수 있으며, `unlock_condition` 필드로 난이도별 해금 조건을 별도로 관리함.

---

## 🌟 Collection: stage_rewards (스테이지별 별 조건 정의)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `stage_id` | string | 스테이지 ID | `"stage_10"` |
| `difficulty` | string | 난이도 | `"easy"` |
| `star_level` | int | 별 단계 | `1` |
| `condition_type` | string | `"time"`, `"mistake"`, `"combo"`, `"item_used"` | `"time"` |
| `condition_value` | int | 조건 값 (예: 90초 이내 클리어) | `90` |
| `reward_type` | string | `"gold"`, `"gems"`, `"item"` | `"gold"` |
| `reward_value` | int | 보상 수량 | `100` |
| `description` | string | 조건 설명 | `"90초 이내 클리어 시 보상 획득"` |
| `created_at` | timestamp | 등록 시각 | `"2025-10-07T14:00:00Z"` |

> 🔹 각 스테이지와 난이도별로 별 조건과 보상 정보를 정의하며, 조건 변경이나 이벤트 적용이 유연함.

---

## 🏅 Collection: user_stage_rewards (유저별 별 달성 / 보상 수령 상태)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `uid` | string | 사용자 ID | `"8aYtL3sd..."` |
| `stage_id` | string | 스테이지 ID | `"stage_10"` |
| `difficulty` | string | 난이도 | `"easy"` |
| `star_level` | int | 별 단계 | `2` |
| `achieved` | bool | 조건 충족 여부 | `true` |
| `reward_claimed` | bool | 보상 수령 여부 | `false` |
| `achieved_at` | timestamp | 달성 시각 | `"2025-10-07T15:00:00Z"` |

> 🔹 각 별 조건별 달성 상태와 보상 수령 여부를 관리하며, `achieved=true && reward_claimed=false` 인 항목이 실제 보상 대상임.

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
| `ad_reward_config` | map | 광고 보상 설정 | `{ "gold": 100, "gems": 1, "energy": 5 }` |

> 🔹 광고 시청에 따른 에너지 충전 보상 설정  

---

## 🔗 관계 요약

- `users.uid` ↔ `records.uid` : 1:N  
- `records.stage_id` ↔ `stages.stage_id` : 1:N  
- `users.uid` ↔ `user_items.uid` : 1:N  
- `user_items.item_id` ↔ `shop_items.item_id` : N:1  
- `stage_rewards.stage_id` ↔ `stages.stage_id` : 1:N  
- `user_stage_rewards.stage_id` ↔ `stage_rewards.stage_id` : 1:N  

---

## 📊 인덱스 권장

| 인덱스 | 목적 |
|---------|------|
| `records (stage_id, difficulty, score DESC)` | 난이도별 랭킹 조회 |
| `users (gold DESC)` | 상위 보유자 조회 |
| `records (uid, stage_id, difficulty)` | 유저별 진행도 조회 |
| `user_items (uid, category)` | 유저별 아이템 카테고리 조회 |
| `user_items (uid, equipped)` | 착용 중인 아이템 빠른 조회 |
| `user_stage_rewards (uid, stage_id, difficulty)` | 유저별 보상 상태 조회 |
| `stage_rewards (stage_id, difficulty, star_level)` | 스테이지별 보상 조건 조회 |

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

---

## ⚡ Collection: energy_transactions (에너지 충전 로그)

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `uid` | string | 사용자 UID | `"8aYtL3sd..."` |
| `type` | string | `"auto"`, `"ad"`, `"gem"` | `"ad"` |
| `amount` | int | 충전량 | `5` |
| `created_at` | timestamp | 충전 발생 시각 | `"2025-10-07T14:00:00Z"` |



# 🗓️ Collection: attendance_events (출석체크 이벤트 정의)

7일 출석 이벤트의 기본 구조를 정의하는 컬렉션입니다. 각 이벤트는 고유의 ID와 제목, 총 출석 일수, 반복 여부, 기간, 보상 정보 등을 포함합니다.

| 필드명       | 타입     | 설명                         | 예시                                   |
|--------------|----------|------------------------------|----------------------------------------|
| `event_id`   | string   | 이벤트 고유 ID               | `"attend_2025_10"`                     |
| `title`      | string   | 이벤트 제목                  | `"10월 출석체크 이벤트"`                |
| `total_days` | int      | 총 출석 일수 (기본 7일)      | `7`                                    |
| `repeatable` | bool     | 반복 가능 여부               | `true`                                 |
| `start_date` | timestamp| 이벤트 시작 날짜             | `"2025-10-01T00:00:00Z"`               |
| `end_date`   | timestamp| 이벤트 종료 날짜             | `"2025-10-31T23:59:59Z"`               |
| `rewards`    | map      | 각 일차별 보상 정보          | `{ "1": {"gold": 100}, "7": {"gems": 5} }` |
| `created_at` | timestamp| 등록 시각                   | `"2025-09-30T12:00:00Z"`               |
| `active`     | bool     | 현재 활성화 여부             | `true`                                 |

> 🔹 7일 누적 출석 기준이며, `repeatable=true` 인 경우 이벤트 기간 내 재참여 가능  
> 🔹 `rewards` 필드는 각 일차별 보상 종류와 수량을 정의함  

---

# 🙋 Collection: user_attendance (유저별 출석 상태)

사용자별 출석 현황과 보상 수령 상태를 관리하는 컬렉션입니다. 7일 누적 출석을 기준으로 하며, 광고 시청 시 2배 보상 수령 기능도 포함합니다.

| 필드명           | 타입       | 설명                                  | 예시                                   |
|------------------|------------|-------------------------------------|----------------------------------------|
| `uid`            | string     | 사용자 UID (`users.uid` 참조)         | `"8aYtL3sd..."`                        |
| `event_id`       | string     | 출석 이벤트 ID (`attendance_events.event_id` 참조) | `"attend_2025_10"`                     |
| `total_checked`  | int        | 누적 출석 일수                       | `3`                                    |
| `last_check_date`| timestamp  | 마지막 출석 날짜                     | `"2025-10-03T00:00:00Z"`               |
| `rewards_status` | map        | 각 일차별 보상 수령 및 광고 2배 여부 상태 | See JSON example below                 |
| `completed`      | bool       | 출석 이벤트 완료 여부                | `false`                                |
| `restart_count`  | int        | 이벤트 재참여 횟수                   | `1`                                    |
| `created_at`     | timestamp  | 최초 생성 시각                      | `"2025-10-01T09:00:00Z"`               |
| `updated_at`     | timestamp  | 마지막 업데이트 시각                | `"2025-10-03T10:00:00Z"`               |

> 🔹 7일 누적 출석 방식으로, 중간에 출석하지 않아도 누적 일수는 유지되나 보상 수령은 출석한 날에만 가능  
> 🔹 광고 시청 시 `reward_multiplier` 가 2배로 설정되어 추가 보상 수령 가능  
> 🔹 `completed=true` 이면 이벤트 모든 일차 출석 완료 상태  

---

### 🔗 관계 요약

- `attendance_events.event_id` ↔ `user_attendance.event_id` : 1:N  
- `user_attendance.uid` ↔ `users.uid` : 1:N  

---

### rewards_status JSON 예시

```json
{
  "1": { "checked": true, "rewarded": true, "reward_multiplier": 1 },
  "2": { "checked": true, "rewarded": false, "reward_multiplier": 2 },
  "3": { "checked": false, "rewarded": false, "reward_multiplier": 1 },
  "4": { "checked": false, "rewarded": false, "reward_multiplier": 1 },
  "5": { "checked": false, "rewarded": false, "reward_multiplier": 1 },
  "6": { "checked": false, "rewarded": false, "reward_multiplier": 1 },
  "7": { "checked": false, "rewarded": false, "reward_multiplier": 1 }
}
```

> - `checked`: 해당 일차 출석 여부  
> - `rewarded`: 보상 수령 완료 여부  
> - `reward_multiplier`: 광고 시청에 따른 보상 배수 (기본 1, 광고 시 2)  
>  
> 버튼 활성화/비활성화 UX 참고:  
> - 출석하지 않은 날은 출석 버튼 활성화  
> - 출석했으나 보상 미수령 시 보상 수령 버튼 활성화  
> - 보상 수령 완료 시 버튼 비활성화  
> - 광고 시청 후 2배 보상 수령 시 보상 수령 버튼 활성화 (단, 중복 수령 불가)

---

# 🧠 아이템 효과 기반 구조 (착용 아이템별 능력 부여형)

아이템의 효과를 유저가 착용한 상태에서 실시간으로 게임 플레이에 반영하기 위한 구조입니다. Firestore에 저장된 아이템 데이터와 유저의 착용 상태를 기반으로, 별도의 캐시 컬렉션을 두어 빠른 효과 조회와 적용을 지원합니다.

---

## 🏪 Collection: shop_items (아이템 기본 정보)

| 필드명          | 타입   | 설명                      | 예시                      |
|-----------------|--------|---------------------------|---------------------------|
| `item_id`       | string | 아이템 고유 ID            | `"char_fox"`              |
| `category`      | string | `"character"`, `"tile"`, `"background"` 등 | `"character"`             |
| `name`          | string | 아이템명                  | `"여우 캐릭터"`           |
| `description`   | string | 아이템 설명               | `"기뻐하며 꼬리를 흔드는 여우"` |
| `price_gold`    | int    | 골드 가격                 | `1000`                    |
| `price_gem`     | int    | 보석 가격                 | `2`                       |
| `image_url`     | string | 이미지 URL                | `"https://firebasestorage..."` |
| `rarity`        | string | `"normal"`, `"rare"`, `"epic"` | `"rare"`                  |
| `animation_type`| string | `"happy"`, `"sad"`, `"thinking"` | `"happy"`                 |
| `effects`       | map    | 아이템 효과 정의 (키-값 쌍) | `{ "energy_bonus": 2, "gold_bonus": 10 }` |
| `created_at`    | timestamp | 등록 시각               | `"2025-10-07T13:00:00Z"` |

> - `effects` 필드는 해당 아이템이 부여하는 능력치나 특수 효과를 키-값 쌍으로 정의함.  
> - 예: `"energy_bonus": 2` 는 최대 에너지 +2 증가 효과.

---

## 🎒 Collection: user_items (유저별 아이템 보유 및 착용 상태)

| 필드명          | 타입   | 설명                      | 예시                      |
|-----------------|--------|---------------------------|---------------------------|
| `uid`           | string | 사용자 UID (`users.uid` 참조) | `"8aYtL3sd..."`          |
| `item_id`       | string | 아이템 ID (`shop_items.item_id` 참조) | `"char_fox"`            |
| `category`      | string | `"character"`, `"tile"`, `"background"` 등 | `"character"`           |
| `owned_at`      | timestamp | 구매 또는 획득 시각      | `"2025-10-07T13:20:00Z"` |
| `equipped`      | bool   | 현재 착용 여부            | `true`                    |
| `source`        | string | `"shop"`, `"reward"`, `"event"` | `"shop"`                 |
| `upgrade_level` | int    | 강화/진화 단계 (옵션)     | `1`                       |

---

## ⚡ Collection: user_effects_cache (유저별 착용 아이템 효과 캐시)

| 필드명          | 타입   | 설명                      | 예시                      |
|-----------------|--------|---------------------------|---------------------------|
| `uid`           | string | 사용자 UID (`users.uid` 참조) | `"8aYtL3sd..."`          |
| `effects`       | map    | 착용 중인 아이템들의 총 합산 효과 | `{ "energy_bonus": 3, "gold_bonus": 15 }` |
| `updated_at`    | timestamp | 최종 업데이트 시각      | `"2025-10-07T14:00:00Z"` |

> - 유저가 아이템을 착용하거나 해제할 때마다 `user_effects_cache` 문서가 갱신됨.  
> - 게임 플레이 중 빠른 효과 조회를 위해 별도 캐시로 관리.

---

## 🎮 Collection: game_sessions (게임 플레이 세션 기록)

| 필드명          | 타입   | 설명                      | 예시                      |
|-----------------|--------|---------------------------|---------------------------|
| `session_id`    | string | 세션 고유 ID              | `"sess_20251007_1234"`    |
| `uid`           | string | 사용자 UID                | `"8aYtL3sd..."`           |
| `stage_id`      | string | 플레이한 스테이지 ID      | `"stage_10"`              |
| `difficulty`    | string | 난이도                    | `"easy"`                  |
| `start_time`    | timestamp | 시작 시각               | `"2025-10-07T14:00:00Z"` |
| `end_time`      | timestamp | 종료 시각               | `"2025-10-07T14:10:00Z"` |
| `used_items`    | array  | 세션 중 사용한 아이템 ID 리스트 | `["char_fox", "bg_forest"]` |
| `effects_applied` | map  | 세션 중 적용된 효과 요약 | `{ "energy_bonus": 2 }`   |
| `score`         | int    | 최종 점수                 | `950`                     |

---

## UX 예시: 아이템 착용과 효과 반영 흐름

1. 유저가 게임 내에서 아이템을 착용/해제한다.  
2. `user_items` 컬렉션 내 해당 아이템 문서의 `equipped` 필드가 변경된다.  
3. 백엔드 또는 클라우드 함수가 트리거되어 `user_effects_cache` 문서의 `effects` 필드를 재계산하여 업데이트한다.  
4. 게임 클라이언트는 `user_effects_cache` 문서를 구독하여 실시간으로 효과 변화를 반영한다.  
5. 게임 플레이 중 `game_sessions` 문서에 해당 세션의 아이템 사용 및 효과 적용 내역이 기록된다.

---

## 🔗 관계 요약

| 관계 | 설명 |
|-------|------|
| `shop_items.item_id` ↔ `user_items.item_id` | 1:N (아이템 기본 정보 ↔ 유저 보유 아이템) |
| `users.uid` ↔ `user_items.uid` | 1:N (유저 ↔ 보유 아이템) |
| `users.uid` ↔ `user_effects_cache.uid` | 1:1 (유저 ↔ 착용 아이템 효과 캐시) |
| `users.uid` ↔ `game_sessions.uid` | 1:N (유저 ↔ 게임 플레이 세션) |

---

이 구조는 아이템 효과를 효율적으로 관리하고, 게임 내에서 실시간으로 반영할 수 있도록 설계되었습니다. Firestore의 트랜잭션 및 클라우드 함수와 연동하여 데이터 일관성과 빠른 반응성을 보장합니다.
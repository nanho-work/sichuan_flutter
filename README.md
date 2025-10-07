# sichuan_flutter# 🀄 Koofy Sichuan (쿠피 사천성)

Flutter 기반으로 개발된 짝맞추기 퍼즐 게임 **“쿠피 사천성”** 입니다.  
전통적인 사천성 룰을 기반으로 하되,  
현대적인 UI / 랭킹 시스템 / 상점 기능을 결합한 모바일 퍼즐 게임입니다.  

---

## 🎮 주요 특징

### 🔹 게임 시스템
- **가로형 퍼즐 구조 (14 × 10 기본 보드)**
- **로컬 저장 기반** (인터넷 연결 없이 플레이 가능)
- **다층(2~3단) 보드 지원 예정**
- **시간 제한, 힌트, 폭탄, 섞기 등 다양한 아이템**
- **에너지 하트(최대 4개) 시스템**

### 🔹 전역 관리
- 전역 설정 (언어, 사운드, 테마, 난이도)
- SharedPreferences 기반 로컬 저장
- Flame + Provider 조합으로 상태 관리

### 🔹 아이템 시스템
| 아이템 | 설명 | 기본 제공 | 구매 방식 |
|---------|-------|-------------|-------------|
| 💡 힌트 | 연결 가능한 블록을 깜빡임으로 표시 | 3개 | 골드 구매 |
| 💣 폭탄 | 같은 그림의 블록을 직접 터치로 제거 | 2개 | 골드 구매 |
| 🔄 섞기 | 전체 블록을 랜덤 재배치 | 2회 | 골드 구매 |

---

## 🏪 상점 시스템

| 분류 | 설명 | 구매 수단 |
|------|------|------------|
| 🎭 캐릭터 | 플레이 중 반응(기쁨/슬픔/고민 등) 애니메이션 | 골드 / 보석 |
| 🧩 블럭 스킨 | 과일 / 동물 / 마작 스타일 등 테마별 블럭 | 골드 / 보석 |
| 🌄 배경 | 게임 배경 이미지 커스터마이징 | 골드 / 보석 |

- **골드:** 스테이지 클리어 또는 광고 보상으로 획득  
- **보석:** 스테이지 보상 또는 인앱 구매로 획득  

---

## 🏆 랭킹 시스템 (Firebase 기반)

Firebase Firestore를 이용하여 랭킹과 클리어 기록을 관리합니다.  

| 항목 | 설명 |
|------|------|
| 스테이지 | 스테이지 번호 (Stage ID) |
| 아이디 | Google / Guest 로그인 기반 사용자 |
| 클리어 시간 | 초 단위 클리어 기록 |
| 틀린 횟수 | 잘못된 매칭 시도 횟수 |
| 힌트 사용 횟수 | 힌트 아이템 사용 횟수 |
| 폭탄 사용 횟수 | 폭탄 아이템 사용 횟수 |
| 섞기 사용 횟수 | 되돌리기(Shuffle) 아이템 사용 횟수 |

- Google 로그인 / 게스트 로그인 지원  
- 오프라인 기록은 로컬에 저장 후 온라인 시 자동 동기화  

---

## ☁️ Firebase 구조

| 컬렉션 | 설명 |
|---------|------|
| `users` | 유저 기본 정보 (닉네임, 재화, 아이템 수량 등) |
| `records` | 스테이지별 클리어 기록 및 랭킹 정보 |
| `stages` | 각 스테이지의 난이도, 레이아웃, 장애물 정보 |
| `shop_items` | 상점 품목 정의 (캐릭터, 블럭, 배경 등) |
| `purchases` | 유저 구매 내역 저장 |

---

## 🧠 향후 업데이트 예정
- 친구 초대 / 친구 랭킹 기능  
- 리얼타임 대전 (타임어택 모드)  
- 시즌별 한정 테마 블럭  
- 플레이 데이터 클라우드 백업  

---

## ⚙️ 개발 환경

| 항목 | 버전 |
|------|------|
| Flutter SDK | 3.9.2 |
| Dart SDK | 3.9.x |
| Flame | ^1.32.0 |
| Flame Audio | ^2.11.10 |
| Google Mobile Ads | ^6.0.0 |
| Shared Preferences | ^2.5.3 |
| Provider | ^6.1.5+1 |
| Firebase (Firestore/Auth) | 최신 안정 버전 |

---

## 🚀 실행 방법

```bash
# 1. 프로젝트 클론
git clone https://github.com/choenamho/sichuan_flutter.git
cd sichuan_flutter

# 2. 의존성 설치
flutter pub get

# 3. 실행 (디바이스 연결 후)
flutter run

lib/
 ├─ main.dart
 ├─ config/
 │   ├─ localization_manager.dart
 │   ├─ settings_manager.dart
 │   └─ constants.dart
 ├─ storage/
 │   └─ local_storage.dart
 ├─ audio/
 │   └─ audio_manager.dart
 ├─ controllers/
 │   ├─ game_controller.dart
 │   ├─ board_controller.dart
 │   └─ ...
 ├─ ui/
 │   ├─ home_screen.dart
 │   ├─ game_screen.dart
 │   └─ result_screen.dart
 └─ game/
     ├─ sichuan_game.dart
     ├─ tile_model.dart
     └─ board_manager.dart

🧩 라이선스

본 프로젝트는 개인 개발용/연습용으로 제작되었으며,
상업적 배포 전에는 반드시 라이선스 정책을 확인해야 합니다.

⸻

👤 Author

NamHo (LaonCode / Koofy Games)
	•	GitHub: @choenamho
	•	Brand: Koofy Games
	•	Email: laoncode.dev@gmail.com


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
- `users` ↔ `shop_items` : 구매 이력 확장 가능 (`purchases` 컬렉션)

---

## 📊 인덱스 권장

| 인덱스 | 목적 |
|---------|------|
| `records (stage_id, score DESC)` | 스테이지별 랭킹 조회 |
| `users (gold DESC)` | 상위 보유자 조회 |
| `records (uid, stage_id)` | 유저별 진행도 조회 |

---
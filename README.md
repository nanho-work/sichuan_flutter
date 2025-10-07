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



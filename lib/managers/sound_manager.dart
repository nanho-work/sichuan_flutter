import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  double bgmVolume = 0.5;
  double sfxVolume = 0.7;
  bool bgmMuted = false;
  bool sfxMuted = false;
  bool _isPlaying = false;
  String? _currentBgm; // ✅ 현재 재생 중인 BGM 파일 이름 저장

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    bgmVolume = prefs.getDouble('bgmVolume') ?? 0.5;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
    bgmMuted = prefs.getBool('bgmMuted') ?? false;
    sfxMuted = prefs.getBool('sfxMuted') ?? false;

    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bgmVolume', bgmVolume);
    await prefs.setDouble('sfxVolume', sfxVolume);
    await prefs.setBool('bgmMuted', bgmMuted);
    await prefs.setBool('sfxMuted', sfxMuted);
  }

  Future<void> playBGM(String fileName) async {
    if (bgmMuted) return;
    if (_isPlaying && _currentBgm == fileName) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(
        AssetSource('sounds/bgm/$fileName'),
        volume: bgmVolume,
      );
      _isPlaying = true;
      _currentBgm = fileName; // ✅ 현재 재생 중인 파일 저장
    } catch (e) {
      print("BGM 재생 오류: $e");
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
    _isPlaying = false;
  }

  Future<void> pauseBGM() async {
    try {
      await _bgmPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print("BGM 일시정지 오류: $e");
    }
  }

  Future<void> resumeBGM() async {
    try {
      if (!bgmMuted) {
        await _bgmPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      print("BGM 재개 오류: $e");
    }
  }

  Future<void> playSFX(String fileName) async {
    if (sfxMuted || sfxVolume <= 0) return;

    final sfxPlayer = AudioPlayer();
    try {
      sfxPlayer.onPlayerComplete.listen((_) => sfxPlayer.dispose());
      await sfxPlayer.play(
        AssetSource('sounds/sfx/$fileName'),
        volume: sfxVolume,
      );
    } catch (e) {
      print("SFX 재생 오류: $e");
      sfxPlayer.dispose();
    }
  }

  void setBgmVolume(double volume) {
    bgmVolume = volume;
    if (_isPlaying && !bgmMuted) {
      _bgmPlayer.setVolume(volume);
    }
    saveSettings();
  }

  void setSfxVolume(double volume) {
    sfxVolume = volume;
    saveSettings();
  }

  void toggleBgmMute(bool muted) {
    bgmMuted = muted;
    if (muted) {
      stopBGM(); // 🔇 완전 정지
    } else {
      // 🔊 음소거 해제 시 자동 복원
      if (_currentBgm != null) {
        playBGM(_currentBgm!);
      } else {
        playBGM('home_theme.mp3');
      }
    }
    saveSettings();
  }

  void toggleSfxMute(bool muted) {
    sfxMuted = muted;
    saveSettings();
  }

  bool get isPlayingBGM => _isPlaying;
}
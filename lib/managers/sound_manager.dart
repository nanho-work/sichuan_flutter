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

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    bgmVolume = prefs.getDouble('bgmVolume') ?? 0.5;
    sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
    bgmMuted = prefs.getBool('bgmMuted') ?? false;
    sfxMuted = prefs.getBool('sfxMuted') ?? false;
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
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(
        AssetSource('sounds/bgm/$fileName'),
        volume: bgmVolume,
      );
    } catch (e) {
      print("BGM 재생 오류: $e");
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  Future<void> pauseBGM() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      print("BGM 일시정지 오류: $e");
    }
  }

  Future<void> resumeBGM() async {
    try {
      if (!bgmMuted) {
        await _bgmPlayer.resume();
      }
    } catch (e) {
      print("BGM 재개 오류: $e");
    }
  }

  Future<void> playSFX(String fileName) async {
    if (sfxMuted) return;
    try {
      final sfxPlayer = AudioPlayer();
      await sfxPlayer.play(AssetSource('sounds/sfx/$fileName'), volume: sfxVolume);
    } catch (e) {
      print("SFX 재생 오류: $e");
    }
  }

  void setBgmVolume(double volume) {
    bgmVolume = volume;
    _bgmPlayer.setVolume(volume);
    saveSettings();
  }

  void setSfxVolume(double volume) {
    sfxVolume = volume;
    saveSettings();
  }

  void toggleBgmMute(bool muted) {
    bgmMuted = muted;
    if (muted) {
      _bgmPlayer.setVolume(0);
    } else {
      _bgmPlayer.setVolume(bgmVolume);
    }
    saveSettings();
  }

  void toggleSfxMute(bool muted) {
    sfxMuted = muted;
    saveSettings();
  }
}
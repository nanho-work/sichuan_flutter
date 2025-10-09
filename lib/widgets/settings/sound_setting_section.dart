import 'package:flutter/material.dart';
import '../../managers/sound_manager.dart';
import '../../ui/sound/volume_slider.dart';
import '../../ui/sound/toggle_switch.dart';
import '../../ui/sound/section_title.dart';

class SoundSettingSection extends StatefulWidget {
  const SoundSettingSection({super.key});

  @override
  State<SoundSettingSection> createState() => _SoundSettingSectionState();
}

class _SoundSettingSectionState extends State<SoundSettingSection> {
  final sound = SoundManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('🎵 사운드'),
        _buildSoundRow(
          '배경음',
          sound.bgmVolume,
          sound.bgmMuted,
          (v) => setState(() => sound.setBgmVolume(v)),
          (v) => setState(() => sound.toggleBgmMute(v)),
        ),
        _buildSoundRow(
          '효과음',
          sound.sfxVolume,
          sound.sfxMuted,
          (v) => setState(() => sound.setSfxVolume(v)),
          (v) => setState(() => sound.toggleSfxMute(v)),
        ),
      ],
    );
  }

  Widget _buildSoundRow(
    String title,
    double volume,
    bool muted,
    ValueChanged<double> onVolumeChanged,
    ValueChanged<bool> onMutedChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title)),
            ToggleSwitch(value: muted, onChanged: onMutedChanged),
          ],
        ),
        VolumeSlider(
          value: volume,
          disabled: muted,
          onChanged: onVolumeChanged,
        ),
      ],
    );
  }
}
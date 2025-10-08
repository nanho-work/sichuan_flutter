import 'package:flutter/material.dart';
import 'sound_setting_section.dart';
import 'language_setting_section.dart';
import 'policy_setting_section.dart';

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const SettingsDialog(),
  );
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SoundSettingSection(),
            Divider(),
            LanguageSettingSection(),
            Divider(),
            PolicySettingSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
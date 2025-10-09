import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ui/sound/section_title.dart';

class LanguageSettingSection extends StatefulWidget {
  const LanguageSettingSection({super.key});

  @override
  State<LanguageSettingSection> createState() => _LanguageSettingSectionState();
}

class _LanguageSettingSectionState extends State<LanguageSettingSection> {
  String selectedLang = 'ko';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => selectedLang = prefs.getString('selectedLang') ?? 'ko');
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLang', lang);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('🌐 언어'),
        _langRadio('한국어', 'ko'),
        _langRadio('English', 'en'),
        _langRadio('日本語', 'ja'),
        _langRadio('中文', 'zh'),
      ],
    );
  }

  Widget _langRadio(String label, String code) {
    return RadioListTile<String>(
      title: Text(label),
      value: code,
      groupValue: selectedLang,
      onChanged: (v) {
        setState(() => selectedLang = v!);
        _saveLanguage(v!);
      },
    );
  }
}
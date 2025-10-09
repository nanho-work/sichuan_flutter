import 'package:flutter/material.dart';
import '../../ui/sound/section_title.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicySettingSection extends StatelessWidget {
  const PolicySettingSection({super.key});

  Future<void> _openWeb(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Failed to launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('📄 약관 및 정책'),
        ListTile(
          title: const Text('이용약관 보기'),
          onTap: () => _openWeb('https://www.koofy.co.kr/privacy'),
        ),
        ListTile(
          title: const Text('개인정보처리방침'),
          onTap: () => _openWeb('https://www.koofy.co.kr/privacy'),
        ),
      ],
    );
  }
}
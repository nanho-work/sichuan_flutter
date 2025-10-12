import 'package:flutter/material.dart';

class GameNavigation extends StatelessWidget {
  const GameNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _navBtn(Icons.lightbulb_outline, '힌트', onTap: (){}),
          _navBtn(Icons.bubble_chart, '폭탄', onTap: (){}),
          _navBtn(Icons.shuffle, '셔플', onTap: (){}),
          const Spacer(),
          _navBtn(Icons.exit_to_app, '나가기', onTap: (){
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle()),
          ],
        ),
      ),
    );
  }
}
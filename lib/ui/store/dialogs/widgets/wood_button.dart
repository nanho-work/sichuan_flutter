import 'package:flutter/material.dart';
import '../../../../managers/image_manager.dart';

class WoodButton extends StatelessWidget {
  const WoodButton({super.key, required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ButtonType.wood.assetPath),
            fit: BoxFit.fill,
            onError: (_, __) {},
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
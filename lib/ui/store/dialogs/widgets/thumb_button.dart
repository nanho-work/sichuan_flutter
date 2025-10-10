import 'package:flutter/material.dart';

class ThumbButton extends StatelessWidget {
  const ThumbButton({super.key, required this.image, required this.onTap});
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: image.isNotEmpty ? Image.asset(image, fit: BoxFit.cover) : const SizedBox.shrink(),
      ),
    );
  }
}
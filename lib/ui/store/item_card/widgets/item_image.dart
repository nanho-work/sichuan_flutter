import 'package:flutter/material.dart';

/// 공통 이미지 표시용 컴포넌트
class ItemImage extends StatelessWidget {
  const ItemImage({super.key, required this.imgPath, this.fit = BoxFit.contain});
  final String imgPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imgPath.isNotEmpty
          ? Image.asset(imgPath, fit: fit)
          : Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Text('No Image',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
    );
  }
}
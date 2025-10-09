import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double value;
  final bool disabled;
  final ValueChanged<double> onChanged;

  const VolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 1,
        activeColor: Colors.blueAccent,
        inactiveColor: Colors.grey.shade300,
        onChanged: disabled ? null : onChanged,
      ),
    );
  }
}
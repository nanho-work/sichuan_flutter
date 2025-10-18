import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/tile_model.dart';
import '../../core/game_engine.dart';
import 'dart:async';

class GameTile extends StatefulWidget {
  final Tile tile;
  final bool selected;

  const GameTile({super.key, required this.tile, required this.selected});

  @override
  _GameTileState createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  bool _isBlinking = false;
  double _opacity = 1.0;
  Timer? _timer;

  void _triggerBlink() {
    if (_isBlinking) return;
    _isBlinking = true;
    int toggleCount = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        _opacity = _opacity == 1.0 ? 0.2 : 1.0;
      });
      toggleCount++;
      if (toggleCount >= 4) {
        timer.cancel();
        _isBlinking = false;
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final engine = gp.engine;
    final isActive = engine.isTopmostTile(widget.tile); // ✅ 클릭 가능 여부 확인

    final baseColor = widget.tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade700.withOpacity(0.9);
    final activeColor = widget.tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade700.withOpacity(0.9);
    final inactiveColor = widget.tile.cleared
        ? Colors.transparent
        : Colors.blueGrey.shade900.withOpacity(0.4);

    final color = widget.selected
        ? Colors.blueGrey.shade700.withOpacity(1.0)
        : (isActive ? activeColor : inactiveColor);

    final isError = gp.lastResultType == MatchResultType.wrong && widget.selected;
    if (isError && !_isBlinking) {
      _triggerBlink();
    }

    final border = widget.selected
        ? Border.all(color: Colors.amberAccent, width: 2)
        : (isActive
            ? Border.all(color: Colors.white24, width: 1)
            : Border.all(color: Colors.transparent, width: 0));

    final borderToUse = isError
        ? Border.all(color: Colors.redAccent, width: 2)
        : border;

    final scale = widget.selected ? 1.08 : 1.0;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: isError ? 0.2 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: borderToUse,
            ),
            alignment: Alignment.center,
            child: widget.tile.cleared
                ? const SizedBox.shrink()
                : Opacity(
                    opacity: isActive ? 1.0 : 0.5,
                    child: widget.tile.imagePath != null
                        ? Transform.scale(
                            scale: 1.06,
                            child: Image.asset(
                              widget.tile.imagePath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Text(
                            widget.tile.type,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
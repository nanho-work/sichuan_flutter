import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../managers/image_manager.dart';
import '../../../providers/inventory_provider.dart';
import 'widgets/effect_grid.dart';
import 'widgets/thumb_button.dart';
import 'widgets/wood_button.dart';
import 'widgets/outlined_button.dart';

class CharacterDetailDialog extends StatefulWidget {
  const CharacterDetailDialog({super.key, required this.item});
  final dynamic item;

  @override
  State<CharacterDetailDialog> createState() => _CharacterDetailDialogState();
}

class _CharacterDetailDialogState extends State<CharacterDetailDialog>
    with SingleTickerProviderStateMixin {
  int _previewIndex = 0;
  late AnimationController _animController;

  List<dynamic> get _levels => (widget.item.levels as List?) ?? [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _animController.reverse(); // 🔄 축소 후 닫기
    if (mounted) Navigator.of(context).pop();
  }

  String _imageAt(int i) {
    if (_levels.isEmpty) return '';
    final lv = _levels[i.clamp(0, _levels.length - 1)];
    if (lv is Map) return (lv['image_path'] as String?) ?? '';
    return (lv.imagePath as String?) ?? '';
  }

  ItemEffects _effectsAt(int i) {
    if (_levels.isEmpty) return const ItemEffects();
    final lv = _levels[i.clamp(0, _levels.length - 1)];
    if (lv is Map) {
      return ItemEffects.fromMap(lv['effects'] as Map<String, dynamic>?);
    } else if (lv is ItemLevel) {
      return lv.effects;
    } else {
      return const ItemEffects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.item.name ?? '';
    final desc = widget.item.description ?? '';
    final price = widget.item.price ?? 0;
    final currency = (widget.item.currency is ItemCurrency)
        ? (widget.item.currency as ItemCurrency).name
        : 'free';
    final imageMain = _imageAt(_previewIndex);
    final effects = _effectsAt(_previewIndex);

    return WillPopScope(
      onWillPop: () async {
        await _closeDialog();
        return false;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInBack,
              ),
            ).value;

            final opacity = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.easeIn,
                reverseCurve: Curves.easeOut,
              ),
            ).value;

            return Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FB),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Row(
                    children: [
                      ThumbButton(
                        image: _imageAt((_previewIndex - 1).clamp(0, _levels.length - 1)),
                        onTap: () => setState(() =>
                            _previewIndex = (_previewIndex - 1).clamp(0, _levels.length - 1)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageMain.isNotEmpty
                              ? Image.asset(imageMain, fit: BoxFit.contain)
                              : Container(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ThumbButton(
                        image: _imageAt((_previewIndex + 1).clamp(0, _levels.length - 1)),
                        onTap: () => setState(() =>
                            _previewIndex = (_previewIndex + 1).clamp(0, _levels.length - 1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                EffectGrid(effects: effects),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _PurchaseButton(
                        item: widget.item,
                        price: price,
                        currency: currency,
                        closeDialog: _closeDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedDialogButton(
                        label: '닫기',
                        onTap: _closeDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatefulWidget {
  final dynamic item;
  final int price;
  final String currency;
  final Future<void> Function() closeDialog;
  const _PurchaseButton({
    required this.item,
    required this.price,
    required this.currency,
    required this.closeDialog,
  });

  @override
  State<_PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<_PurchaseButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final isOwned = inventory.hasItem(widget.item.id);
    if (_isLoading) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    if (isOwned) {
      return Opacity(
        opacity: 0.6,
        child: IgnorePointer(
          ignoring: true,
          child: WoodButton(
            onTap: () {},
            child: const Text("보유중", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
    return WoodButton(
      onTap: () async {
        setState(() => _isLoading = true);
        try {
          final message = await context.read<InventoryProvider>().purchaseItem(widget.item);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );

            if (message.contains("완료")) {
              await widget.closeDialog();
            }
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.price > 0)
            (widget.currency == 'gold')
                ? ImageManager.instance.getCurrencyIcon(CurrencyType.gold, size: 24)
                : ImageManager.instance.getCurrencyIcon(CurrencyType.gem, size: 24),
          Text(widget.price > 0 ? '  ${widget.price}' : '무료 획득',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
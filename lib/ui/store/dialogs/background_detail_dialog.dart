import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../managers/image_manager.dart';
import 'widgets/wood_button.dart';
import 'widgets/outlined_button.dart';

class BackgroundDetailDialog extends StatefulWidget {
  const BackgroundDetailDialog({super.key, required this.item});
  final dynamic item;

  @override
  State<BackgroundDetailDialog> createState() => _BackgroundDetailDialogState();
}

class _BackgroundDetailDialogState extends State<BackgroundDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

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
    await _animController.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final desc = widget.item.description ?? '';
    final price = widget.item.price ?? 0;
    final currency = (widget.item.currency is ItemCurrency)
        ? (widget.item.currency as ItemCurrency).name
        : 'free';

    return WillPopScope(
      onWillPop: () async {
        await _closeDialog();
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
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
                Text(widget.item.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.item.images?.isNotEmpty ?? false)
                        ? Image.asset(widget.item.images!.first, fit: BoxFit.cover)
                        : Container(color: Colors.black12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WoodButton(
                        onTap: () async {
                          await context.read<ItemProvider>().purchaseItem(widget.item);
                          await _closeDialog();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (price > 0)
                              (currency == 'gold')
                                  ? ImageManager.instance.getCurrencyIcon(CurrencyType.gold, size: 24)
                                  : ImageManager.instance.getCurrencyIcon(CurrencyType.gem, size: 24),
                            Text(price > 0 ? '  $price' : '무료 획득',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/app_notifier.dart';
import '../../../managers/image_manager.dart';
import '../../../providers/inventory_provider.dart';
import 'widgets/wood_button.dart';
import 'widgets/outlined_button.dart';
import '../../../models/item_model.dart';

class BlocksetDetailDialog extends StatefulWidget {
  const BlocksetDetailDialog({super.key, required this.item});
  final dynamic item;

  @override
  State<BlocksetDetailDialog> createState() => _BlocksetDetailDialogState();
}

class _BlocksetDetailDialogState extends State<BlocksetDetailDialog>
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
                SizedBox(
                  height: 160,
                  child: GridView.count(
                    crossAxisCount: 5,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: (widget.item.images ?? [])
                        .map<Widget>((img) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(img, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _PurchaseButton(
                        item: widget.item,
                        price: price,
                        currency: currency,
                        onPurchased: _closeDialog,
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
  const _PurchaseButton({
    required this.item,
    required this.price,
    required this.currency,
    required this.onPurchased,
  });

  final dynamic item;
  final int price;
  final String currency;
  final Future<void> Function() onPurchased;

  @override
  State<_PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<_PurchaseButton> {
  bool _isLoading = false;

  bool get _isOwned {
    final inventory = context.read<InventoryProvider>().inventory;
    if (widget.price == 0) return false;
    return inventory.any((invItem) => invItem.itemId == widget.item.id);
  }

  Future<void> _handlePurchase() async {
    if (_isOwned) {
      AppNotifier.showInfo(context, '이미 보유중인 아이템입니다.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await context.read<InventoryProvider>().purchaseItem(widget.item);
      if (mounted) {
        AppNotifier.showSuccess(context, '구매가 완료되었습니다.');
        await widget.onPurchased();
      }
    } catch (e) {
      if (mounted) {
        AppNotifier.showError(context, '구매 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            if (message.contains("완료")) {
              AppNotifier.showSuccess(context, message);
              await widget.onPurchased();
            } else {
              AppNotifier.showInfo(context, message);
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
          Text(
            widget.price > 0 ? '  ${widget.price}' : '무료 획득',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
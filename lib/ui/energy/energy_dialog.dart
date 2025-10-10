import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../managers/image_manager.dart';
import '../../ads/ad_rewarded.dart';

class EnergyDialog extends StatelessWidget {
  const EnergyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool isFull = user.energy >= user.energyMax;
    final gems = user.gems;
    final bool adLimitReached = user.adLimitReached;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ImageManager.instance.getDialogBackground(DialogType.energy).image,
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 33, 50, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/koofy_carrot_refill.png',
                width: 100,
                height: 120,
              ),
              const SizedBox(height: 8),
              _EnergyButtons(isFull: isFull, gems: gems, adLimitReached: adLimitReached),
              const SizedBox(height: 12),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageManager.instance.getCurrencyIcon(CurrencyType.energy, size: 28),
        const SizedBox(width: 8),
        const Text(
          "충전",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 1.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
        ),
        child: const Text(
          "닫기",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EnergyButtons extends StatefulWidget {
  final bool isFull;
  final int gems;
  final bool adLimitReached;

  const _EnergyButtons({required this.isFull, required this.gems, required this.adLimitReached});

  @override
  State<_EnergyButtons> createState() => _EnergyButtonsState();
}

class _EnergyButtonsState extends State<_EnergyButtons> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final adButtonDisabled = widget.isFull || widget.adLimitReached || _isProcessing;
    final gemButtonDisabled = widget.isFull || widget.gems < 10 || _isProcessing;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildButton(
                context,
                label: "+5 당근",
                icon: 'assets/images/koofy_watch_ad.png',
                disabled: adButtonDisabled,
                onPressed: _onWatchAd,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildButton(
                context,
                label: "+5 당근",
                icon: 'assets/images/koofy_gem_offer.png',
                disabled: gemButtonDisabled,
                onPressed: _onUseGems,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.isFull
                    ? "에너지가 이미 가득 찼습니다."
                    : widget.adLimitReached
                        ? "오늘 광고 시청 횟수를 모두 사용했습니다."
                        : "",
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isFull
                    ? "에너지가 이미 가득 찼습니다."
                    : widget.gems < 10
                        ? "젬이 부족합니다."
                        : "",
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onWatchAd() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final userProvider = context.read<UserProvider>();

    AdRewardedService.showRewardedAd(
      onReward: () async {
        try {
          await userProvider.restoreEnergyViaAd();
          if (mounted) {
            _showSnack("광고 보상으로 에너지가 +5 충전되었습니다.");
          }
        } catch (e) {
          if (mounted) {
            _showSnack(e.toString().replaceAll('Exception: ', ''));
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      },
      onFail: () {
        if (mounted) {
          _showSnack("광고를 불러오지 못했습니다.");
          setState(() => _isProcessing = false);
        }
      },
    );
  }

  Future<void> _onUseGems() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final userProvider = context.read<UserProvider>();

    try {
      await userProvider.restoreEnergyViaGem(10);
      _showSnack("젬 10개로 에너지를 +5 충전했습니다.");
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildButton(
      BuildContext context, {
        required String label,
        required String icon,
        required VoidCallback onPressed,
        bool disabled = false,
      }) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ImageManager.instance.getButtonImage(ButtonType.wood).image,
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 40, height: 40),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
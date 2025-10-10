import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/energy_service.dart';
import '../../ads/ad_rewarded.dart';
import '../../managers/image_manager.dart';

class EnergyDialog extends StatefulWidget {
  const EnergyDialog({super.key});

  @override
  State<EnergyDialog> createState() => _EnergyDialogState();
}

class _EnergyDialogState extends State<EnergyDialog> {
  final user = FirebaseAuth.instance.currentUser!;
  final energyService = EnergyService();

  int _energy = 0;
  int _energyMax = 0;
  int _gems = 0;
  DateTime? _lastRefill;

  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserEnergy();
  }

  Future<void> _loadUserEnergy() async {
    await energyService.autoRecharge(user.uid);
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data()!;
    setState(() {
      _energy = data['energy'];
      _energyMax = data['energy_max'];
      _gems = data['gems'];
      _lastRefill = (data['energy_last_refill'] as Timestamp).toDate();
      _isLoading = false;
    });
  }

  // ⏱ 다음 자동충전까지 남은 시간 계산
  String get _nextRechargeText {
    if (_energy >= _energyMax || _lastRefill == null) return "충전 완료";
    final elapsed = DateTime.now().difference(_lastRefill!);
    final remain = 10 - (elapsed.inMinutes % 10);
    return "$remain분 후 +1";
  }

  // 🎁 광고로 에너지 충전
  Future<void> _onWatchAd() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    AdRewardedService.showRewardedAd(
      onReward: () async {
        await context.read<UserProvider>().restoreEnergyViaAd();
        await _loadUserEnergy();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("광고 보상으로 에너지가 +5 충전되었습니다.")),
          );
        }
      },
      onFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("광고를 불러오지 못했습니다.")),
        );
      },
    );

    setState(() => _isProcessing = false);
  }

  // 💎 젬으로 에너지 충전
  Future<void> _onUseGems() async {
    if (_isProcessing) return;
    if (_gems < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("젬이 부족합니다.")),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await context.read<UserProvider>().restoreEnergyViaGem(10);
      await _loadUserEnergy();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("젬 10개로 에너지를 +5 충전했습니다.")),
        );
      }
    } catch (e) {
      print("젬 충전 오류: $e");
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minHeight: 400, maxHeight: 600),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageManager.instance.getCurrencyIcon(CurrencyType.energy, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "충전",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),


            Image.asset(
              'assets/images/koofy_carrot_refill.png',
              width: 100,
              height: 120,
              fit: BoxFit.contain,
            ),

            // (에너지 상태 및 다음 충전까지 표시 영역 삭제됨)

 
           
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _onWatchAd,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ImageManager.instance.getButtonImage(ButtonType.wood).image,
                              fit: BoxFit.fill,
                            ),
                          ),
                          alignment: Alignment.center,
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/koofy_watch_ad.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                "+5 당근",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "광고 충전",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _onUseGems,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ImageManager.instance.getButtonImage(ButtonType.wood).image,
                              fit: BoxFit.fill,
                            ),
                          ),
                          alignment: Alignment.center,
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/koofy_gem_offer.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                "+5 당근",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "루비 충전",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // 닫기 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: const Text(
                  "닫기",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
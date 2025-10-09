import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sichuan_flutter/ui/profiles/account_dialog.dart';
import 'package:sichuan_flutter/managers/image_manager.dart';
import '../../providers/user_provider.dart';
import '../ui/energy/energy_header.dart'; // ✅ 추가

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});


  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserProvider>().user;

    if (userModel == null) {
      return _loadingHeader();
    }

    final profileImage = 'char_default';
    final gems = userModel.gems;
    final gold = userModel.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [

          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 프로필 + 에너지
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AccountDialog(),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image(
                            image: ImageManager.instance
                                .getImageProvider(itemId: profileImage),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const EnergyHeader(),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // 오른쪽: 보석/골드
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _currencyIconText(CurrencyType.gem, gems.toString()),
                      const SizedBox(width: 12),
                      _currencyIconText(CurrencyType.gold, gold.toString()),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget _currencyIconText(CurrencyType type, String value) {
    return Row(
      children: [
        ImageManager.instance.getCurrencyIcon(type, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/member_dashboard_controller.dart';
import '../../../routes/app_routes.dart';
import 'tabs/history_view.dart';
import 'tabs/growth_view.dart';
import 'tabs/settings_view.dart';

class MemberDashboardView extends GetView<MemberDashboardController> {
  const MemberDashboardView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static Color getBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F6);
  static Color getTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: SafeArea(
        child: Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildHomeContent(context),
            const HistoryView(),
            const GrowthView(),
            const SettingsView(),
          ],
        )),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildGreeting(context),
          _buildRedCard(),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          _buildAnalisisGrafik(context),
          _buildSimpananList(context),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
                  border: Border.all(color: themeColor.withAlpha(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.account_balance, color: themeColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'KOPERASI SIMPANAN HARKAT',
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.NOTIFIKASI),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : themeColor, 
                size: 24
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'selamat_datang'.tr,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38,
              letterSpacing: 1.5,
            ),
          ),
          Obx(() => Text(
            controller.dynamicGreeting,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRedCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8A1515), Color(0xFF4A0808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(Icons.account_balance_wallet, size: 160, color: Colors.white.withAlpha(13)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Obx(() => Text(
                        controller.userName.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      )),
                      Icon(Icons.credit_card, color: Colors.white.withAlpha(128), size: 20),
                    ],
                  ),
                const SizedBox(height: 16),
                Text(
                  'total_simpanan'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.formatCurrency(controller.totalBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                )),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('PLATINUM MEMBER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    Obx(() => Text('ID: ${controller.memberId}', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionItem(
              context,
              Icons.add_circle_outline, 
              'buka_simpanan'.tr,
              onTap: () => Get.toNamed(Routes.BUKA_SIMPANAN),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionItem(
              context,
              Icons.money_off_csred_outlined, 
              'pengajuan_penarikan'.tr,
              onTap: () => Get.toNamed(Routes.PENARIKAN),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withAlpha(13)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(25) : const Color(0xFFFFF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpananList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'simpanan_saya'.tr,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w900, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => _buildSimpananItem(context, Icons.account_balance_wallet_outlined, 'simpanan_sukarela'.tr, controller.formatCurrency(controller.getBalanceByType('Simpanan Sukarela')))),
          const SizedBox(height: 12),
          Obx(() => _buildSimpananItem(context, Icons.account_balance, 'simpanan_pokok'.tr, controller.formatCurrency(controller.getBalanceByType('Simpanan Pokok')))),
          const SizedBox(height: 12),
          Obx(() => _buildSimpananItem(context, Icons.savings_outlined, 'simpanan_wajib'.tr, controller.formatCurrency(controller.getBalanceByType('Simpanan Wajib')))),
        ],
      ),
    );
  }

  Widget _buildSimpananItem(BuildContext context, IconData icon, String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(13)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(25) : const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black45)),
                const SizedBox(height: 4),
                Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: themeColor)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildAnalisisGrafik(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'analisis_grafik'.tr,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w900, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor,
                ),
              ),
              TextButton(
                onPressed: () => controller.changeTabIndex(2),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'lihat_detail'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withAlpha(13)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: themeColor.withAlpha(128)),
                const SizedBox(height: 8),
                Text(
                  'grafik_pertumbuhan'.tr,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54, fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Obx(() => Container(
      height: 80,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: themeColor.withAlpha(77), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'home'.tr, controller.currentIndex.value == 0, () => controller.changeTabIndex(0)),
          _buildNavItem(Icons.history, 'history'.tr, controller.currentIndex.value == 1, () => controller.changeTabIndex(1)),
          _buildNavItem(Icons.analytics_outlined, 'growth'.tr, controller.currentIndex.value == 2, () => controller.changeTabIndex(2)),
          _buildNavItem(Icons.settings_outlined, 'settings'.tr, controller.currentIndex.value == 3, () => controller.changeTabIndex(3)),
        ],
      ),
    ));
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withAlpha(51) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_dashboard_controller.dart';
import 'dart:io';
import '../../../../modules/dashboard_status/controllers/dashboard_status_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static Color getBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 24),
            Text(
              'pengaturan'.tr,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: themeColor),
            ),
            Text(
              'kelola_akun'.tr,
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle(context, 'profile'.tr),
                  _buildProfileCard(context),
            const SizedBox(height: 12),
            _buildVerifiedEmail(context),
            
            const SizedBox(height: 32),
        _buildSectionTitle(context, 'security'.tr),
        _buildSettingItem(
          context, 
          Icons.lock_outline, 
          'ubah_sandi'.tr, 
          'terakhir_diubah'.tr, 
          hasChevron: true,
          onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
        ),
        Obx(() => _buildSettingItem(
          context,
          Icons.dark_mode_outlined, 
          'mode_gelap'.tr, 
          'sesuaikan_mata'.tr, 
          hasToggle: true, 
          toggleValue: controller.isDarkMode.value,
          onToggle: (v) => controller.toggleTheme(v),
        )),
        _buildSettingItem(
          context, 
          Icons.translate, 
          'bahasa'.tr, 
          Get.locale?.languageCode == 'id' ? 'Bahasa Indonesia' : 'English', 
          hasChevron: true,
          onTap: () => _showLanguageDialog(context, controller),
        ),
        
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'notifikasi'.tr),
        _buildNotificationItem(context, Icons.account_balance_wallet_outlined, 'update_saldo'.tr, 'notif_saldo'.tr, true),
        _buildNotificationItem(context, Icons.campaign_outlined, 'promosi'.tr, 'notif_promosi'.tr, true),
            
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'tentang'.tr),
            _buildAboutItem(context, 'versi'.tr, 'v2.4.0-gold'),
            _buildAboutItem(context, 'layanan'.tr, null, isLink: true),
            _buildAboutItem(context, 'privasi'.tr, null, isLink: true),
            
            const SizedBox(height: 40),
            _buildLogoutButtons(context),
            
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'KOPERASI SIMPANAN HARKAT © 2024',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
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
                border: Border.all(color: themeColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : themeColor, 
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.w900, 
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38, 
          letterSpacing: 1.5
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final box = GetStorage();
    DashboardStatusController? ds;
    try {
      if (Get.isRegistered<DashboardStatusController>()) ds = Get.find<DashboardStatusController>();
    } catch (_) {}
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PROFILE),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Obx(() {
              final _ = Get.find<MemberDashboardController>().count.value; // Prevent Obx crash if ds is null
              final avatarPath = ds?.userAvatarPath.value ?? box.read('userAvatarPath') ?? '';
              if (avatarPath.isNotEmpty) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(avatarPath), 
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 60, color: Colors.grey),
                  ),
                );
              }
              final name = ds?.userName.value ?? box.read('userName') ?? 'Budi Santoso';
              final encoded = Uri.encodeComponent(name);
              final url = 'https://ui-avatars.com/api/?name=$encoded&background=6B0D0D&color=fff';
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url, 
                  width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 60, color: Colors.grey),
                ),
              );
            }),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final _ = Get.find<MemberDashboardController>().count.value; // Prevent Obx crash
                    final name = ds?.userName.value ?? box.read('userName') ?? 'Budi Santoso';
                    return Text(
                      name, 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 4),
                  Builder(builder: (context) {
                    final id = box.read('memberId') ?? '#KS-B8291';
                    return Text(
                      'ID Anggota: $id', 
                      style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedEmail(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline, size: 18, color: Colors.black38),
          const SizedBox(width: 12),
          Expanded(
            child: Builder(builder: (context) {
              final email = GetStorage().read('userEmail') ?? 'budi.santoso@email.com';
              return Text(
                email, 
                style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.orange.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: const Text('Terverifikasi', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, {bool hasChevron = false, bool hasToggle = false, bool toggleValue = false, Function(bool)? onToggle, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withAlpha(5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: themeColor.withAlpha(13), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: themeColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38)),
                ],
              ),
            ),
            if (hasChevron) const Icon(Icons.chevron_right, color: Colors.black12),
            if (hasToggle) Switch(
              value: toggleValue, 
              onChanged: onToggle, 
              activeThumbColor: themeColor
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, IconData icon, String title, String desc, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87))),
              Switch(value: value, onChanged: (v) {}, activeThumbColor: themeColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAboutItem(BuildContext context, String title, String? value, {bool isLink = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withAlpha(13))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
          if (value != null) Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38)),
          if (isLink) const Icon(Icons.open_in_new, size: 16, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildLogoutButtons(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_remove_outlined, size: 18),
          label: Text('keluar_anggota'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: themeColor,
            side: const BorderSide(color: themeColor),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => Get.find<MemberDashboardController>().logout(),
          icon: const Icon(Icons.logout, size: 18),
          label: Text('keluar_akun'.tr),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, MemberDashboardController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'pilih_bahasa'.tr,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageItem(context, 'Bahasa Indonesia', 'id', 'ID', controller),
            const SizedBox(height: 12),
            _buildLanguageItem(context, 'English', 'en', 'US', controller),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text('batal'.tr, style: const TextStyle(color: Colors.black38)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String title, String langCode, String countryCode, MemberDashboardController controller) {
    bool isSelected = Get.locale?.languageCode == langCode;
    return GestureDetector(
      onTap: () {
        controller.changeLanguage(langCode, countryCode);
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? themeColor : Colors.black.withAlpha(13)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87
              )
            ),
            if (isSelected) const Icon(Icons.check_circle, color: themeColor, size: 20),
          ],
        ),
      ),
    );
  }
}

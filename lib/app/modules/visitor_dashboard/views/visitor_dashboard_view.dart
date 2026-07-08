import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/visitor_dashboard_controller.dart';

class VisitorDashboardView extends GetView<VisitorDashboardController> {
  const VisitorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memaksa GetX untuk menginisialisasi controller
    final _ = controller;
    
    final themeColor = Color(0xFF6B0D0D);
    final bgColor = Color(0xFFFFF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildHeroSection(themeColor),
              _buildFeaturesSection(themeColor),
              _buildGrowthSimulation(themeColor),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.DAFTAR_ANGGOTA),
        backgroundColor: themeColor,
        label: Row(
          children: [
            Text(
              'daftar_menjadi_anggota'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B0D0D), size: 20),
                onPressed: () => Get.offAllNamed(Routes.LOGIN),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logo_koperasi.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text(
                'KOPERASI SIMPANKU',
                style: TextStyle(
                  color: Color(0xFF6B0D0D),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Icon(Icons.language, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'visitor_hero_title'.tr,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: themeColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'visitor_hero_desc'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/hero_dashboard.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.orange[100],
                    child: Center(
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: themeColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                Position8(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_graph,
                          color: Colors.green[600],
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'update_ekonomi_harian'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'fitur_unggulan'.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'solusi_finansial'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 24),
          _buildFeatureCard(
            Icons.newspaper_rounded,
            'berita_ekonomi_terkini'.tr,
            'desc_berita_ekonomi'.tr,
            Colors.orange[50]!,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            Icons.document_scanner_rounded,
            'verifikasi_cerdas'.tr,
            'desc_verifikasi_cerdas'.tr,
            Colors.white,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            Icons.account_balance_wallet_rounded,
            'manajemen_simpanan'.tr,
            'desc_manajemen_simpanan'.tr,
            themeColor.withAlpha((0.9 * 255).toInt()),
            isDark: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String desc,
    Color bgColor, {
    bool isDark = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.orange[800],
              size: 24,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthSimulation(Color themeColor) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: themeColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'siap_memulai'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'desc_siap_memulai'.tr,
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Fixed Positioned typo in code
class Position8 extends StatelessWidget {
  final Widget child;
  final double? top, bottom, left, right;
  const Position8({
    super.key,
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: child,
  );
}

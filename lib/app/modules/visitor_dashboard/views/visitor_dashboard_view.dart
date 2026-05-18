import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/visitor_dashboard_controller.dart';

class VisitorDashboardView extends GetView<VisitorDashboardController> {
  const VisitorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Daftar Menjadi Anggota',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF6B0D0D).withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.account_balance, color: Color(0xFF6B0D0D), size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'KOPERASI SIMPANAN HARKAT',
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
            'Wujudkan Masa\nDepan Finansial\nyang Lebih Baik',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: themeColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Bergabunglah dengan ekosistem koperasi modern yang mengutamakan transparansi dan kesejahteraan bersama.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24),
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
                ),
                Position8(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STATUS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('Aktif', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
            'KEUNGGULAN KAMI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Solusi Simpanan\nMasa Depan Anda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 24),
          _buildFeatureCard(
            Icons.account_balance_wallet_outlined,
            'Beragam Jenis Simpanan',
            'Tersedia Simpanan Pokok, Wajib, dan Sukarela yang dirancang untuk mendukung pertumbuhan aset finansial Anda dengan aman.',
            Colors.orange[50]!,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            Icons.account_balance_outlined,
            'Penarikan Fleksibel',
            'Ajukan penarikan dana simpanan sukarela Anda kapan saja langsung melalui aplikasi, tanpa proses yang rumit.',
            Colors.white,
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            Icons.trending_up,
            'Bagi Hasil (SHU)',
            'Nikmati Sisa Hasil Usaha tahunan yang kompetitif sebagai apresiasi atas partisipasi aktif Anda dalam koperasi.',
            themeColor.withAlpha((0.9 * 255).toInt()),
            isDark: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, Color bgColor, {bool isDark = false}) {
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
            child: Icon(icon, color: isDark ? Colors.white : Colors.orange[800], size: 24),
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
          Text(
            'Lihat Potensi\nPertumbuhan Anda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Gunakan simulasi kami untuk melihat bagaimana simpanan Anda berkontribusi pada pertumbuhan kolektif.',
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 24),
          Text(
            'ESTIMASI SIMPANAN BULANAN',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                'Rp ${controller.savingsAmount.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              Icon(Icons.edit, color: themeColor, size: 18),
            ],
          ),
          Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimasi SHU per Tahun', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('12.5%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                  ],
                ),
              ),
              VerticalDivider(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Proyeksi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Obx(() => Text(
                      'Rp ${(controller.savingsAmount.value * 1.125).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Mulai Simulasi Lengkap', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed Positioned typo in code
class Position8 extends StatelessWidget {
  final Widget child;
  final double? top, bottom, left, right;
  const Position8({super.key, required this.child, this.top, this.bottom, this.left, this.right});
  @override
  Widget build(BuildContext context) => Positioned(top: top, bottom: bottom, left: left, right: right, child: child);
}

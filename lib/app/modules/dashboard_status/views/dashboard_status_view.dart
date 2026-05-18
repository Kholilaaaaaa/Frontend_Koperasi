import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_status_controller.dart';

class DashboardStatusView extends GetView<DashboardStatusController> {
  const DashboardStatusView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B0D0D)),
            );
          }

          if (controller.status.value == 'rejected' ||
              controller.status.value == 'ditolak') {
            return _buildRejectedUI();
          }

          // Default is Pending state
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildProfileSection(),
                _buildStatusAlert(),
                _buildMainCard(),
                _buildVerificationProgress(),
                _buildMainServices(),
                _buildRecentActivity(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedUI() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 80),
          ),
          const SizedBox(height: 32),
          Text(
            'Pendaftaran Ditolak',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'Alasan Penolakan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.rejectionReason.value.isEmpty
                      ? 'Dokumen tidak valid atau kurang jelas.'
                      : controller.rejectionReason.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButton('Daftar Ulang', controller.retryRegistration),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.offAllNamed('/visitor-dashboard'),
            child: const Text(
              'Ke Dashboard Pengunjung',
              style: TextStyle(color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: themeColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                const Expanded(
                  child: Text(
                    'KOPERASI SIMPANAN HARKAT',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/notifikasi'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_outlined, color: themeColor, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://ui-avatars.com/api/?name=Budi+Santoso&background=6B0D0D&color=fff'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELAMAT DATANG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                    letterSpacing: 1,
                  ),
                ),
                Obx(() => Text(
                  controller.userName.value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A80),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.access_time_filled,
                      color: Colors.white,
                      size: 10,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PENDAFTARAN SEDANG DIPROSES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Keanggotaan Anda di Koperasi Simpanan Harkat sedang kami tinjau.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B0D0D), Color(0xFF3D0707)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.account_balance,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SALDO KUMULATIF',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Rp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ID ANGGOTA',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'KOP-PENDING-2024',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'MENUNGGU VERIFIKASI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.verified_user_outlined, color: themeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Verifikasi Sedang Berjalan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tim admin kami sedang memvalidasi dokumen Anda. Proses ini biasanya memakan waktu 1-2 hari kerja.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Colors.black12,
                color: themeColor,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'DOKUMEN DITERIMA',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black26,
                    ),
                  ),
                  Text(
                    'REVIEW AKHIR',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainServices() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAYANAN UTAMA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildLockedServiceItem(
                'Simpanan',
                Icons.account_balance_wallet_outlined,
              ),
              _buildLockedServiceItem(
                'Pinjaman',
                Icons.monetization_on_outlined,
              ),
              _buildLockedServiceItem('Investasi', Icons.trending_up_outlined),
              _buildLockedServiceItem('E-Laporan', Icons.assignment_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedServiceItem(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.black12, size: 24),
              const Icon(Icons.lock_outline, color: Colors.black12, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black26,
            ),
          ),
          const Text(
            'TERKUNCI',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AKTIVITAS TERAKHIR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Pendaftaran Akun Berhasil',
            'Dokumen identitas telah diterima oleh sistem',
            'HARI INI, 09:12',
            true,
          ),
          _buildTimelineItem(
            'Verifikasi Manual',
            'Sedang dalam antrean peninjauan oleh petugas',
            '-',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String time,
    bool isCompleted,
  ) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF6B0D0D) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? Colors.transparent : Colors.black12,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              Expanded(child: Container(width: 2, color: Colors.black12)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCompleted ? Colors.black87 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  if (time != '-') ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.account_balance_wallet, 'LEDGER', true),
          _buildNavItem(Icons.history, 'HISTORY', false),
          _buildNavItem(Icons.trending_up, 'GROWTH', false),
          _buildNavItem(Icons.settings, 'SETTINGS', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? themeColor : Colors.black26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: isActive ? themeColor : Colors.black26,
          ),
        ),
      ],
    );
  }
}

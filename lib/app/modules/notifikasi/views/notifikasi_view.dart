import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotifikasiView extends StatelessWidget {
  const NotifikasiView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              const Text(
                'Notifikasi',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: themeColor),
              ),
              const Text(
                'Pantau aktivitas akun dan pengumuman terbaru koperasi Anda.',
                style: TextStyle(color: Colors.black38, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              _buildDateSection('HARI INI'),
              _buildNotifItem(
                icon: Icons.check_circle_outline,
                iconColor: Colors.orange,
                title: 'Pinjaman Disetujui',
                time: '10:24 AM',
                desc: 'Pengajuan pinjaman darurat Anda sebesar Rp 5.000.000 telah disetujui oleh pengurus.',
                badges: ['KREDIT', 'PENTING'],
              ),
              _buildNotifItem(
                icon: Icons.account_balance_wallet,
                iconColor: themeColor,
                title: 'Setoran Masuk',
                time: '08:15 AM',
                desc: 'Simpanan sukarela sebesar Rp 250.000 telah berhasil diverifikasi oleh sistem.',
              ),
              
              const SizedBox(height: 32),
              _buildDateSection('KEMARIN'),
              _buildNotifItem(
                icon: Icons.campaign,
                iconColor: themeColor,
                title: 'Rapat Anggota Tahunan',
                time: '23 OKT',
                desc: 'Undangan RAT Buku Tahun 2023 akan dilaksanakan pada hari Sabtu ini via Zoom.',
                hasAction: true,
                isHighlighted: true,
              ),
              _buildNotifItem(
                icon: Icons.security,
                iconColor: Colors.grey,
                title: 'Login Perangkat Baru',
                time: '14:50 PM',
                desc: 'Seseorang berhasil login ke akun Anda menggunakan Chrome di MacOS.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: themeColor, size: 20),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
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
    );
  }

  Widget _buildDateSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String desc,
    List<String>? badges,
    bool hasAction = false,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFBE9E7) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5)),
                if (badges != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: badges.map((b) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(8)),
                      child: Text(b, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                    )).toList(),
                  ),
                ],
                if (hasAction) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('LIHAT DETAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

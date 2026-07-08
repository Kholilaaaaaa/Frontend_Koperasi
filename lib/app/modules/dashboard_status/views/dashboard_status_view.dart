import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/dashboard_status_controller.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';

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
                _buildSubmittedData(),
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
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
              'pendaftaran_ditolak'.tr,
              style: const TextStyle(
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
                  Text(
                    'alasan_penolakan'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.rejectionReason.value.isEmpty
                        ? 'alasan_default'.tr
                        : controller.rejectionReason.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildActionButton('daftar_ulang'.tr, controller.retryRegistration),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.offAllNamed('/visitor-dashboard'),
              child: Text(
                'ke_dashboard_pengunjung'.tr,
                style: const TextStyle(color: Colors.black38),
              ),
            ),
          ],
        ),
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
                Image.asset(
                  'assets/images/logo_koperasi.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'KOPERASI SIMPANKU',
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
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Obx(() {
            final avatar = controller.userAvatarPath.value;
            if (avatar.isNotEmpty) {
              final isNetwork = avatar.startsWith('http://') || avatar.startsWith('https://');
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: isNetwork 
                      ? NetworkImage(avatar) as ImageProvider
                      : FileImage(File(avatar)),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
            final encoded = Uri.encodeComponent(controller.userName.value);
            final url = 'https://ui-avatars.com/api/?name=$encoded&background=6B0D0D&color=fff';
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'selamat_datang'.tr,
                  style: const TextStyle(
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
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'pendaftaran_diproses'.tr,
                      style: const TextStyle(
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
          Text(
            'desc_pendaftaran_diproses'.tr,
            style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
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
                Text(
                  'saldo_kumulatif'.tr,
                  style: const TextStyle(
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
                      children: [
                        Text(
                          'id_anggota'.tr,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
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
                      child: Text(
                        'menunggu_verifikasi'.tr,
                        style: const TextStyle(
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
                  children: [
                    Text(
                      'verifikasi_berjalan'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'desc_verifikasi'.tr,
                      style: const TextStyle(
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
                children: [
                  Text(
                    'dokumen_diterima'.tr,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black26,
                    ),
                  ),
                  Text(
                    'review_akhir'.tr,
                    style: const TextStyle(
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

  Widget _buildSubmittedData() {
    return Obx(() {
      final details = controller.registrationDetails;
      if (details.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'data_dikirim'.tr,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('dokumen_ktp'.tr),
                  const SizedBox(height: 12),
                  if (details['ktp_path'] != null && details['ktp_path'].toString().isNotEmpty) ...[
                    _buildImagePreview(details['ktp_path'].toString()),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle('data_diri'.tr),
                  const SizedBox(height: 12),
                  _buildDataRow('nik'.tr, details['nik']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('nama_lengkap'.tr, details['full_name']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('ttl'.tr, details['ttl']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('jenis_kelamin'.tr, details['jenis_kelamin']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('agama'.tr, details['agama']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('alamat'.tr, details['alamat']?.toString() ?? '-'),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('data_kepegawaian'.tr),
                  const SizedBox(height: 12),
                  _buildDataRow('nip'.tr, details['nip']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('jabatan'.tr, details['pekerjaan']?.toString() ?? '-'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('data_simpanan_bank'.tr),
                  const SizedBox(height: 12),
                  _buildDataRow('tipe_simpanan'.tr, details['tipe_simpanan']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('nominal'.tr, 'Rp ${details['nominal_simpanan']?.toString() ?? '0'}'),
                  const Divider(height: 16),
                  _buildDataRow('nama_bank'.tr, details['nama_bank']?.toString() ?? '-'),
                  const Divider(height: 16),
                  _buildDataRow('no_rekening'.tr, details['nomor_rekening']?.toString() ?? '-'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('dokumen_tambahan'.tr),
                  const SizedBox(height: 12),
                  if (details['kartu_karyawan_path'] != null && details['kartu_karyawan_path'].toString().isNotEmpty) ...[
                    Text('kartu_karyawan'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 8),
                    _buildImagePreview(details['kartu_karyawan_path'].toString()),
                    const SizedBox(height: 16),
                  ],
                  if (details['pas_foto_path'] != null && details['pas_foto_path'].toString().isNotEmpty) ...[
                    Text('pas_foto'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 8),
                    _buildImagePreview(details['pas_foto_path'].toString(), isPortrait: true),
                    const SizedBox(height: 16),
                  ],
                  if (details['tanda_tangan_path'] != null && details['tanda_tangan_path'].toString().isNotEmpty) ...[
                    Text('tanda_tangan'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 8),
                    _buildImagePreview(details['tanda_tangan_path'].toString(), isSignature: true),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: themeColor,
        ),
      ),
    );
  }

  Widget _buildImagePreview(String path, {bool isPortrait = false, bool isSignature = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        path.startsWith('http') ? path : '$baseUrl/$path',
        height: isPortrait ? 200 : (isSignature ? 100 : 180),
        width: isPortrait ? 150 : double.infinity,
        fit: isSignature ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 120,
          color: Colors.grey[100],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.black26, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

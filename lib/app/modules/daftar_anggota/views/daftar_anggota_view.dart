import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/daftar_anggota_controller.dart';

class DaftarAnggotaView extends GetView<DaftarAnggotaController> {
  const DaftarAnggotaView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: Obx(() => _buildCurrentStep())),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: themeColor, size: 20),
                onPressed: controller.previousStep,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_outlined, color: themeColor, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return _buildStep5();
      default:
        return _buildStep1();
    }
  }

  // --- STEP 1: EMAIL & PHONE ---
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(1, 5),
          const SizedBox(height: 16),
          Text(
            'daftar_anggota_title'.tr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: themeColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'desc_daftar_anggota'.tr,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildLabel('EMAIL ${controller.loginType.value == 'phone' ? 'wajib_diisi'.tr : 'sudah_terisi'.tr}'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hintText: 'nama@email.com',
            readOnly: controller.loginType.value == 'email',
          ),
          const SizedBox(height: 24),
          _buildLabel('PHONE NUMBER ${controller.loginType.value == 'email' ? 'wajib_diisi'.tr : 'sudah_terisi'.tr}'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                  color: controller.loginType.value == 'phone' ? Colors.grey[100] : Colors.white,
                ),
                child: const Text('+62', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: controller.phoneController,
                  hintText: '812 3456 7890',
                  keyboardType: TextInputType.phone,
                  readOnly: controller.loginType.value == 'phone',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildActionButton('lanjut_verifikasi'.tr, controller.nextStep),
        ],
      ),
    );
  }

  // --- STEP 2: OCR UPLOAD (MATCHING IMAGE) ---
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'verifikasi_identitas'.tr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'desc_verifikasi_identitas'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          
          // KTP Section
          controller.ktpImage.value == null
              ? _buildDocItem(
                  'foto_ktp'.tr,
                  'desc_foto_ktp'.tr,
                  Icons.badge_outlined,
                  false,
                  () => controller.startKtpScannerFlow(),
                )
              : Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: themeColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'foto_ktp_terdeteksi'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16),
                                ),
                                Text(
                                  'desc_ktp_terdeteksi'.tr,
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.check_circle_outline, color: themeColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Preview Area
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(controller.ktpImage.value!, width: double.infinity, fit: BoxFit.cover, cacheWidth: 800),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text('terdeteksi'.tr, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => controller.startKtpScannerFlow(),
                              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                              label: Text('ganti_foto'.tr, style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          
          const SizedBox(height: 32),
          Text('dokumen_pendukung'.tr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
          const SizedBox(height: 16),
          
          _buildDocItem('kartu_anggota'.tr, 'unggah_galeri'.tr, Icons.card_membership_outlined, controller.kartuAnggotaImage.value != null, () => controller.pickImage('kartu_anggota', ImageSource.gallery)),
          _buildDocItem('pas_foto'.tr, 'unggah_pas_foto'.tr, Icons.portrait_outlined, controller.pasFotoImage.value != null, () => controller.pickImage('pas_foto', ImageSource.gallery)),
          _buildDocItem('tanda_tangan'.tr, 'unggah_tanda_tangan'.tr, Icons.gesture, controller.signatureImage.value != null, () => controller.pickImage('signature', ImageSource.gallery)),
          
          const SizedBox(height: 40),
          _buildActionButton('proses_verifikasi'.tr, controller.nextStep),
        ],
      ),
    );
  }

  // --- STEP 3: OCR RESULTS (PREMIUM VALIDATION) ---
  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Progress Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepBadge(3, 5),
                const SizedBox(height: 24),
                Text(
                  'konfirmasi_hasil_scan'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'desc_konfirmasi_scan'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Duplicate check status card
                Obx(() {
                  final isDup = controller.isDuplicate.value;
                  final reason = controller.duplicateReason.value;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDup ? const Color(0xFFFCE4E4) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDup ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isDup ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: isDup ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDup ? 'teridentifikasi_duplikat'.tr : 'data_bersih'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDup ? Colors.red[900] : Colors.green[900],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDup
                                    ? reason
                                    : 'ktp_belum_terdaftar'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDup ? Colors.red[700] : Colors.green[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                
                // Data Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDataField('nama_lengkap_upper'.tr, controller.nameController),
                      const SizedBox(height: 24),
                      _buildDataField('nomor_nik'.tr, controller.nikController),
                      const SizedBox(height: 24),
                      _buildDataField(
                        'tanggal_lahir'.tr, 
                        controller.dobController, 
                        suffix: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 24),
                      _buildDataField('jenis_kelamin_upper'.tr, controller.genderController),
                      const SizedBox(height: 24),
                      _buildDataField('agama_upper'.tr, controller.religionController),
                      const SizedBox(height: 24),
                      _buildDataField(
                        'alamat_lengkap'.tr, 
                        controller.addressController, 
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF6B0D0D)),
                          const SizedBox(width: 6),
                          Text(
                            'data_kepegawaian'.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF6B0D0D),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'desc_data_kepegawaian'.tr,
                        style: const TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                      const SizedBox(height: 16),
                      _buildDataField('nip_id_karyawan'.tr, controller.nipController, readOnly: false),
                      const SizedBox(height: 24),
                      // Jabatan dropdown
                      _buildJabatanField(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // KTP Preview Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'hasil_scan_ktp'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.currentStep.value = 2,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: Text('scan_ulang'.tr, style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: themeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: controller.ktpImage.value != null
                        ? Image.file(
                            controller.ktpImage.value!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 800,
                          )
                        : const Center(child: Icon(Icons.credit_card, size: 64, color: Colors.white24)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 12, color: Colors.black26),
                    const SizedBox(width: 4),
                    Text(
                      'data_aman'.tr,
                      style: const TextStyle(fontSize: 10, color: Colors.black26),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              final isDup = controller.isDuplicate.value;
              return _buildActionButton(
                isDup ? 'ktp_terduplikasi'.tr : 'pilih_simpanan'.tr,
                isDup
                    ? () {
                        Get.snackbar(
                          'pendaftaran_ditolak'.tr,
                          'ktp_terdaftar_admin'.tr,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    : controller.nextStep,
                color: isDup ? Colors.grey : themeColor,
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS FOR VALIDATION ---
  
  Widget _buildDataField(String label, TextEditingController textController, {Widget? suffix, int maxLines = 1, bool readOnly = true}) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textController,
      builder: (context, value, _) {
        final bool hasData = value.text.trim().isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
                if (readOnly)
                  hasData
                    ? _buildBadge('ocr_verified'.tr, Colors.green, Icons.check_circle)
                    : _buildBadge('review_required'.tr, Colors.orange, Icons.edit_note_outlined)
                else
                  hasData
                    ? _buildBadge('terisi'.tr, Colors.blue, Icons.check_circle_outline)
                    : _buildBadge('wajib_dipilih'.tr, const Color(0xFF6B0D0D), Icons.edit_outlined),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: (!hasData && readOnly) ? const EdgeInsets.all(12) : EdgeInsets.zero,
              decoration: (!hasData && readOnly)
                  ? BoxDecoration(
                      color: const Color(0xFFFFF2F2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: readOnly,
                      controller: textController,
                      maxLines: maxLines,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: readOnly ? Colors.grey[50] : Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: readOnly
                              ? BorderSide(color: Colors.grey[300]!)
                              : const BorderSide(color: Color(0xFF6B0D0D), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF6B0D0D)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  if (suffix != null) suffix,
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJabatanField() {
    final jabatanOptions = [
      'Dosen',
      'Tenaga Kependidikan',
      'Staf Administrasi',
      'Karyawan Honorer',
      'Kepala Bagian',
      'Pejabat Struktural',
      'Guru',
      'Lainnya',
    ];
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.jabatanController,
      builder: (context, value, _) {
        final selected = value.text;
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'jabatan_unit'.tr,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
              selected.isNotEmpty
                ? _buildBadge('terisi'.tr, Colors.blue, Icons.check_circle_outline)
                : _buildBadge('wajib_dipilih'.tr, const Color(0xFF6B0D0D), Icons.arrow_drop_down_circle_outlined),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: const Color(0xFF6B0D0D), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected.isNotEmpty ? selected : null,
                hint: Text('pilih_jabatan'.tr, style: const TextStyle(color: Colors.black38, fontSize: 14)),
                isExpanded: true,
                items: jabatanOptions.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                onChanged: (val) {
                  if (val != null) controller.jabatanController.text = val;
                },
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
        ],
      );
    });
  }

  // --- STEP 4: SAVINGS & BANK ---
  Widget _buildStep4() {
    // Bank-bank umum yang banyak digunakan di Indonesia
    final bankOptions = [
      'BCA',
      'Bank Mandiri',
      'BRI',
      'BNI',
      'BSI (Bank Syariah Indonesia)',
      'BTN',
      'CIMB Niaga',
      'Danamon',
      'Permata Bank',
      'Maybank',
      'OCBC NISP',
      'Bank Jago',
      'SeaBank',
      'Jenius (SMBC)',
      'BPD (Bank Pembangunan Daerah)',
      'Muamalat',
      'BTPN',
      'BPR',
      'Lainnya',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(4, 5),
          const SizedBox(height: 16),
          Text('simpanan_rekening'.tr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: themeColor)),
          const SizedBox(height: 8),
          Text(
            'desc_simpanan_wajib'.tr,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 28),

          // --- Simpanan Wajib Card (fixed, tidak bisa diubah saat pendaftaran) ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor, const Color(0xFFAA2222)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('simpanan_wajib'.tr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      const Text('Rp 100.000', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('setoran_awal'.tr, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Info tambah simpanan lain
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'info_tambah_simpanan'.tr,
                    style: const TextStyle(fontSize: 12, color: Colors.blue, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // --- Nomor Rekening ---
          _buildLabel('nomor_rekening_upper'.tr),
          const SizedBox(height: 8),
          TextField(
            controller: controller.nomorRekeningController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'masukkan_no_rekening'.tr,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.credit_card_outlined, color: Colors.black38),
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: themeColor, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Pilih Bank ---
          _buildLabel('pilih_bank'.tr),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.namaBankController,
            builder: (ctx, val, _) {
              // Pastikan value ada di list, jika tidak reset
              final selectedVal = bankOptions.contains(val.text) ? val.text : null;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: selectedVal != null ? themeColor : Colors.black12,
                    width: selectedVal != null ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedVal,
                    hint: Row(
                      children: [
                        const Icon(Icons.account_balance_outlined, color: Colors.black38, size: 20),
                        const SizedBox(width: 10),
                        Text('pilih_bank'.tr, style: const TextStyle(color: Colors.black38, fontSize: 14)),
                      ],
                    ),
                    isExpanded: true,
                    items: bankOptions.map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) controller.namaBankController.text = v;
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          _buildActionButton('lanjut'.tr, controller.nextStep),
        ],
      ),
    );
  }


  // --- STEP 5: AGREEMENT ---
  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(5, 5),
          const SizedBox(height: 16),
          Text('pernyataan'.tr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: themeColor)),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: SingleChildScrollView(
                child: Text(
                  'teks_pernyataan'.tr * 5,
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: controller.isAgreed.value,
                onChanged: (v) => controller.isAgreed.value = v!,
                activeColor: themeColor,
              ),
              Expanded(
                child: Text('setuju_syarat'.tr, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton('ajukan_pendaftaran'.tr, controller.submitRegistration),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStepBadge(int current, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFCE4E4), borderRadius: BorderRadius.circular(20)),
      child: Text(
        '${'langkah'.tr} $current ${'dari'.tr} $total',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5));
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text, bool readOnly = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor)),
      ),
    );
  }

  Widget _buildDocItem(String title, String subtitle, IconData icon, bool isUploaded, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12.withValues(alpha: 0.05))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFF2F2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: themeColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
            Icon(isUploaded ? Icons.edit_outlined : Icons.add, color: themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? themeColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

}

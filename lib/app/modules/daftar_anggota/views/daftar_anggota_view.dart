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
              const SizedBox(width: 16),
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
            'Daftar Anggota\nKoperasi',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: themeColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bergabunglah dengan Koperasi Simpanan Harkat untuk masa depan finansial yang lebih stabil.',
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildLabel('EMAIL ${controller.loginType.value == 'phone' ? '(WAJIB DIISI)' : '(SUDAH TERISI)'}'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller.emailController,
            hintText: 'nama@email.com',
            readOnly: controller.loginType.value == 'email',
          ),
          const SizedBox(height: 24),
          _buildLabel('PHONE NUMBER ${controller.loginType.value == 'email' ? '(WAJIB DIISI)' : '(SUDAH TERISI)'}'),
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
          _buildActionButton('Lanjut Ke Verifikasi Dokumen', controller.nextStep),
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
            'Verifikasi Identitas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: themeColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lengkapi dokumen koperasi Anda untuk memulai perjalanan finansial yang aman.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          
          // KTP Section
          controller.ktpImage.value == null
              ? _buildDocItem(
                  'Foto KTP',
                  'Pastikan foto jelas dan terbaca',
                  Icons.badge_outlined,
                  false,
                  () => _showImageSourceDialog('ktp'),
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
                                  'Foto KTP Terdeteksi',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16),
                                ),
                                const Text(
                                  'Data Anda akan diekstraksi secara otomatis.',
                                  style: TextStyle(fontSize: 11, color: Colors.black54),
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
                              child: Image.file(controller.ktpImage.value!, width: double.infinity, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text('TERDETEKSI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                              onPressed: () => _showImageSourceDialog('ktp'),
                              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                              label: const Text('Ganti Foto', style: TextStyle(color: Colors.white)),
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
          const Text('DOKUMEN PENDUKUNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
          const SizedBox(height: 16),
          
          _buildDocItem('Kartu Anggota', 'Format PDF atau JPG (Max 5MB)', Icons.card_membership_outlined, controller.kartuAnggotaImage.value != null, () => _showImageSourceDialog('kartu_anggota')),
          _buildDocItem('Pas Foto', 'Wajah tegak lurus, latar polos', Icons.portrait_outlined, controller.pasFotoImage.value != null, () => _showImageSourceDialog('pas_foto')),
          _buildDocItem('Tanda Tangan', 'Gunakan tinta hitam di kertas', Icons.gesture, controller.signatureImage.value != null, () => _showImageSourceDialog('signature')),
          
          const SizedBox(height: 40),
          _buildActionButton('Proses Verifikasi Sekarang', controller.nextStep),
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
                  'Konfirmasi Hasil Scan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan data berikut sesuai dengan KTP asli Anda. Anda dapat mengedit data jika terdapat kesalahan pembacaan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
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
                      _buildDataField('NAMA LENGKAP', controller.nameController, true),
                      const SizedBox(height: 24),
                      _buildDataField('NOMOR NIK', controller.nikController, true),
                      const SizedBox(height: 24),
                      _buildDataField(
                        'TANGGAL LAHIR', 
                        controller.dobController, 
                        true, 
                        suffix: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.redAccent),
                      ),
                      const SizedBox(height: 24),
                      _buildDataField('JENIS KELAMIN', controller.genderController, true),
                      const SizedBox(height: 24),
                      _buildDataField('AGAMA', controller.religionController, true),
                      const SizedBox(height: 24),
                      _buildDataField(
                        'ALAMAT LENGKAP', 
                        controller.addressController, 
                        false,
                        isReviewRequired: true,
                        maxLines: 3,
                      ),
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
                    const Text(
                      'Hasil Scan KTP',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.currentStep.value = 2,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Scan Ulang', style: TextStyle(fontSize: 12)),
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
                          )
                        : const Center(child: Icon(Icons.credit_card, size: 64, color: Colors.white24)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 12, color: Colors.black26),
                    SizedBox(width: 4),
                    Text(
                      'Data aman & terenkripsi oleh sistem perbankan',
                      style: TextStyle(fontSize: 10, color: Colors.black26),
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
            child: _buildActionButton('Pilih Simpanan', controller.nextStep),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS FOR VALIDATION ---
  
  Widget _buildDataField(String label, TextEditingController textController, bool isVerified, {Widget? suffix, bool isReviewRequired = false, int maxLines = 1}) {
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
            if (isVerified)
              _buildBadge('OCR Verified', Colors.green, Icons.check_circle)
            else if (isReviewRequired)
              _buildBadge('Review Required', Colors.orange, Icons.edit_note_outlined),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isReviewRequired ? 12 : 0),
          decoration: isReviewRequired
              ? BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Row(
            children: [
              Expanded(
                child: TextField(
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
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF6B0D0D)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              ?suffix,
            ],
          ),
        ),
      ],
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

  // --- STEP 4: SAVINGS SELECTION ---
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(4, 5),
          const SizedBox(height: 16),
          Text('Pilih Simpanan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: themeColor)),
          const SizedBox(height: 32),
          _buildLabel('JENIS SIMPANAN'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedSavingsType.value,
                isExpanded: true,
                items: ['Simpanan Sukarela', 'Simpanan Pokok', 'Simpanan Wajib'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => controller.selectedSavingsType.value = v!,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('NOMINAL SIMPANAN PERTAMA'),
          const SizedBox(height: 8),
          _buildTextField(controller: controller.nominalController, hintText: 'Rp 0', keyboardType: TextInputType.number),
          const SizedBox(height: 40),
          _buildActionButton('Lanjut', controller.nextStep),
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
          Text('Pernyataan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: themeColor)),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
              child: SingleChildScrollView(
                child: Text(
                  'Saya menyatakan bahwa data yang saya berikan adalah benar dan saya bersedia mematuhi segala peraturan Koperasi Simpanan Harkat.\n\n' * 5,
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
              const Expanded(
                child: Text('Saya menyetujui syarat dan ketentuan yang berlaku.', style: TextStyle(fontSize: 13, color: Colors.black54)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton('Ajukan Pendaftaran', controller.submitRegistration),
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
        'LANGKAH $current DARI $total',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor),
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

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
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

  void _showImageSourceDialog(String type) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.pickImage(type, ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Kamera', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.pickImage(type, ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo_library, color: themeColor),
                    label: Text('Galeri', style: TextStyle(color: themeColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: themeColor.withValues(alpha: 0.1)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

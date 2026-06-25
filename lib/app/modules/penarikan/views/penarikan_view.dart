import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/penarikan_controller.dart';
import '../../../routes/app_routes.dart';

class PenarikanView extends GetView<PenarikanController> {
  const PenarikanView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);
  static const cardColor = Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
            Text(
              'Pengajuan Penarikan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kelola dana simpanan Anda secara aman dan transparan melalui sistem ledger digital kami.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A1515), Color(0xFF4A0808)],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL SALDO TERSEDIA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        controller.formattedSelectedSavingBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'STATUS AKUN',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Anggota Aktif',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.verified_user, color: Colors.white.withValues(alpha: 0.5), size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Form
            _buildLabel('PILIH SIMPANAN'),
            _buildDropdown(
              value: controller.selectedSimpanan,
              items: controller.daftarSimpanan,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('NOMINAL PENARIKAN'),
            _buildTextField(
              controller: controller.nominalController,
              hint: '0',
              prefix: 'Rp ',
              helper: 'Minimal penarikan Rp 50.000',
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('PILIH REKENING TUJUAN'),
            _buildTextField(
              controller: controller.rekeningTujuanController,
              hint: '',
              suffix: Icon(Icons.account_balance, color: themeColor.withValues(alpha: 0.5), size: 20),
              readOnly: true,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('ALASAN PENARIKAN (OPSIONAL)'),
            _buildTextField(
              controller: controller.alasanController,
              hint: 'Contoh: Kebutuhan mendesak keluarga',
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.security, color: themeColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Penarikan akan diproses dalam 1-3 hari kerja untuk verifikasi keamanan dan integritas dana bersama Anda.',
                      style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submitPenarikan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ajukan Penarikan Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
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
          onTap: () => Get.toNamed(Routes.NOTIFIKASI),
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
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({required RxString value, required List<String> items}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: themeColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => value.value = val!,
        ),
      ),
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? helper,
    Widget? suffix,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixText: prefix,
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              suffixIcon: suffix,
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(helper, style: const TextStyle(fontSize: 10, color: Colors.black26, fontStyle: FontStyle.italic)),
          ),
        ],
      ],
    );
  }
}

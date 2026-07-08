import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/buka_simpanan_controller.dart';
import '../../../routes/app_routes.dart';

class BukaSimpananView extends GetView<BukaSimpananController> {
  const BukaSimpananView({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
            Text(
              'layanan_keanggotaan'.tr,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.isEditMode.value ? 'update_pengajuan'.tr : 'buka_simpanan'.tr,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
            )),
            const SizedBox(height: 12),
            Obx(() => Text(
              controller.isEditMode.value
                ? 'desc_update_pengajuan'.tr
                : 'desc_buka_simpanan'.tr,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            )),
            const SizedBox(height: 32),
            
            // Promo Card
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1580519542036-c47de6196ba5?auto=format&fit=crop&q=80&w=600'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Form
            _buildLabel('jenis_simpanan'.tr),
            _buildDropdown(
              value: controller.jenisSimpanan,
              items: controller.daftarSimpanan,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('nominal_simpanan'.tr),
            _buildTextField(
              controller: controller.nominalController,
              hint: 'hint_nominal'.tr,
              prefix: 'Rp ',
              helper: 'helper_nominal'.tr,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Obx(() {
              List<String> options = [];
              if (controller.jenisSimpanan.value == 'Simpanan Pokok') {
                options = ['50000', '100000'];
              } else if (controller.jenisSimpanan.value == 'Simpanan Sukarela') {
                options = ['20000', '50000', '100000'];
              }
              
              if (options.isEmpty) return const SizedBox.shrink();
              
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((opt) {
                  return InkWell(
                    onTap: () => controller.setNominal(opt),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Rp ${opt.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            
            const SizedBox(height: 24),
            _buildLabel('nomor_rekening'.tr),
            _buildTextField(
              controller: controller.nomorRekeningController,
              hint: 'hint_nomor_rekening'.tr,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('pilih_bank'.tr),
            _buildDropdown(
              value: controller.selectedBank,
              items: controller.daftarBank,
            ),
            
            const SizedBox(height: 40),
            
            Obx(() {
              if (!controller.isEditMode.value || controller.savingTypeId == null) {
                return const SizedBox.shrink();
              }
              
              final status = controller.savingStatus.value;
              String statusText = 'status_aktif'.tr;
              Color statusColor = const Color(0xFF2E7D32);
              String actionText = 'nonaktifkan_simpanan'.tr;
              IconData actionIcon = Icons.power_settings_new_rounded;
              Color actionColor = themeColor;
              bool showAction = true;
              
              if (status == 'ACTIVE') {
                statusText = 'status_aktif'.tr;
                statusColor = const Color(0xFF2E7D32);
                actionText = 'ajukan_penonaktifan'.tr;
                actionColor = themeColor;
              } else if (status == 'DEACTIVATION_PENDING') {
                statusText = 'menunggu_persetujuan_penonaktifan'.tr;
                statusColor = const Color(0xFFE65100);
                showAction = false;
              } else if (status == 'INACTIVE') {
                statusText = 'status_nonaktif'.tr;
                statusColor = Colors.grey;
                actionText = 'ajukan_pengaktifan_kembali'.tr;
                actionColor = const Color(0xFF2E7D32);
              } else if (status == 'ACTIVATION_PENDING') {
                statusText = 'menunggu_persetujuan_pengaktifan'.tr;
                statusColor = const Color(0xFFE65100);
                showAction = false;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'status_simpanan'.tr,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.bold, 
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showAction) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showToggleConfirmation(context, status, actionText),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: actionColor,
                            side: BorderSide(color: actionColor.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(actionIcon, size: 16),
                          label: Text(
                            actionText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        'pesan_perubahan_status'.tr,
                        style: const TextStyle(fontSize: 11, color: Colors.black45, height: 1.4),
                      ),
                    ]
                  ],
                ),
              );
            }),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitBukaSimpanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        controller.isEditMode.value ? 'update_pengajuan'.tr : 'buka_simpanan_sekarang'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              )),
            ),
            
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'syarat_buka_1'.tr,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                  children: [
                    TextSpan(
                      text: 'syarat_ketentuan_buka'.tr,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: 'syarat_buka_2'.tr),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Info Cards
            Row(
              children: [
                Expanded(child: _buildInfoCard(
                  Icons.verified_user, 
                  'keamanan_terjamin'.tr, 
                  'desc_keamanan'.tr,
                  null
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(
                  Icons.trending_up, 
                  'pertumbuhan'.tr, 
                  null,
                  'solid'.tr
                )),
              ],
            ),
            const SizedBox(height: 32),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: themeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown({required RxString value, required List<String> items}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.5),
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
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixText: prefix,
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          Text(helper, style: const TextStyle(fontSize: 10, color: Colors.black26, fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String? subtitle, String? highlight) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeColor, size: 24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45, height: 1.4)),
          ],
          if (highlight != null) ...[
            const Spacer(),
            Text(highlight, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: themeColor)),
          ],
        ],
      ),
    );
  }

  void _showToggleConfirmation(BuildContext context, String currentStatus, String actionText) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          currentStatus == 'ACTIVE' ? 'dialog_nonaktifkan_title'.tr : 'dialog_aktifkan_title'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          currentStatus == 'ACTIVE'
              ? 'dialog_nonaktifkan_desc'.tr
              : 'dialog_aktifkan_desc'.tr,
          style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('batal'.tr, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleSavingStatus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus == 'ACTIVE' ? themeColor : const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('ya_ajukan'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

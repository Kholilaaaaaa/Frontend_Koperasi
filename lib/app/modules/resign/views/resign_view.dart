import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resign_controller.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';

class ResignMembershipView extends GetView<ResignController> {
  const ResignMembershipView({super.key});
  
  static const themeColor = Color(0xFF6B0D0D);

  @override
  Widget build(BuildContext context) {
    final memberController = Get.find<MemberDashboardController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pengunduran Diri', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: themeColor),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingStatus.value) {
          return const Center(child: CircularProgressIndicator(color: themeColor));
        }

        if (controller.hasPendingRequest.value) {
          return _buildPendingStatus();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SURAT PERNYATAAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text('Pengunduran Diri dari Keanggotaan Koperasi Harkat', style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),

              _buildSectionTitle('Data Anggota'),
              _buildReadOnlyField('Nama', memberController.rxUserName.value),
              _buildReadOnlyField('No. Anggota / NIPY / NIK', memberController.rxMemberId.value),
              
              _buildDropdownField('Jabatan / Departemen', controller.selectedJabatan, controller.jabatanOptions),
              _buildDropdownField('Lokasi Kerja / Site', controller.selectedLokasi, controller.lokasiOptions),

              const SizedBox(height: 24),
              _buildSectionTitle('Detail Pengunduran Diri'),
              const Text('Mohon untuk menghentikan pemotongan simpanan wajib dan sukarela otomatis terhitung mulai bulan:', style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildMonthDropdown(),

              const SizedBox(height: 24),
              _buildSectionTitle('Pengembalian Simpanan'),
              const Text('Mohon untuk mengembalikan seluruh simpanan dan ditransfer ke:', style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInputField('Nama Bank (contoh: BCA)', controller.bankNameController),
              _buildInputField('Nomor Rekening', controller.bankAccountController, isNumber: true),
              _buildInputField('Atas Nama', controller.bankAccountNameController),

              const SizedBox(height: 32),
              _buildAgreementCheckbox(),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.submitResignation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Pengajuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPendingStatus() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_filled_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Pengajuan Sedang Diproses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text('Pengajuan Anda sedang menunggu persetujuan dari pengurus.', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(foregroundColor: themeColor, side: const BorderSide(color: themeColor), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Kembali ke Pengaturan'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: themeColor, letterSpacing: 1.2)));
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.withOpacity(0.2))), child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, RxnString selectedValue, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.1))),
            child: Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue.value,
                hint: const Text('Pilih', style: TextStyle(color: Colors.black26)),
                isExpanded: true,
                items: options.map((String opt) => DropdownMenuItem<String>(value: opt, child: Text(opt, overflow: TextOverflow.ellipsis, maxLines: 2, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) { if (val != null) selectedValue.value = val; },
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController textController, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            controller: textController,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.black.withOpacity(0.1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: themeColor))),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.1))),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedMonth.value.isNotEmpty ? controller.selectedMonth.value : null,
          isExpanded: true,
          items: controller.availableMonths.map((String month) => DropdownMenuItem<String>(value: month, child: Text(month))).toList(),
          onChanged: (val) { if (val != null) controller.selectedMonth.value = val; },
        ),
      )),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => SizedBox(width: 24, height: 24, child: Checkbox(value: controller.agreedToTerms.value, onChanged: (val) => controller.agreedToTerms.value = val ?? false, activeColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))))),
          const SizedBox(width: 12),
          const Expanded(child: Text('Demikian Surat Pernyataan ini saya buat dengan sesungguhnya.', style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87))),
        ],
      ),
    );
  }
}

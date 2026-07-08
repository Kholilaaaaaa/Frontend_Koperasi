import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../network/api_client.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';

class BukaSimpananController extends GetxController {
  final jenisSimpanan = 'Simpanan Pokok'.obs;
  final nominalController = TextEditingController();
  final nomorRekeningController = TextEditingController();
  final selectedBank = 'Pilih Bank Sumber'.obs;

  final isEditMode = false.obs;
  int? editDepositId;
  final savingStatus = 'ACTIVE'.obs;
  int? savingTypeId;

  final List<String> daftarSimpanan = [
    'Simpanan Pokok',
    'Simpanan Sukarela',
  ];

  final List<String> daftarBank = [
    'Pilih Bank Sumber',
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

  @override
  void onInit() {
    super.onInit();
    // Check initial value
    _checkExistingSaving(jenisSimpanan.value);

    // Whenever jenisSimpanan changes, we check if it already exists
    ever(jenisSimpanan, (String value) {
      nominalController.clear();
      nomorRekeningController.clear();
      selectedBank.value = 'Pilih Bank Sumber';
      _checkExistingSaving(value);
    });
  }

  void _checkExistingSaving(String savingType) {
    if (Get.isRegistered<MemberDashboardController>()) {
      final dashCtrl = Get.find<MemberDashboardController>();
      final existingId = dashCtrl.getSavingId(savingType);
      
      if (existingId != null) {
        isEditMode.value = true;
        editDepositId = existingId;
        final saving = dashCtrl.approvedSavings.firstWhereOrNull(
          (s) => s['id'] == existingId
        );
        if (saving != null) {
          savingTypeId = saving['saving_type_id'] as int?;
          savingStatus.value = (saving['status'] ?? 'ACTIVE').toString();
          if (saving['amount'] != null) {
            final amt = saving['amount'].toString();
            setNominal(amt.endsWith('.0') ? amt.replaceAll('.0', '') : amt);
          }
        }
      } else {
        isEditMode.value = false;
        editDepositId = null;
        savingTypeId = null;
        savingStatus.value = 'ACTIVE';
      }
    }
  }

  Future<void> toggleSavingStatus() async {
    if (savingTypeId == null) return;
    isLoading.value = true;
    try {
      final response = await authorizedPost(
        '/api/member/savings/$savingTypeId/toggle_status',
        {},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar(
          'Permohonan Dikirim',
          data['message'] ?? 'Permohonan perubahan status berhasil diajukan.',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
        );
        
        if (Get.isRegistered<MemberDashboardController>()) {
          await Get.find<MemberDashboardController>().refreshAll();
        }
        _checkExistingSaving(jenisSimpanan.value);
      } else {
        Get.snackbar(
          'Gagal',
          data['error'] ?? 'Gagal mengajukan perubahan status.',
          backgroundColor: const Color(0xFFC62828),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nominalController.dispose();
    nomorRekeningController.dispose();
    super.onClose();
  }

  void setNominal(String value) {
    nominalController.text = value;
  }

  final isLoading = false.obs;

  Future<void> submitBukaSimpanan() async {
    if (nominalController.text.isEmpty || selectedBank.value == 'Pilih Bank Sumber') {
      Get.snackbar(
        'Lengkapi Data',
        'Mohon isi nominal dan pilih bank sumber terlebih dahulu',
        backgroundColor: const Color(0xFFB71C1C),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      // Map jenis simpanan to ID based on database (1: Pokok, 2: Wajib, 3: Sukarela)
      int savingTypeId = 3; // Default to Sukarela (SS = 3)
      if (jenisSimpanan.value == 'Simpanan Pokok') savingTypeId = 1; // SP = 1
      
      final payload = {
        'amount': nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'saving_type_id': savingTypeId,
        'source_bank': selectedBank.value,
        'source_account_no': nomorRekeningController.text.isNotEmpty ? nomorRekeningController.text : '-',
      };

      http.Response response;
      if (isEditMode.value && editDepositId != null) {
        response = await authorizedPut('/api/member/deposit/$editDepositId', payload);
      } else {
        response = await authorizedPost('/api/member/deposit', payload);
      }

      final resData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && resData['success'] == true) {
        isLoading.value = false;
        
        // Refresh dashboard data
        if (Get.isRegistered<MemberDashboardController>()) {
          Get.find<MemberDashboardController>().fetchApprovedSavings();
        }

        await Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 56),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditMode.value ? 'Pengajuan Diperbarui!' : 'Permohonan Terkirim!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isEditMode.value 
                    ? 'Update data simpanan ${jenisSimpanan.value} sebesar Rp ${nominalController.text} berhasil.'
                    : 'Pengajuan buka simpanan ${jenisSimpanan.value} sebesar Rp ${nominalController.text} telah berhasil dikirim.\n\nTunggu konfirmasi dari pengurus koperasi.',
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B0D0D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('OK, Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        Get.back(); // close page
      } else {
        Get.snackbar(
          'Gagal',
          resData['error'] ?? 'Terjadi kesalahan saat memproses permohonan',
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Koneksi Gagal',
        'Tidak dapat terhubung ke server. Pastikan internet Anda aktif.',
        backgroundColor: const Color(0xFFB71C1C),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

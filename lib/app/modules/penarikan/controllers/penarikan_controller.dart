import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../network/api_client.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';

class PenarikanController extends GetxController {
  final selectedSimpanan = 'Simpanan Sukarela'.obs;
  final nominalController = TextEditingController();
  final rekeningTujuanController = TextEditingController(text: 'Bank Central Asia • 8820****12');
  final alasanController = TextEditingController();

  final List<String> daftarSimpanan = [
    'Simpanan Sukarela',
    'Simpanan Pokok',
    'Simpanan Wajib',
  ];

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<MemberDashboardController>()) {
      Get.find<MemberDashboardController>().fetchGrowthAnalytics();
    }
    updateRekeningTujuan();
    ever(selectedSimpanan, (_) => updateRekeningTujuan());
  }

  void updateRekeningTujuan() {
    if (Get.isRegistered<MemberDashboardController>()) {
      final dashboard = Get.find<MemberDashboardController>();
      final match = dashboard.approvedSavings.firstWhereOrNull(
        (s) => (s['saving_type_name'] as String).toLowerCase().contains(selectedSimpanan.value.toLowerCase()),
      );
      if (match != null &&
          match['bank_name'] != null &&
          match['bank_name'].toString().isNotEmpty) {
        rekeningTujuanController.text = "${match['bank_name']} • ${match['account_number']}";
      } else {
        rekeningTujuanController.text = "-";
      }
    } else {
      rekeningTujuanController.text = "-";
    }
  }

  double get selectedSavingBalance {
    if (Get.isRegistered<MemberDashboardController>()) {
      final dashboardController = Get.find<MemberDashboardController>();
      return dashboardController.getBalanceByType(selectedSimpanan.value);
    }
    return 0.0;
  }

  String get formattedSelectedSavingBalance {
    if (Get.isRegistered<MemberDashboardController>()) {
      final dashboardController = Get.find<MemberDashboardController>();
      return dashboardController.formatNumber(selectedSavingBalance);
    }
    return '0';
  }

  Future<void> submitPenarikan() async {
    final amountText = nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (amountText.isEmpty) {
      Get.snackbar(
        'Error',
        'Mohon masukkan nominal penarikan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount < 50000) {
      Get.snackbar(
        'Peringatan',
        'Minimal penarikan adalah Rp 50.000',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (amount > selectedSavingBalance) {
      Get.snackbar(
        'Peringatan',
        'Nominal penarikan melebihi saldo tersedia (Rp ${formattedSelectedSavingBalance})',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      int savingTypeId = 3; // Default Sukarela (SS = 3)
      if (selectedSimpanan.value == 'Simpanan Pokok') savingTypeId = 1; // SP = 1
      if (selectedSimpanan.value == 'Simpanan Wajib') savingTypeId = 2; // SW = 2
      
      String bankName = '-';
      String accNum = '-';
      final rekParts = rekeningTujuanController.text.split('•');
      if (rekParts.length == 2) {
        bankName = rekParts[0].trim();
        accNum = rekParts[1].trim();
      } else {
        bankName = rekeningTujuanController.text.trim();
      }

      final response = await authorizedPost('/api/member/withdraw', {
        'amount': amountText,
        'bank_name': bankName,
        'account_number': accNum,
        'account_holder': Get.isRegistered<MemberDashboardController>()
            ? Get.find<MemberDashboardController>().userName
            : (GetStorage().read('userName') ?? 'Anggota'),
        'reason': alasanController.text,
        'saving_type_id': savingTypeId
      });

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 && resData['success'] == true) {
        isLoading.value = false;
        if (Get.isRegistered<MemberDashboardController>()) {
          Get.find<MemberDashboardController>().fetchGrowthAnalytics();
          Get.find<MemberDashboardController>().fetchApprovedSavings(); // Also refresh savings list
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
                const Text(
                  'Permohonan Terkirim!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pengajuan penarikan ${selectedSimpanan.value} sebesar Rp ${nominalController.text} berhasil dikirim.\n\nMohon tunggu konfirmasi persetujuan dari pengurus koperasi.',
                  style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B0D0D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
        Get.back(); // Close PenarikanView
      } else {
        Get.snackbar(
          'Gagal',
          resData['error'] ?? 'Terjadi kesalahan saat memproses permohonan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghubungi server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nominalController.dispose();
    rekeningTujuanController.dispose();
    alasanController.dispose();
    super.onClose();
  }
}

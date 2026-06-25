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
    if (nominalController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Mohon masukkan nominal penarikan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      int savingTypeId = 2; // Default Sukarela
      if (selectedSimpanan.value == 'Simpanan Pokok') savingTypeId = 3;
      if (selectedSimpanan.value == 'Simpanan Wajib') savingTypeId = 1;
      
      String bankName = '-';
      String accNum = '-';
      final rekParts = rekeningTujuanController.text.split('•');
      if (rekParts.length == 2) {
        bankName = rekParts[0].trim();
        accNum = rekParts[1].trim();
      }

      final response = await authorizedPost('/api/member/withdraw', {
        'amount': nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
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
        Get.snackbar(
          'Sukses',
          'Pengajuan penarikan berhasil dikirim dan sedang diproses',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (Get.isRegistered<MemberDashboardController>()) {
          Get.find<MemberDashboardController>().fetchGrowthAnalytics();
        }
        Get.back();
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

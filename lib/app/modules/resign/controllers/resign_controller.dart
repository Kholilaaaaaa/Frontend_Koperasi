import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/network/api_client.dart';
import 'package:get_storage/get_storage.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';

class ResignController extends GetxController {
  final ApiClient apiClient = ApiClient();
  final box = GetStorage();

  final nipyController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankAccountController = TextEditingController();
  final bankAccountNameController = TextEditingController();

  final isSubmitting = false.obs;
  final isLoadingStatus = true.obs;
  final agreedToTerms = false.obs;
  
  final hasPendingRequest = false.obs;
  final resignStatus = ''.obs;

  final selectedMonth = ''.obs;
  final List<String> availableMonths = [];

  final selectedJabatan = RxnString();
  final selectedLokasi = RxnString();

  final List<String> jabatanOptions = [
    'Dosen',
    'Staff Akademik',
    'Tenaga Kependidikan',
    'Karyawan',
    'Pengurus Koperasi',
    'Anggota Biasa',
    'Lainnya'
  ];

  final List<String> lokasiOptions = [
    'Universitas Harkat Negeri\nJl. Mataram No.9, Pesurungan Lor, Kec. Margadana, Kota Tegal, Jawa Tengah 52147',
    'Universitas Harkat Negeri (Kampus Pendidikan)\nJl. Pendidikan No.1, Pesurungan Lor, Kec. Margadana, Kota Tegal, Jawa Tengah 52142'
  ];



  @override
  void onInit() {
    super.onInit();
    _generateMonths();
    _loadPreFillData();
    checkResignStatus();
  }

  void _generateMonths() {
    final now = DateTime.now();
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      availableMonths.add('${months[date.month - 1]} ${date.year}');
    }
    selectedMonth.value = availableMonths.first;
  }

  void _loadPreFillData() {
    final memberController = Get.find<MemberDashboardController>();
    bankAccountNameController.text = memberController.rxUserName.value;
    nipyController.text = memberController.rxMemberId.value; // autofill NIPY dengan memberId/NIK/NIP
  }

  Future<void> checkResignStatus() async {
    try {
      isLoadingStatus.value = true;
      final response = await apiClient.authorizedGet('/api/membership/resign');
      final resData = jsonDecode(response.body);
      if (resData['success'] == true) {
        final data = resData['data'];
        if (data != null && data['status'] == 'PENDING') {
          hasPendingRequest.value = true;
          resignStatus.value = 'PENDING';
        } else {
          hasPendingRequest.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error checking resign status: $e');
    } finally {
      isLoadingStatus.value = false;
    }
  }

  Future<void> submitResignation() async {
    if (!agreedToTerms.value) {
      Get.snackbar('Peringatan', 'Anda harus menyetujui pernyataan pengunduran diri.', backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    
    if (bankNameController.text.isEmpty || bankAccountController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Silakan lengkapi data bank untuk pengembalian simpanan.', backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    if (selectedJabatan.value == null || selectedLokasi.value == null) {
      Get.snackbar('Peringatan', 'Silakan pilih Jabatan dan Lokasi Kerja.', backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    try {
      isSubmitting.value = true;
      final data = {
        'nipy': nipyController.text,
        'jabatan': selectedJabatan.value,
        'lokasi_kerja': selectedLokasi.value,
        'effective_month': selectedMonth.value,
        'bank_name': bankNameController.text,
        'bank_branch': '-', // removed from UI
        'bank_account_number': bankAccountController.text,
        'bank_account_name': bankAccountNameController.text,
      };
      
      final response = await apiClient.authorizedPost('/api/membership/resign', data);
      final resData = jsonDecode(response.body);
      
      if (resData['success'] == true) {
        hasPendingRequest.value = true;
        resignStatus.value = 'PENDING';
        Get.snackbar('Berhasil', 'Pengajuan pengunduran diri berhasil dikirim.', backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', resData['message'] ?? 'Terjadi kesalahan.', backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pengajuan.', backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nipyController.dispose();
    bankNameController.dispose();
    bankAccountController.dispose();
    bankAccountNameController.dispose();
    super.onClose();
  }
}

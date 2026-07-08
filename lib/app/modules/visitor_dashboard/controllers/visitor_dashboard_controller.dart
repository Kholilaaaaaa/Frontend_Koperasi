import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../network/api_client.dart';
import '../../../routes/app_routes.dart';

class VisitorDashboardController extends GetxController {
  final savingsAmount = 500000.obs;
  final estimatedRate = 12.5;
  final _box = GetStorage();

  double get estimatedYearlySHU => savingsAmount.value * (estimatedRate / 100);

  @override
  void onReady() {
    super.onReady();
    checkResignStatus();
  }

  void setSavingsAmount(int amount) {
    savingsAmount.value = amount;
  }

  Future<void> checkResignStatus() async {
    try {
      print('DEBUG: checkResignStatus dipanggil!');
      final response = await authorizedGet('/api/membership/resign');
      print('DEBUG: response status = ${response.statusCode}');
      print('DEBUG: response body = ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (data['data']['status'] == 'APPROVED') {
            final docUrl = data['data']['document_url'];
            final proofUrl = data['data']['transfer_proof_url'];
            print('DEBUG: docUrl = $docUrl, proofUrl = $proofUrl');
            _showResignationApprovedDialog(docUrl, proofUrl);
          } else {
            print('DEBUG: status bukan APPROVED melainkan ${data['data']['status']}');
          }
        } else {
          print('DEBUG: success false atau data null');
        }
      }
    } catch (e) {
      print('DEBUG: Error in checkResignStatus = $e');
    }
  }

  void _showResignationApprovedDialog(String? docUrl, String? proofUrl) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isDialogOpen == true) return; // prevent duplicate
      Get.dialog(
        AlertDialog(
          title: const Text('Pengajuan Keluar Anggota Disetujui', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pengajuan pengunduran diri Anda telah disetujui oleh pengurus.'),
                const SizedBox(height: 12),
                if (proofUrl != null) ...[
                const Text('Bukti Transfer Sisa Simpanan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '$baseUrl$proofUrl',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Anda dapat mengunduh dokumen bukti persetujuan di bawah ini.'),
              const SizedBox(height: 16),
              if (docUrl != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('$baseUrl$docUrl');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      Get.snackbar('Error', 'Gagal membuka tautan dokumen');
                    }
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Unduh Form'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              const SizedBox(height: 12),
              const Text('Setelah Anda menekan tombol OK, seluruh akses dan data keanggotaan Anda akan dinonaktifkan secara permanen.', style: TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
        ),
        actions: [
            TextButton(
              onPressed: () async {
                Get.back(); // close dialog
                await _acknowledgeResignation();
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    });
  }

  Future<void> _acknowledgeResignation() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await authorizedPost('/api/membership/resign/acknowledge', {});
      Get.back(); // close loading
      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Data keanggotaan berhasil dihapus secara permanen.');
      } else {
        Get.snackbar('Error', 'Gagal memproses persetujuan akhir.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Terjadi kesalahan sistem.');
    }
  }
}

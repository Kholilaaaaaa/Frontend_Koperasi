import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../routes/app_routes.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';
import '../views/scanner_instructions_view.dart';


class DaftarAnggotaController extends GetxController {
  final box = GetStorage();
  final picker = ImagePicker();

  // Step 1: Email & Phone
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  var loginType = ''.obs;

  // Step state
  var currentStep = 1.obs;

  // Step 2: Document Paths
  var ktpImage = Rx<File?>(null);
  var kartuAnggotaImage = Rx<File?>(null);
  var pasFotoImage = Rx<File?>(null);
  var signatureImage = Rx<File?>(null);

  // Step 3: OCR Data
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final dobController = TextEditingController();
  final genderController = TextEditingController();
  final religionController = TextEditingController();
  final addressController = TextEditingController();
  var isDuplicate = false.obs;
  var duplicateReason = ''.obs;
  var _ocrAlreadyProcessed = false.obs;

  // Step 4: Savings
  var selectedSavingsType = 'Simpanan Sukarela'.obs;
  final nominalController = TextEditingController();

  // Step 5: Agreement
  var isAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    loginType.value = box.read('loginType') ?? '';
    
    if (loginType.value == 'email') {
      emailController.text = box.read('userEmail') ?? '';
    } else if (loginType.value == 'phone') {
      phoneController.text = box.read('userPhone') ?? '';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    nikController.dispose();
    dobController.dispose();
    religionController.dispose();
    addressController.dispose();
    nominalController.dispose();
    super.onClose();
  }

  Future<void> startKtpScannerFlow() async {
    final result = await Get.to(() => const ScannerInstructionsView(documentType: 'ktp'));
    
    if (result == null) return;

    if (result is Map<String, dynamic>) {
      // Kamera mengembalikan path + data OCR dari server
      final path = result['path'] as String?;
      final ocrData = result['ocr_data'] as Map<String, dynamic>?;

      if (path != null) {
        ktpImage.value = File(path);
      }

      // Langsung isi field dengan data OCR yang sudah ada dari scan
      if (ocrData != null && ocrData.isNotEmpty) {
        nameController.text = ocrData['nama'] ?? '';
        nikController.text = ocrData['nik'] ?? '';
        dobController.text = ocrData['ttl'] ?? '';
        genderController.text = ocrData['jenis_kelamin'] ?? 'Laki-laki';
        religionController.text = ocrData['agama'] ?? '';
        addressController.text = ocrData['alamat'] ?? '';
        isDuplicate.value = ocrData['is_duplicate'] ?? false;
        duplicateReason.value = ocrData['duplicate_reason'] ?? '';
        // Tandai bahwa OCR sudah diproses agar tidak dipanggil 2x
        _ocrAlreadyProcessed.value = true;
      }
    } else if (result is String) {
      // Fallback: hanya path (kamera lama)
      ktpImage.value = File(result);
    }
  }

  Future<void> pickImage(String type, ImageSource source) async {
    try {
      // imageQuality: 100 = tanpa kompresi | maxWidth/maxHeight: null = tanpa resize
      // Penting untuk akurasi OCR backend - gambar harus full resolution
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: null,
        maxHeight: null,
      );
      if (pickedFile != null) {
        switch (type) {
          case 'ktp':
            ktpImage.value = File(pickedFile.path);
            break;
          case 'kartu_anggota':
            kartuAnggotaImage.value = File(pickedFile.path);
            break;
          case 'pas_foto':
            pasFotoImage.value = File(pickedFile.path);
            break;
          case 'signature':
            signatureImage.value = File(pickedFile.path);
            break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e', 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void nextStep() {
    if (currentStep.value == 1) {
      // Validasi email jika login via phone
      if (loginType.value == 'phone' && emailController.text.isEmpty) {
        Get.snackbar('Error', 'Email harus diisi', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Validasi nomor telepon (wajib untuk semua)
      final phone = phoneController.text.replaceAll(RegExp(r'[\s\-]'), ''); // hapus spasi & strip
      if (phone.isEmpty) {
        Get.snackbar(
          'Nomor Telepon Tidak Valid',
          'Wajib isi nomor telepon yang benar dan aktif.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // Hapus leading 0 jika ada (karena prefix +62 sudah ditampilkan)
      final cleanPhone = phone.startsWith('0') ? phone.substring(1) : phone;

      // Harus angka saja
      if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
        Get.snackbar(
          'Nomor Telepon Tidak Valid',
          'Nomor telepon hanya boleh berisi angka.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // Harus dimulai dengan 8 (format Indonesia: 8xx setelah +62)
      if (!cleanPhone.startsWith('8')) {
        Get.snackbar(
          'Nomor Telepon Tidak Valid',
          'Wajib isi nomor telepon yang benar dan aktif. Contoh: 812 3456 7890',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      // Panjang nomor harus 9-12 digit (tanpa leading 0, setelah +62)
      if (cleanPhone.length < 9 || cleanPhone.length > 12) {
        Get.snackbar(
          'Nomor Telepon Tidak Valid',
          'Wajib isi nomor telepon yang benar dan aktif (9-12 digit setelah +62).',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      if (ktpImage.value == null) {
        Get.snackbar('Dokumen Belum Lengkap', 'Harap upload foto KTP terlebih dahulu', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (kartuAnggotaImage.value == null) {
        Get.snackbar('Dokumen Belum Lengkap', 'Harap upload Kartu Anggota terlebih dahulu', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (pasFotoImage.value == null) {
        Get.snackbar('Dokumen Belum Lengkap', 'Harap upload Pas Foto terlebih dahulu', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (signatureImage.value == null) {
        Get.snackbar('Dokumen Belum Lengkap', 'Harap upload Tanda Tangan terlebih dahulu', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      processOCR();
    } else if (currentStep.value == 3) {
      // Data bisa diisi manual jika OCR tidak sempurna, tidak perlu validasi NIK kosong
      currentStep.value = 4;
    } else if (currentStep.value == 4) {
      if (nominalController.text.isEmpty) {
        Get.snackbar('Error', 'Nominal simpanan harus diisi', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      currentStep.value = 5;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  Future<void> processOCR() async {
    if (ktpImage.value == null) return;

    // Jika data OCR sudah ada dari proses scan kamera, langsung lanjut ke Step 3
    if (_ocrAlreadyProcessed.value) {
      currentStep.value = 3;
      _ocrAlreadyProcessed.value = false; // reset untuk scan berikutnya
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  color: Color(0xFF6B0D0D),
                  strokeWidth: 5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Memproses Dokumen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF6B0D0D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mohon tunggu sebentar, sistem sedang mengekstraksi data KTP Anda...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Kirim gambar ke Backend (PaddleOCR + YOLOv8)
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/ocr'));
      request.files.add(await http.MultipartFile.fromPath('file', ktpImage.value!.path));

      final token = await const FlutterSecureStorage().read(key: 'jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60)); // sama dengan camera_scanner_view.dart
      var response = await http.Response.fromStream(streamedResponse);

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        // Isi form dengan data dari Backend
        nameController.text = data['nama'] ?? "";
        nikController.text = data['nik'] ?? "";
        dobController.text = data['ttl'] ?? "";
        genderController.text = data['jenis_kelamin'] ?? "Laki-laki";
        religionController.text = data['agama'] ?? "";
        addressController.text = data['alamat'] ?? "";
        
        // Validasi dan Duplikat dari backend
        isDuplicate.value = data['is_duplicate'] ?? false;
        duplicateReason.value = data['duplicate_reason'] ?? "";

        // Hitung field yang berhasil terisi
        int filledFields = 0;
        if (nameController.text.isNotEmpty) filledFields++;
        if (nikController.text.isNotEmpty) filledFields++;
        if (dobController.text.isNotEmpty) filledFields++;
        if (addressController.text.isNotEmpty) filledFields++;

        // Tampilkan Dialog Hasil OCR
        Get.defaultDialog(
          title: "Hasil Scan KTP",
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B0D0D)),
          content: Column(
            children: [
              Icon(
                filledFields >= 3 ? Icons.check_circle : Icons.warning_amber_rounded,
                color: filledFields >= 3 ? Colors.green : Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                filledFields >= 3 
                    ? "Berhasil mengekstrak data KTP Anda!" 
                    : "Beberapa data tidak terbaca sempurna. Mohon lengkapi secara manual.",
                textAlign: TextAlign.center,
              ),
              if (isDuplicate.value) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    "⚠️ ${duplicateReason.value}",
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                )
              ]
            ],
          ),
          textConfirm: "Lanjutkan",
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFF6B0D0D),
          onConfirm: () {
            Get.back(); // Tutup dialog
            // Lanjut ke Step 3 — user bisa koreksi manual jika ada yang kurang
            currentStep.value = 3;
          },
        );
      } else if (response.statusCode == 401) {
        await const FlutterSecureStorage().delete(key: 'jwt_token');
        box.write('isLoggedIn', false);
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali.', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Gagal memproses OCR: ${response.body}', 
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Terjadi kesalahan koneksi: $e', 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> submitRegistration() async {
    if (!isAgreed.value) {
      Get.snackbar(
        'Persetujuan Diperlukan',
        'Anda harus menyetujui syarat dan ketentuan sebelum mengajukan pendaftaran.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/member/register'));
      
      final token = await const FlutterSecureStorage().read(key: 'jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Data Identitas & OCR
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['user_id'] = (box.read('userId') ?? "").toString();
      request.fields['nama'] = nameController.text;
      request.fields['nik'] = nikController.text;
      request.fields['ttl'] = dobController.text;
      request.fields['jenis_kelamin'] = genderController.text;
      request.fields['agama'] = religionController.text;
      request.fields['alamat'] = addressController.text;
      
      // Data Simpanan
      request.fields['tipe_simpanan'] = selectedSavingsType.value;
      request.fields['nominal_simpanan'] = nominalController.text;

      // File Dokumen
      if (ktpImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('ktp', ktpImage.value!.path));
      }
      if (kartuAnggotaImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('kartu_anggota', kartuAnggotaImage.value!.path));
      }
      if (pasFotoImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('pas_foto', pasFotoImage.value!.path));
      }
      if (signatureImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('tanda_tangan', signatureImage.value!.path));
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      var response = await http.Response.fromStream(streamedResponse);

      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan status pendaftaran secara lokal
        box.write('registration_status', 'pending');
        
        _showSuccessDialog();
      } else if (response.statusCode == 401) {
        await const FlutterSecureStorage().delete(key: 'jwt_token');
        box.write('isLoggedIn', false);
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali.', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal Daftar', 'Terjadi kesalahan: ${response.body}', 
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error Koneksi', 'Gagal menghubungi server: $e', 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pendaftaran Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF6B0D0D)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data Anda telah berhasil diajukan dan sedang dalam proses verifikasi oleh tim kami.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.offAllNamed(Routes.DASHBOARD_STATUS); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B0D0D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Ke Dashboard Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verifikasi Email', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.mark_email_read_outlined, size: 80, color: const Color(0xFF6B0D0D)),
              const SizedBox(height: 24),
              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami telah mengirimkan 6 digit kode OTP ke email:\n${controller.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "000000",
                  hintStyle: const TextStyle(color: Colors.black26, letterSpacing: 8),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B0D0D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Verifikasi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum menerima kode? ', style: TextStyle(color: Colors.black54)),
                  Obx(() => GestureDetector(
                    onTap: controller.countdown.value > 0 ? null : controller.resendOtp,
                    child: Text(
                      controller.countdown.value > 0 
                          ? 'Tunggu ${controller.countdown.value} detik'
                          : 'Kirim Ulang',
                      style: TextStyle(
                        color: controller.countdown.value > 0 ? Colors.grey : const Color(0xFF6B0D0D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

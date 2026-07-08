import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Spacer(),

              // Logo besar dan nama koperasi
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo_koperasi.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'KOPERASI SIMPANKU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B0000),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B0000),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              
              // Text Content
              Text(
                'splash_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'splash_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.SIGNUP),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'daftar_sekarang'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.LOGIN),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B0000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6B0000)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'masuk'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                  children: [
                    TextSpan(text: 'dengan_melanjutkan'.tr),
                    TextSpan(
                      text: 'syarat_ketentuan'.tr,
                      style: const TextStyle(
                        color: Color(0xFF6B0000),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: 'serta'.tr),
                    TextSpan(
                      text: 'kebijakan_privasi'.tr,
                      style: const TextStyle(
                        color: Color(0xFF6B0000),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: 'kami'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

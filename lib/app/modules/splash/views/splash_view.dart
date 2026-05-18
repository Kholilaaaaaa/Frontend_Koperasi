import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF6B0000),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'KOPERASI SIMPANAN\nHARKAT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B0000),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Illustration placeholder
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B0000).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B0000).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF6F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const Icon(
                      Icons.trending_up,
                      size: 80,
                      color: Color(0xFF6B0000),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Text Content
              const Text(
                'Aman, Transparan, Mudah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Solusi finansial yang memberdayakan setiap langkah Anda dalam mencapai pertumbuhan.',
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
                child: const Text(
                  'Daftar Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                  children: [
                    TextSpan(text: 'Dengan melanjutkan, Anda menyetujui '),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: TextStyle(
                        color: Color(0xFF6B0000),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' serta '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: TextStyle(
                        color: Color(0xFF6B0000),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' kami.'),
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

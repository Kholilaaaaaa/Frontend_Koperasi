import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import '../../../routes/app_routes.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6B0D0D);
    final bgColor = const Color(0xFFFFF9F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              IconButton(
                icon: Icon(Icons.arrow_back, color: themeColor),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mulai perjalanan finansial Anda bersama Heritage Ledger.',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Full Name
              _buildLabel('NAMA LENGKAP'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.nameController,
                hintText: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Email
              _buildLabel('EMAIL ATAU TELEPON'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.emailOrPhoneController,
                hintText: 'nama@email.com',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 20),

              // Password
              _buildLabel('PASSWORD'),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.passwordController,
                hintText: '********',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !controller.isPasswordVisible.value,
                onToggle: controller.togglePasswordVisibility,
              )),
              const SizedBox(height: 20),

              // Confirm Password
              _buildLabel('KONFIRMASI PASSWORD'),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.confirmPasswordController,
                hintText: '********',
                icon: Icons.lock_reset,
                isPassword: true,
                obscureText: !controller.isConfirmPasswordVisible.value,
                onToggle: controller.toggleConfirmPasswordVisibility,
              )),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Daftar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () => Get.offNamed(Routes.LOGIN),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        const TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: Colors.black38),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, size: 20, color: Colors.black38),
              onPressed: onToggle,
            )
          : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6B0D0D)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

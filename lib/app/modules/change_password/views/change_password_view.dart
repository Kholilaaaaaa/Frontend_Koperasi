import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF6B0D0D);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(themeColor),
              const SizedBox(height: 24),
              const Text(
                'Ubah Kata Sandi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan kata sandi baru Anda kuat dan mudah diingat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              
              // Old Password
              _buildLabel('KATA SANDI LAMA', themeColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.oldPasswordController,
                isVisible: controller.isOldPasswordVisible.value,
                onToggle: () => controller.isOldPasswordVisible.toggle(),
                hint: 'Masukkan kata sandi saat ini',
              )),
              const SizedBox(height: 24),

              // New Password
              _buildLabel('KATA SANDI BARU', themeColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.newPasswordController,
                isVisible: controller.isNewPasswordVisible.value,
                onToggle: () => controller.isNewPasswordVisible.toggle(),
                hint: 'Masukkan kata sandi baru',
              )),
              const SizedBox(height: 24),

              // Confirm Password
              _buildLabel('KONFIRMASI KATA SANDI BARU', themeColor),
              const SizedBox(height: 8),
              Obx(() => _buildPasswordField(
                controller: controller.confirmPasswordController,
                isVisible: controller.isConfirmPasswordVisible.value,
                onToggle: () => controller.isConfirmPasswordVisible.toggle(),
                hint: 'Ulangi kata sandi baru',
              )),
              const SizedBox(height: 40),
              
              // Submit Button
              ElevatedButton(
                onPressed: controller.submitChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color color) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: color, size: 20),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.black38,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

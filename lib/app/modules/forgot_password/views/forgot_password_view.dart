import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  static const themeColor = Color(0xFF6B0D0D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              Obx(() {
                switch (controller.step.value) {
                  case 1:
                    return _buildRequestOtpStep();
                  case 2:
                    return _buildVerifyOtpStep();
                  case 3:
                    return _buildResetPasswordStep();
                  default:
                    return _buildRequestOtpStep();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: themeColor, size: 20),
          onPressed: () {
            if (controller.step.value > 1) {
              controller.step.value--;
            } else {
              Get.back();
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildRequestOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Lupa Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan email Anda untuk menerima kode OTP verifikasi reset password.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        
        // Email Field
        _buildLabel('EMAIL'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            hint: 'nama@email.com',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 32),
        
        // Submit Button
        ElevatedButton(
          onPressed: controller.sendOtp,
          style: _buildButtonStyle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Kirim Kode OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.send_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Verifikasi OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan 6 digit kode OTP yang telah dikirim ke email: ${controller.emailController.text}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        
        // OTP Field
        _buildLabel('KODE OTP'),
        const SizedBox(height: 8),
        TextField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: _buildInputDecoration(
            hint: '000000',
            icon: Icons.lock_open_rounded,
          ).copyWith(counterText: ""),
        ),
        const SizedBox(height: 32),
        
        // Verify Button
        ElevatedButton(
          onPressed: controller.verifyOtp,
          style: _buildButtonStyle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Verifikasi Kode OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.verified_user_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Silakan buat kata sandi baru untuk akun Anda.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        
        // New Password Field
        _buildLabel('KATA SANDI BARU'),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller.newPasswordController,
          obscureText: !controller.isNewPasswordVisible.value,
          decoration: _buildInputDecoration(
            hint: 'Masukkan kata sandi baru',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                controller.isNewPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
                size: 20,
              ),
              onPressed: () => controller.isNewPasswordVisible.toggle(),
            ),
          ),
        )),
        const SizedBox(height: 24),
        
        // Confirm Password Field
        _buildLabel('KONFIRMASI KATA SANDI BARU'),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller.confirmPasswordController,
          obscureText: !controller.isConfirmPasswordVisible.value,
          decoration: _buildInputDecoration(
            hint: 'Konfirmasi kata sandi baru',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
                size: 20,
              ),
              onPressed: () => controller.isConfirmPasswordVisible.toggle(),
            ),
          ),
        )),
        const SizedBox(height: 40),
        
        // Submit Button
        ElevatedButton(
          onPressed: controller.resetPassword,
          style: _buildButtonStyle(),
          child: const Text(
            'Simpan Sandi Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: themeColor,
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: themeColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    );
  }
}

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
              _buildTopBar(themeColor),
              const SizedBox(height: 24),
              
              Text(
                'buat_akun_baru'.tr,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'mulai_perjalanan_finansial'.tr,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildLabel('nama_lengkap'.tr),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.nameController,
                hintText: 'hint_nama_lengkap'.tr,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel('email_atau_telepon'.tr),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.emailOrPhoneController,
                hintText: 'hint_email_telepon'.tr,
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel('password'.tr),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.passwordController,
                hintText: 'hint_password'.tr,
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !controller.isPasswordVisible.value,
                onToggle: controller.togglePasswordVisibility,
              )),
              const SizedBox(height: 20),

              _buildLabel('konfirmasi_password'.tr),
              const SizedBox(height: 8),
              Obx(() => _buildTextField(
                controller: controller.confirmPasswordController,
                hintText: 'hint_password'.tr,
                icon: Icons.lock_reset,
                isPassword: true,
                obscureText: !controller.isConfirmPasswordVisible.value,
                onToggle: controller.toggleConfirmPasswordVisibility,
              )),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'daftar_sekarang'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                )),
              ),
              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau_daftar_dengan'.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black38,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black12)),
                ],
              ),
              const SizedBox(height: 24),

              // Google Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.signupWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _GoogleLogo(size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'daftar_google'.tr,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                        TextSpan(text: 'sudah_punya_akun'.tr),
                        TextSpan(
                          text: 'masuk'.tr,
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

  Widget _buildTopBar(Color themeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B0000), size: 20),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logo_koperasi.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'KOPERASI SIMPANKU',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF6B0D0D),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      
      ],
    );
  }
}

// ── Google Logo Widget (4 warna asli) ─────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeW = size.width * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeW / 2);

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(rect, start, sweep, false,
          Paint()..color = color..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.butt);
    }

    const pi = 3.14159265;
    arc(const Color(0xFFEA4335), -pi * 0.22, pi * 0.72); // Merah
    arc(const Color(0xFFFBBC05), pi * 0.50, pi * 0.5);  // Kuning
    arc(const Color(0xFF34A853), pi * 1.00, pi * 0.5);  // Hijau
    arc(const Color(0xFF4285F4), pi * 1.50, pi * 0.78); // Biru

    // Garis horizontal khas Google
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - strokeW * 0.3, center.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

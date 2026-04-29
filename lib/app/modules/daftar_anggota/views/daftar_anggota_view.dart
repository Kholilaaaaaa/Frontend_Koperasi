import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daftar_anggota_controller.dart';
import '../../../routes/app_routes.dart';

class DaftarAnggotaView extends GetView<DaftarAnggotaController> {
  const DaftarAnggotaView({Key? key}) : super(key: key);

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
              // Header Logo
              Row(
                children: [
                  Icon(Icons.account_balance, color: themeColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Heritage Ledger',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Step Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LANGKAH 1 DARI 3',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Daftar Anggota\nKoperasi',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Bergabunglah dengan Koperasi Simpanan Sukarela untuk masa depan finansial yang lebih stabil.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              _buildLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.emailController,
                hintText: 'nama@email.com',
              ),
              const SizedBox(height: 24),

              // Phone Field
              _buildLabel('PHONE NUMBER'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '+62',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: controller.phoneController,
                      hintText: '812 3456 7890',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Terms Text
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                  children: [
                    const TextSpan(text: 'Dengan melanjutkan, Anda menyetujui '),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' serta Kebijakan Privasi kami.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Lanjut Ke Verifikasi Dokumen',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Footer Link
              Center(
                child: GestureDetector(
                  onTap: () => Get.offAllNamed(Routes.VISITOR_DASHBOARD),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        const TextSpan(text: 'Sudah memiliki akun? '),
                        TextSpan(
                          text: 'Masuk ke Dashboard',
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6B0D0D)),
        ),
      ),
    );
  }
}

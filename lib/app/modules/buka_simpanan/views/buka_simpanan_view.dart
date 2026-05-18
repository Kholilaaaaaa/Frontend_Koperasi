import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/buka_simpanan_controller.dart';
import '../../../routes/app_routes.dart';

class BukaSimpananView extends GetView<BukaSimpananController> {
  const BukaSimpananView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);
  static const cardColor = Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
            const Text(
              'LAYANAN KEANGGOTAAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buka Simpanan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mulai perjalanan finansial Anda bersama Koperasi dengan membuka rekening simpanan baru yang aman dan menguntungkan.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Promo Card
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1580519542036-c47de6196ba5?auto=format&fit=crop&q=80&w=600'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'IMBAL JASA HINGGA',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '7.5% per Annum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Form
            _buildLabel('JENIS SIMPANAN'),
            _buildDropdown(
              value: controller.jenisSimpanan,
              items: controller.daftarSimpanan,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('NOMINAL SIMPANAN PERTAMA'),
            _buildTextField(
              controller: controller.nominalController,
              hint: '0',
              prefix: 'Rp ',
              helper: 'Minimal setoran pertama Rp 100.000',
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            _buildLabel('NOMOR REKENING'),
            _buildTextField(
              controller: controller.nomorRekeningController,
              hint: 'Masukkan nomor rekening sumber',
            ),
            
            const SizedBox(height: 24),
            _buildLabel('PILIH BANK'),
            _buildDropdown(
              value: controller.selectedBank,
              items: controller.daftarBank,
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submitBukaSimpanan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Buka Simpanan Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Center(
              child: Text.rich(
                TextSpan(
                  text: 'Dengan menekan tombol di atas, Anda menyetujui ',
                  style: TextStyle(fontSize: 10, color: Colors.black45),
                  children: [
                    TextSpan(
                      text: 'Syarat \n & Ketentuan',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' pembukaan rekening Koperasi Simpanan Harkat.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Info Cards
            Row(
              children: [
                Expanded(child: _buildInfoCard(
                  Icons.verified_user, 
                  'Keamanan Terjamin', 
                  'Dana Anda dikelola dengan transparansi penuh dan dilindungi oleh sistem keamanan berlapis.',
                  null
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(
                  Icons.trending_up, 
                  'Pertumbuhan', 
                  null,
                  'Solid'
                )),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: themeColor, size: 20),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: themeColor.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.account_balance, color: themeColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'KOPERASI SIMPANAN HARKAT',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.NOTIFIKASI),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_outlined, color: themeColor, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: themeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown({required RxString value, required List<String> items}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: themeColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => value.value = val!,
        ),
      ),
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? helper,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixText: prefix,
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          Text(helper, style: const TextStyle(fontSize: 10, color: Colors.black26, fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String? subtitle, String? highlight) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: themeColor, size: 24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black45, height: 1.4)),
          ],
          if (highlight != null) ...[
            const Spacer(),
            Text(highlight, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: themeColor)),
          ],
        ],
      ),
    );
  }
}

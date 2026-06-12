import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'camera_scanner_view.dart';

class ScannerInstructionsView extends StatelessWidget {
  final String documentType;
  
  const ScannerInstructionsView({Key? key, required this.documentType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Siapkan Kartu identitas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda memerlukan kartu identitas fisik yang asli.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              
              // Main illustration (Mock)
              Container(
                width: 200,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(Icons.badge, size: 80, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 48),
              
              // 3 bad examples
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadExample(Icons.crop, 'Tidak\nterpangkas'),
                  _buildBadExample(Icons.blur_on, 'Tidak buram'),
                  _buildBadExample(Icons.wb_sunny_outlined, 'Tidak ada silau'),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Bullet points
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Pastikan kartu identitas Anda:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('• Bukan fotokopian atau salinan cetak', style: TextStyle(height: 1.5)),
                    Text('• Tidak kedaluwarsa', style: TextStyle(height: 1.5)),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Navigate to Camera, and wait for result
                    final result = await Get.to(() => CameraScannerView(documentType: documentType));
                    if (result != null) {
                      // Pop back to Daftar Anggota view with the image path
                      Get.back(result: result);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2B5E), // Pinkish red
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Berikutnya', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadExample(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 60,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(icon, color: Colors.grey[400])),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

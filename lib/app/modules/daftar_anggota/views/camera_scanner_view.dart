import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:http/http.dart' as http;

import 'package:pattern_getx_cli/app/network/api_client.dart';

class CameraScannerView extends StatefulWidget {
  final String documentType;
  const CameraScannerView({Key? key, required this.documentType}) : super(key: key);

  @override
  _CameraScannerViewState createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  DocumentScanner? _documentScanner;

  // Proses ke Backend
  bool _isAnalyzingBackend = false;
  bool _showResult = false;
  bool _isKtpValidBackend = false;
  String _croppedImagePath = '';
  Map<String, dynamic> _ocrData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    final options = DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg},
      mode: ScannerMode.base,
      pageLimit: 1,
      isGalleryImport: true,
    );
    _documentScanner = DocumentScanner(options: options);
    
    // Automatically launch scanner when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDocumentScan();
    });
  }

  Future<void> _startDocumentScan() async {
    if (_isAnalyzingBackend) return;

    try {
      final result = await _documentScanner?.scanDocument();
      if (result != null && result.images != null && result.images!.isNotEmpty) {
        final croppedPath = result.images!.first;
        if (mounted) {
          setState(() {
            _isAnalyzingBackend = true;
            _croppedImagePath = croppedPath;
            _showResult = false; // Sembunyikan hasil lama jika ada
          });
        }

        // Kirim gambar yang sudah di-crop sempurna oleh native scanner ke backend OCR Flask
        final ocrResult = await _sendToBackendOcr(croppedPath);

        if (mounted) {
          setState(() {
            _ocrData = ocrResult;
            // Gunakan validasi langsung dari Backend sesuai kontrak API terbaru
            _isKtpValidBackend = ocrResult['nik_valid'] == true;
            
            if (!_isKtpValidBackend) {
              _errorMessage = ocrResult['nik_validation_message'] ?? 'Data tidak terbaca dengan baik.';
              
              // TAMPILKAN DIALOG ENTERPRISE JIKA GAGAL
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                      SizedBox(width: 10),
                      Text("Foto Kurang Jelas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: Text(
                    "Kami kesulitan membaca data KTP Anda.\n\nDetail: $_errorMessage\n\nMohon pastikan KTP berada di tempat yang terang, tidak silau, dan tulisan terbaca jelas.",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        // Biarkan user melihat layar hasil merah untuk opsi manual jika mereka mau
                      },
                      child: const Text("Isi Manual", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B0D0D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        _resetScanner(); // Buka kamera otomatis
                      },
                      child: const Text("Foto Ulang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                barrierDismissible: false, // Wajib pilih salah satu aksi
              );

            } else {
              _errorMessage = '';
            }

            _isAnalyzingBackend = false;
            _showResult = true;
          });
        }
      } else {
        // User membatalkan proses scan (menekan tombol back di scanner)
        Get.back();
      }
    } catch (e) {
      debugPrint("Scanner Error: $e");
      if (mounted) {
        setState(() {
          _isAnalyzingBackend = false;
          _showResult = true;
          _isKtpValidBackend = false;
          _errorMessage = 'Gagal memproses dokumen: $e';
        });
      }
    }
  }

  Future<Map<String, dynamic>> _sendToBackendOcr(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/ocr'));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var streamed = await request.send().timeout(const Duration(seconds: 90));
      var response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Server Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  void _resetScanner() {
    setState(() {
      _showResult = false;
      _isAnalyzingBackend = false;
    });
    _startDocumentScan();
  }

  @override
  void dispose() {
    _documentScanner?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background saat scanner native tertutup atau sedang loading
          Center(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const CircularProgressIndicator(color: Colors.white),
                 const SizedBox(height: 16),
                 const Text('Menyiapkan Pemindai Dokumen...', style: TextStyle(color: Colors.white70)),
               ],
             ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
          ),

          // 7. Loading Backend
          if (_isAnalyzingBackend)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 4),
                  SizedBox(height: 24),
                  Text('Memproses KTP...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Mengekstrak data dan cek duplikasi ke server', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ]),
              ),
            ),

          // 8. Overlay Hasil Akhir
          if (_showResult) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(children: [
            const Text('HASIL VALIDASI KTP', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            // Gambar KTP hasil crop
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isKtpValidBackend ? Colors.green : Colors.red, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _croppedImagePath.isNotEmpty
                      ? Image.file(File(_croppedImagePath), fit: BoxFit.contain)
                      : Container(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kartu Informasi Hasil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Icon(_isKtpValidBackend ? Icons.check_circle : Icons.cancel, color: _isKtpValidBackend ? Colors.green : Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isKtpValidBackend ? 'KTP Berhasil Dibaca' : 'KTP Tidak Terbaca',
                      style: TextStyle(color: _isKtpValidBackend ? Colors.green[800] : Colors.red[800], fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
                const Divider(height: 24, thickness: 1.5),

                if (_isKtpValidBackend) ...[
                  _infoRow('NIK', _ocrData['nik'] ?? '-'),
                  _infoRow('Nama', _ocrData['nama'] ?? '-'),
                  const SizedBox(height: 12),
                  const Text('Data berhasil diekstrak otomatis. Lanjutkan untuk verifikasi.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                ] else ...[
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(fontSize: 13, color: Colors.red)),
                  const Text('Sebab: Foto KTP kurang jelas atau bukan KTP asli.', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  const Text('Silakan scan ulang, atau lanjutkan untuk mengisi data manual.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                ],

                const SizedBox(height: 24),

                // Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: {'path': _croppedImagePath, 'ocr_data': _ocrData});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isKtpValidBackend ? Colors.green : const Color(0xFF6B0D0D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _isKtpValidBackend ? 'Gunakan Foto Ini' : 'Lanjutkan & Isi Manual',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetScanner,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    child: const Text('Scan Ulang', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 55, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87))),
      ]),
    );
  }
}

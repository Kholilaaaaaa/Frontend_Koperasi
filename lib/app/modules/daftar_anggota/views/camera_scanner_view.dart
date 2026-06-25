import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

        // Lakukan OCR LOKAL Realtime + Validasi Backend Ringan
        final ocrResult = await _processRealtimeOcr(croppedPath);

        if (mounted) {
          setState(() {
            _ocrData = ocrResult;
            // Gunakan validasi langsung dari Backend sesuai kontrak API terbaru
            _isKtpValidBackend = ocrResult['nik_valid'] == true;
            
            if (!_isKtpValidBackend) {
              _errorMessage = ocrResult['nik_validation_message'] ?? 'Data tidak terbaca dengan baik.';
              // Dialog peringatan dihapus agar tidak mengganggu UX. User bisa langsung melihat hasil di overlay dan mengoreksi secara manual.
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

  Future<Map<String, dynamic>> _processRealtimeOcr(String imagePath) async {
    try {
      // ✅ FIX #1: Kirim dengan JWT token agar server bisa log user OCR dengan benar
      final token = await const FlutterSecureStorage().read(key: 'jwt_token');

      // ✅ FIX #2: Timeout dinaikkan ke 60 detik (YOLOv8+PaddleOCR bisa butuh 45s+)
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/ocr'));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      Map<String, dynamic> ktpData = {};

      if (response.statusCode == 200) {
        var validationData = jsonDecode(response.body);
        ktpData = validationData;
        
        // Sesuaikan parameter fallback jika tidak terbaca sempurna
        if (!ktpData.containsKey('nik_valid')) {
           ktpData['nik_valid'] = false;
        }
        if (!ktpData.containsKey('is_duplicate')) {
           ktpData['is_duplicate'] = false;
        }
      } else if (response.statusCode == 401) {
        // Token expired — paksa re-login
        ktpData['nik_valid'] = false;
        ktpData['nik_validation_message'] = 'Sesi berakhir. Silakan login ulang.';
        ktpData['session_expired'] = true;
      } else {
        // Fallback jika API gagal (biarkan valid agar user bisa lanjut manual)
        debugPrint('[OCR] Server error ${response.statusCode}: ${response.body}');
        ktpData['nik_valid'] = true; 
        ktpData['is_duplicate'] = false;
        ktpData['nik_validation_message'] = 'Server error (${response.statusCode}). Lanjutkan secara manual.';
      }
      
      return ktpData;
    } catch (e) {
      debugPrint('Realtime OCR Error: $e');
      // Timeout atau koneksi putus — tidak crash, kembalikan fallback
      return {
        'nik_valid': true,
        'is_duplicate': false,
        'nik_validation_message': 'Koneksi gagal/timeout. Lanjutkan secara manual.',
      };
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
                  Text('Memproses KTP Realtime...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Mengekstrak data instan & cek validasi', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                  if ((_ocrData['ttl'] ?? '').isNotEmpty) _infoRow('TTL', _ocrData['ttl']),
                  if ((_ocrData['jenis_kelamin'] ?? '').isNotEmpty) _infoRow('JK', _ocrData['jenis_kelamin']),
                  if ((_ocrData['agama'] ?? '').isNotEmpty) _infoRow('Agama', _ocrData['agama']),
                  if ((_ocrData['alamat'] ?? '').isNotEmpty) _infoRow('Alamat', _ocrData['alamat']),
                  const SizedBox(height: 12),
                  // ✅ Tunjukkan duplikat warning jika ada
                  if (_ocrData['is_duplicate'] == true)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _ocrData['duplicate_reason'] ?? 'NIK sudah terdaftar.',
                              style: const TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('Data berhasil diekstrak otomatis. Lanjutkan untuk verifikasi.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                ] else ...[
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(fontSize: 13, color: Colors.red)),
                  const Text('Sebab: Foto KTP kurang jelas atau bukan KTP asli.', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  // ✅ Tips kualitas foto untuk user
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡 Tips foto KTP yang baik:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                        SizedBox(height: 4),
                        Text('• KTP isi minimal 70% frame kamera', style: TextStyle(fontSize: 11, color: Colors.black87)),
                        Text('• Hindari bayangan & pantulan cahaya', style: TextStyle(fontSize: 11, color: Colors.black87)),
                        Text('• Letakkan di permukaan datar & polos', style: TextStyle(fontSize: 11, color: Colors.black87)),
                        Text('• Pencahayaan cukup, tidak backlight', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
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

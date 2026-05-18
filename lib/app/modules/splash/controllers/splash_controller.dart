import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../routes/app_routes.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Memberikan delay sedikit untuk efek splash screen
    await Future.delayed(Duration(seconds: 2));

    bool isLoggedIn = box.read('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Cek status member sebelum navigasi
      await _checkMemberStatusAndRoute();
    } else {
      // Jika belum login, ke halaman Login
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _checkMemberStatusAndRoute() async {
    try {
      final userId = box.read('userId');
      print("DEBUG SPLASH: Checking status for userId: $userId");

      if (userId == null) {
        print("DEBUG SPLASH: UserId is missing! Redirecting to LOGIN for re-sync.");
        // Jika ID hilang tapi status isLoggedIn=true, paksa login ulang untuk ambil ID
        Get.offAllNamed(Routes.LOGIN);
        return;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/member/status/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] ?? 'not_started').toString().toLowerCase();
        
        print("DEBUG SPLASH: Received Status from Server -> $status");

        if (status == 'approved' || status == 'disetujui' || status == 'aktif' || status == 'acc' || status == 'diterima') {
          print("DEBUG SPLASH: Status Approved -> Routes.MEMBER_DASHBOARD");
          Get.offAllNamed(Routes.MEMBER_DASHBOARD);
        } else if (status == 'pending' || status == 'menunggu') {
          print("DEBUG SPLASH: Status Pending -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else if (status == 'rejected' || status == 'ditolak') {
          print("DEBUG SPLASH: Status Rejected -> Routes.DASHBOARD_STATUS");
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        } else {
          // Default for 'not_started' or unknown
          print("DEBUG SPLASH: Status '$status' -> Routes.VISITOR_DASHBOARD");
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        }
      } else {
        print("DEBUG SPLASH: Server error ${response.statusCode}. Fallback to LOGIN.");
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print("DEBUG SPLASH: Connection Error -> $e");
      Get.snackbar('Koneksi Gagal', 'Pastikan server aktif di $baseUrl');
      Get.offAllNamed(Routes.LOGIN);
    }
  }


  @override
  void onClose() {}
}

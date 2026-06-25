import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../../routes/app_routes.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';

class DashboardStatusController extends GetxController {
  final box = GetStorage();
  var userName = 'Pengguna'.obs;
  var userAvatarPath = ''.obs;
  
  var status = 'pending'.obs; // 'pending', 'approved', 'rejected'
  var rejectionReason = ''.obs;
  var isLoading = true.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    userName.value = box.read('userName') ?? 'Pengguna';
    userAvatarPath.value = box.read('userAvatarPath') ?? '';
    fetchStatus();
    _startPolling();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (status.value == 'pending') {
        fetchStatus(showLoading: false);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> fetchStatus({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final userId = box.read('userId');
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/member/status/$userId'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        status.value = (data['status'] ?? 'pending').toString().toLowerCase();
        
        // Update userName if available from server
        if (data['full_name'] != null) {
          userName.value = data['full_name'];
          box.write('userName', data['full_name']);
        }
        if (data['member_id'] != null) {
          box.write('memberId', data['member_id']);
        }
        if (data['avatar_path'] != null) {
          userAvatarPath.value = data['avatar_path'];
          box.write('userAvatarPath', data['avatar_path']);
        }
        if (data['address'] != null) {
          box.write('userAddress', data['address']);
        }
        if (data['phone'] != null) {
          box.write('userPhone', data['phone']);
        }
        
        if (status.value == 'rejected' && data['registration_details'] != null) {
          rejectionReason.value = data['registration_details']['rejection_reason'] ?? '';
        } else {
          rejectionReason.value = data['reason'] ?? '';
        }

        if (status.value == 'approved' || status.value == 'disetujui' || status.value == 'aktif' || status.value == 'acc' || status.value == 'diterima') {
          print("DEBUG STATUS_POLLING: Status MATCHED (Approved/ACC)! Navigating to Member Dashboard...");
          _timer?.cancel();
          Get.offAllNamed(Routes.MEMBER_DASHBOARD);
        } else if (status.value == 'rejected' || status.value == 'ditolak') {
          print("DEBUG STATUS_POLLING: Status Rejected. Stopping poll.");
          _timer?.cancel();
        } else if (status.value == 'pending' || status.value == 'menunggu') {
          print("DEBUG STATUS_POLLING: Status still pending...");
        } else if (status.value == 'not_started') {
          print("DEBUG STATUS_POLLING: Status not_started. Redirecting to Visitor Dashboard.");
          _timer?.cancel();
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        } else {
          print("DEBUG STATUS_POLLING: Unknown status '${status.value}'. Stopping poll.");
          _timer?.cancel();
        }
      }
    } catch (e) {
      print('Error fetching status: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void retryRegistration() {
    Get.toNamed(Routes.DAFTAR_ANGGOTA);
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pattern_getx_cli/app/network/api_client.dart';
import '../../dashboard_status/controllers/dashboard_status_controller.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';

class ProfileController extends GetxController {
  var name = "Budi Santoso".obs;
  var email = "budi.santoso@email.com".obs;
  var phone = "081234567890".obs;
  var address = "Jl. Sudirman No. 123, Jakarta".obs;
  var memberId = "#KS-B8291".obs;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController memberIdController;
  final box = GetStorage();
  var avatarPath = ''.obs;
  
  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Semua kolom wajib diisi.', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D0D))),
      barrierDismissible: false,
    );

    try {
      final Map<String, String> fields = {
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
      };

      final response = await authorizedMultipartPost(
        endpoint: '/api/member/update-profile',
        fields: fields,
        fileKey: 'avatar',
        filePath: avatarPath.value,
      );

      Get.back(); // Close loading dialog

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        name.value = nameController.text.trim();
        email.value = emailController.text.trim();
        phone.value = phoneController.text.trim();
        address.value = addressController.text.trim();
        memberId.value = memberIdController.text.trim();
        
        box.write('userName', name.value);
        box.write('userEmail', email.value);
        box.write('userPhone', phone.value);
        box.write('userAddress', address.value);
        
        if (data['avatar_path'] != null) {
          avatarPath.value = data['avatar_path'];
          box.write('userAvatarPath', data['avatar_path']);
        }

        try {
          if (Get.isRegistered<DashboardStatusController>()) {
            final ds = Get.find<DashboardStatusController>();
            ds.userName.value = name.value;
            if (ds.userAvatarPath != null) {
              ds.userAvatarPath.value = avatarPath.value;
            }
          }
        } catch (_) {}

        try {
          if (Get.isRegistered<MemberDashboardController>()) {
            final mdc = Get.find<MemberDashboardController>();
            mdc.refreshUserDetails();
          }
        } catch (_) {}

        Get.back(); // Return to settings page

        Get.snackbar(
          'Sukses', 
          'Profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF6B0D0D),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal', 
          data['error'] ?? 'Gagal memperbarui profil.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error', 
        'Gagal menghubungi server: $e', 
        backgroundColor: Colors.orange, 
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    // initialize from storage if available
    name.value = box.read('userName') ?? name.value;
    email.value = box.read('userEmail') ?? email.value;
    phone.value = box.read('userPhone') ?? phone.value;
    address.value = box.read('userAddress') ?? address.value;
    memberId.value = box.read('memberId') ?? memberId.value;
    avatarPath.value = box.read('userAvatarPath') ?? '';

    nameController = TextEditingController(text: name.value);
    emailController = TextEditingController(text: email.value);
    phoneController = TextEditingController(text: phone.value);
    addressController = TextEditingController(text: address.value);
    memberIdController = TextEditingController(text: memberId.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    memberIdController.dispose();
    super.onClose();
  }

  Future<void> pickAvatarImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      avatarPath.value = file.path;
      await box.write('userAvatarPath', file.path);
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}

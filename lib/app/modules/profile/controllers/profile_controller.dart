import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../dashboard_status/controllers/dashboard_status_controller.dart';

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
  
  void saveProfile() {
    // Update reactive values from controllers
    name.value = nameController.text.trim();
    email.value = emailController.text.trim();
    phone.value = phoneController.text.trim();
    address.value = addressController.text.trim();
    memberId.value = memberIdController.text.trim();
    // persist to local storage so other parts of the app can read updated values
    box.write('userName', name.value);
    box.write('userEmail', email.value);
    box.write('userPhone', phone.value);
    box.write('userAddress', address.value);
    box.write('memberId', memberId.value);
    // ensure avatar path also persisted (pickAvatarImage also writes it)
    if (avatarPath.value.isNotEmpty) {
      box.write('userAvatarPath', avatarPath.value);
    }

    // Also update DashboardStatusController if it's in memory
    try {
      if (Get.isRegistered()) {
        // attempt to find DashboardStatusController by type if present
        if (Get.isRegistered<DashboardStatusController>()) {
          final ds = Get.find<DashboardStatusController>();
          ds.userName.value = name.value;
          // update avatar path on dashboard controller as well
          if (ds.userAvatarPath != null) {
            ds.userAvatarPath.value = avatarPath.value;
          }
        }
      }
    } catch (_) {}

    // Close the page
    Get.back();
    Get.snackbar(
      'Sukses', 
      'Profil berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B0D0D),
      colorText: Colors.white,
    );
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

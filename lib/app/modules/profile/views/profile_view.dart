import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static Color getBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBgColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: themeColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'edit_profil'.tr,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor, 
            fontWeight: FontWeight.w900, 
            fontSize: 18
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 40),
            _buildEditForm(context),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: themeColor.withAlpha(51), width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: themeColor.withAlpha(25),
              child: Obx(() {
                  final path = controller.avatarPath.value;
                  if (path.isNotEmpty) {
                    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: isNetwork 
                        ? NetworkImage(path) as ImageProvider
                        : FileImage(File(path)),
                      backgroundColor: Colors.transparent,
                    );
                  }
                  final encoded = Uri.encodeComponent(controller.name.value);
                  final url = 'https://ui-avatars.com/api/?name=$encoded&background=6B0D0D&color=fff';
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(url),
                    backgroundColor: Colors.transparent,
                  );
                }),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
              child: GestureDetector(
                onTap: () => controller.pickAvatarImage(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          context: context,
          label: 'nama_lengkap'.tr,
          icon: Icons.person_outline,
          controller: controller.nameController,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'email'.tr,
          icon: Icons.mail_outline,
          controller: controller.emailController,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'nomor_telepon'.tr,
          icon: Icons.phone_android_outlined,
          controller: controller.phoneController,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'alamat'.tr,
          icon: Icons.location_on_outlined,
          controller: controller.addressController,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'id_anggota'.tr,
          icon: Icons.badge_outlined,
          controller: controller.memberIdController,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withAlpha(13)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: enabled 
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black26)
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: themeColor.withAlpha(128), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () => controller.saveProfile(),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: themeColor.withAlpha(102),
      ),
      child: Text(
        'simpan_perubahan'.tr,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

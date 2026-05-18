import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          'Edit Profil',
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
              backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=Budi+Santoso&background=6B0D0D&color=fff'),
              backgroundColor: themeColor.withAlpha(25),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
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
          label: 'NAMA LENGKAP',
          icon: Icons.person_outline,
          controller: TextEditingController(text: controller.name.value),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'EMAIL',
          icon: Icons.mail_outline,
          controller: TextEditingController(text: controller.email.value),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'NOMOR TELEPON',
          icon: Icons.phone_android_outlined,
          controller: TextEditingController(text: controller.phone.value),
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'ALAMAT',
          icon: Icons.location_on_outlined,
          controller: TextEditingController(text: controller.address.value),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          context: context,
          label: 'ID ANGGOTA',
          icon: Icons.badge_outlined,
          controller: TextEditingController(text: controller.memberId.value),
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
      child: const Text(
        'Simpan Perubahan',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

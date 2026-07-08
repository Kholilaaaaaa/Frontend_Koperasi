import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifikasi_controller.dart';
import 'package:collection/collection.dart' as coll;
class NotifikasiView extends GetView<NotifikasiController> {
  const NotifikasiView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const bgColor = Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: themeColor));
          }
          if (controller.errorMessage.isNotEmpty && controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage.value, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.fetchNotifications(),
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    child: Text('coba_lagi'.tr, style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.black26),
                  const SizedBox(height: 16),
                  Text('tidak_ada_notifikasi'.tr, style: const TextStyle(color: Colors.black38, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.fetchNotifications(),
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    child: Text('refresh'.tr, style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: themeColor,
            onRefresh: () => controller.fetchNotifications(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'notifikasi'.tr,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: themeColor, height: 1.1),
                        ),
                      ),
                      if (controller.unreadCount.value > 0)
                        TextButton.icon(
                          onPressed: () => controller.markAllAsRead(),
                          icon: const Icon(Icons.done_all, size: 16, color: themeColor),
                          label: Text(
                            'tandai_dibaca'.tr,
                            style: const TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'desc_notifikasi'.tr,
                    style: const TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  ...coll.groupBy(controller.notifications.toList(), (n) => controller.getGroupKey(n['timestamp'] ?? ''))
                      .entries
                      .map((e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateSection(e.key),
                              ...e.value.map((notif) {
                                final int notifId = notif['id'] as int;
                                final bool isRead = notif['is_read'] ?? false;
                                return _buildNotifItem(
                                  notifId: notifId,
                                  icon: controller.getIcon(notif['type'] ?? ''),
                                  iconColor: controller.getColor(notif['color'] ?? ''),
                                  title: notif['title'] ?? '',
                                  time: controller.formatTime(notif['timestamp'] ?? ''),
                                  desc: notif['message'] ?? '',
                                  isRead: isRead,
                                  onTap: () => controller.markAsRead(notifId),
                                );
                              })
                            ],
                          ))
                      .toList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: themeColor, size: 20),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Image.asset(
          'assets/images/logo_koperasi.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        const Text(
          'KOPERASI SIMPANKU',
          style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildDateSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildNotifItem({
    required int notifId,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String desc,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFFBE9E7).withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRead ? Colors.black.withOpacity(0.03) : themeColor.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                              fontSize: 15,
                              color: isRead ? Colors.black87 : themeColor,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 10, color: Colors.black38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12, 
                        color: isRead ? Colors.black54 : Colors.black87, 
                        height: 1.5,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../network/api_client.dart';
import '../../member_dashboard/controllers/member_dashboard_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

class NotifikasiController extends GetxController {
  final isLoading = false.obs;
  List<Map<String, dynamic>> allNotifications = [];
  final notifications = <Map<String, dynamic>>[].obs;
  final errorMessage = ''.obs;

  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        fetchNotifications();
        
        Get.snackbar(
          message.notification?.title ?? 'Notifikasi Baru',
          message.notification?.body ?? '',
          backgroundColor: Colors.white,
          colorText: Colors.black87,
          icon: const Icon(Icons.notifications_active, color: Color(0xFF6B0D0D)),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      });
    }
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await authorizedGet('/api/member/notifications');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          allNotifications = List<Map<String, dynamic>>.from(data['notifications']);
          // Ensure strictly descending order (newest first) by sorting locally
          // Fallback to sorting by 'id' if timestamps are identical
          allNotifications.sort((a, b) {
            final t1 = DateTime.parse(a['timestamp'] ?? '1970-01-01');
            final t2 = DateTime.parse(b['timestamp'] ?? '1970-01-01');
            final cmp = t2.compareTo(t1);
            if (cmp == 0) {
              final id1 = a['id'] as int? ?? 0;
              final id2 = b['id'] as int? ?? 0;
              return id2.compareTo(id1);
            }
            return cmp;
          });
          applyFilters();
        } else {
          errorMessage.value = data['error'] ?? 'Gagal memuat notifikasi';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final box = GetStorage();
    final isPenarikanEnabled = box.read('isNotifPenarikan') ?? true;
    
    if (isPenarikanEnabled) {
      notifications.value = List.from(allNotifications);
    } else {
      // Sembunyikan notifikasi penarikan dan pemasukan jika dimatikan
      notifications.value = allNotifications.where((n) {
        final type = n['type'] ?? '';
        final isSaldo = type.startsWith('SAVING_') || type.startsWith('WITHDRAWAL_') || type == 'PAYROLL';
        return !isSaldo;
      }).toList();
    }
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n['is_read'] == false).length;
    if (Get.isRegistered<MemberDashboardController>()) {
      Get.find<MemberDashboardController>().unreadNotificationCount.value = unreadCount.value;
    }
  }

  Future<void> markAsRead(int notifId) async {
    try {
      final response = await authorizedPut('/api/member/notifications/$notifId/read', {});
      if (response.statusCode == 200) {
        final idx = allNotifications.indexWhere((n) => n['id'] == notifId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(allNotifications[idx]);
          updated['is_read'] = true;
          allNotifications[idx] = updated;
          applyFilters();
        }
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await authorizedPut('/api/member/notifications/read-all', {});
      if (response.statusCode == 200) {
        allNotifications = allNotifications.map((n) {
          final updated = Map<String, dynamic>.from(n);
          updated['is_read'] = true;
          return updated;
        }).toList();
        applyFilters();
      }
    } catch (_) {}
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'SAVING_APPROVED':
        return Icons.check_circle_rounded;
      case 'SAVING_REJECTED':
        return Icons.cancel_rounded;
      case 'SAVING_PENDING':
        return Icons.schedule_rounded;
      case 'PAYROLL':
        return Icons.savings_rounded;
      case 'WITHDRAWAL_APPROVED':
        return Icons.account_balance_rounded;
      case 'WITHDRAWAL_REJECTED':
        return Icons.money_off_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color getColor(String colorStr) {
    switch (colorStr) {
      case 'green':
        return const Color(0xFF28A745);
      case 'red':
        return const Color(0xFFDC3545);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'blue':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B0D0D);
    }
  }

  String getGroupKey(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final compareDate = DateTime(dt.year, dt.month, dt.day);
      
      final diff = today.difference(compareDate).inDays;
      if (diff == 0) {
        return 'Hari Ini';
      } else if (diff == 1) {
        return 'Kemarin';
      } else if (diff < 7) {
        return '$diff Hari yang Lalu';
      } else {
        return '${dt.day} ${_bulan(dt.month)} ${dt.year}';
      }
    } catch (_) {
      return 'Lainnya';
    }
  }

  String formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _bulan(int m) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return bulan[m - 1];
  }
}

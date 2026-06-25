import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/growth_analytics_model.dart';
import '../../../data/services/growth_analytics_service.dart';

class MemberDashboardController extends GetxController {
  final count = 0.obs;

  final currentIndex = 0.obs;
  final isDarkMode = false.obs;
  final selectedPeriod = 'Bulanan'.obs;
  final _box = GetStorage();

  // Growth Analytics Data
  final Rx<GrowthAnalyticsModel?> growthData = Rx<GrowthAnalyticsModel?>(null);
  final isLoadingGrowth = false.obs;
  final growthError = ''.obs;

  final rxUserName = 'Pengguna'.obs;
  final rxMemberId = '-'.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    refreshUserDetails();
    fetchGrowthAnalytics();
  }

  void refreshUserDetails() {
    rxUserName.value = _box.read('userName')?.toString() ?? 'Pengguna';
    rxMemberId.value = _box.read('memberId')?.toString() ?? _box.read('userId')?.toString() ?? '-';
  }

  String get memberId => rxMemberId.value;
  String get userName => rxUserName.value;

  String formatNumber(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => "${m[1]}.",
    );
  }

  String formatCurrency(double amount) {
    return 'Rp ${formatNumber(amount)}';
  }

  double get totalBalance {
    return growthData.value?.savingTrend.totalBalance ?? 0.0;
  }

  double getBalanceByType(String typeName) {
    if (growthData.value == null) return 0.0;
    final dists = growthData.value!.savingTrend.distribution;
    for (var dist in dists) {
      if (dist.name.toLowerCase() == typeName.toLowerCase()) {
        return dist.value;
      }
    }
    return 0.0;
  }

  String get dynamicGreeting {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 11) {
      greeting = 'SELAMAT PAGI';
    } else if (hour >= 11 && hour < 15) {
      greeting = 'SELAMAT SIANG';
    } else if (hour >= 15 && hour < 18) {
      greeting = 'SELAMAT SORE';
    } else {
      greeting = 'SELAMAT MALAM';
    }
    return '$greeting, ${userName.toUpperCase()}';
  }


  void changeTabIndex(int index) {
    currentIndex.value = index;
    // Refresh analytics when switching to growth tab
    if (index == 2) {
      fetchGrowthAnalytics();
    }
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    fetchGrowthAnalytics();
  }

  /// Fetch growth analytics data from backend
  Future<void> fetchGrowthAnalytics() async {
    isLoadingGrowth.value = true;
    growthError.value = '';
    try {
      final data = await GrowthAnalyticsService.fetchGrowthAnalytics(
        period: selectedPeriod.value,
      );
      if (data != null) {
        growthData.value = data;
      } else {
        growthError.value = 'Gagal memuat data analytics';
      }
    } catch (e) {
      growthError.value = 'Error: $e';
    } finally {
      isLoadingGrowth.value = false;
    }
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _box.write('isDarkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLanguage(String langCode, String countryCode) {
    var locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
    _box.write('langCode', langCode);
    _box.write('countryCode', countryCode);
  }

  void increment() => count.value++;

  Future<void> logout() async {
    _box.remove('isLoggedIn');
    _box.remove('userId');
    _box.remove('userEmail');
    _box.remove('userName');
    _box.remove('userPhone');
    _box.remove('userAddress');
    _box.remove('memberId');
    _box.remove('userAvatarPath');
    _box.remove('loginType');
    
    Get.offAllNamed('/login');
  }
}

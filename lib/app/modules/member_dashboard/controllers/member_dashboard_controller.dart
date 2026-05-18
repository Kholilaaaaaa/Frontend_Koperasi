import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MemberDashboardController extends GetxController {
  final count = 0.obs;

  final currentIndex = 0.obs;
  final isDarkMode = false.obs;
  final selectedPeriod = 'Bulanan'.obs;
  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? false;
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
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
}

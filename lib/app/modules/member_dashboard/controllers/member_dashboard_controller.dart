import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'dart:convert';
import '../../../data/models/growth_analytics_model.dart';
import '../../../data/models/article_model.dart';
import '../../../data/services/growth_analytics_service.dart';
import '../../../network/api_client.dart';
import '../../../routes/app_routes.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
class MemberDashboardController extends GetxController {
  final count = 0.obs;

  final currentIndex = 0.obs;
  final isDarkMode = false.obs;
  final _box = GetStorage();

  final isNotifPenarikanEnabled = true.obs;
  final isNotifPromosiEnabled = true.obs;

  // Date range filter (default: 1 Jan tahun ini s/d hari ini)
  final startDate = Rxn<DateTime>();
  final endDate   = Rxn<DateTime>();
  
  final selectedPeriod = 'Mingguan'.obs;
  
  void setPeriod(String period) {
    selectedPeriod.value = period;
  }

  // Growth Analytics Data
  final Rx<GrowthAnalyticsModel?> growthData = Rx<GrowthAnalyticsModel?>(null);
  final isLoadingGrowth = false.obs;
  final growthError = ''.obs;

  // Approved & Pending Savings
  final approvedSavings = <Map<String, dynamic>>[].obs;
  final isLoadingSavings = false.obs;

  // Recent Transactions
  final recentTransactions = <Map<String, dynamic>>[].obs;
  final isLoadingTransactions = false.obs;

  // News state
  final latestNews = <ArticleModel>[].obs;
  final isLoadingNews = false.obs;

  final unreadNotificationCount = 0.obs;

  final rxUserName = 'Pengguna'.obs;
  final rxMemberId = '-'.obs;
  final rxAvatarPath = ''.obs;
  // Tanggal bergabung anggota (diisi dari response backend)
  final rxDateJoined = Rxn<DateTime>();
  
  Timer? _statusCheckTimer;

  // Saving type filter
  final selectedSavingTypeId = Rxn<int>();        // null = semua jenis
  final availableSavingTypes = <SavingTypeItem>[].obs;  // daftar jenis simpanan

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    isNotifPenarikanEnabled.value = _box.read('isNotifPenarikan') ?? true;
    isNotifPromosiEnabled.value = _box.read('isNotifPromosi') ?? true;
    // startDate.value dibiarkan null agar default dari backend (sejak pendaftaran) dipakai
    final now = DateTime.now();
    startDate.value = null;
    endDate.value   = now;
    refreshUserDetails();
    fetchSavingTypes();  // load jenis simpanan terlebih dahulu
    fetchGrowthAnalytics();
    fetchApprovedSavings();
    fetchRecentTransactions();
    fetchUnreadNotificationCount();
    fetchLatestNews();

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkMemberStatusAndRoute();
    });
    _checkMemberStatusAndRoute();
  }

  Future<void> _checkMemberStatusAndRoute() async {
    try {
      final userId = _box.read('userId');
      if (userId == null) return;
      final response = await authorizedGet('/api/member/status/$userId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] ?? '').toString().toLowerCase();
        if (status == 'resigned' || status == 'not_started' || status == 'rejected') {
          // Member no longer active or resignation approved
          Get.offAllNamed(Routes.VISITOR_DASHBOARD);
        } else if (status == 'pending' || status == 'menunggu') {
          Get.offAllNamed(Routes.DASHBOARD_STATUS);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final response = await authorizedGet('/api/member/notifications/unread-count');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          unreadNotificationCount.value = data['unread_count'] as int;
        }
      }
    } catch (_) {}
  }

  void refreshUserDetails() {
    rxUserName.value = _box.read('userName')?.toString() ?? 'Pengguna';
    rxMemberId.value = _box.read('memberId')?.toString() ?? _box.read('userId')?.toString() ?? '-';
    rxAvatarPath.value = _box.read('userAvatarPath')?.toString() ?? '';
  }

  String get memberId => rxMemberId.value;
  String get userName => rxUserName.value;
  String get avatarPath => rxAvatarPath.value;

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

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value   = end;
    fetchGrowthAnalytics();
  }

  /// Ubah filter jenis simpanan dan refresh grafik
  void setSavingTypeFilter(int? typeId) {
    selectedSavingTypeId.value = typeId;
    fetchGrowthAnalytics();
  }

  /// Fetch daftar jenis simpanan dari backend
  Future<void> fetchSavingTypes() async {
    try {
      final types = await GrowthAnalyticsService.fetchSavingTypes();
      availableSavingTypes.assignAll(types);
    } catch (e) {
      print('[Controller] fetchSavingTypes error: $e');
    }
  }

  Widget _buildSimpananList(BuildContext context) {
    // Placeholder – actual UI built in the view file.
    return const SizedBox.shrink();
  }

  /// Fetch growth analytics data dari backend dengan rentang tanggal
  Future<void> fetchGrowthAnalytics() async {
    isLoadingGrowth.value = true;
    growthError.value = '';
    try {
      final result = await GrowthAnalyticsService.fetchGrowthAnalytics(
        startDate: startDate.value,
        endDate:   endDate.value,
        savingTypeId: selectedSavingTypeId.value,
      );
      if (result.isBeforeJoinDate) {
        // Tanggal sebelum bergabung — tampilkan notifikasi dan reset ke tanggal bergabung
        Get.snackbar(
          'Tanggal Tidak Valid',
          result.errorMessage ?? 'Tanggal mulai tidak boleh sebelum tanggal Anda bergabung sebagai anggota.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
        // Reset startDate ke tanggal bergabung jika tersedia
        if (rxDateJoined.value != null) {
          startDate.value = rxDateJoined.value;
        }
        growthError.value = result.errorMessage ?? 'Tanggal sebelum bergabung';
      } else if (result.data != null) {
        growthData.value = result.data;
        // Simpan tanggal bergabung dari response backend
        final joinDateStr = result.data!.memberInfo.dateJoined;
        if (joinDateStr != null && joinDateStr.isNotEmpty) {
          try {
            rxDateJoined.value = DateTime.parse(joinDateStr);
          } catch (_) {}
        }
      } else {
        growthError.value = result.errorMessage ?? 'Gagal memuat data analytics';
      }
    } catch (e) {
      growthError.value = 'Error: $e';
    } finally {
      isLoadingGrowth.value = false;
    }
  }

  Future<void> fetchApprovedSavings() async {
    isLoadingSavings.value = true;
    try {
      final response = await authorizedGet('/api/member/savings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          approvedSavings.value = List<Map<String, dynamic>>.from(data['savings']);
        }
      }
    } catch (e) {
      debugPrint('Error fetchApprovedSavings: $e');
    } finally {
      isLoadingSavings.value = false;
    }
  }
  Future<void> fetchRecentTransactions() async {
    isLoadingTransactions.value = true;
    try {
      final response = await authorizedGet('/api/member/financial_details');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['recent_transactions'] != null) {
          recentTransactions.value = List<Map<String, dynamic>>.from(data['recent_transactions']);
        }
      }
    } catch (e) {
      debugPrint('Error fetchRecentTransactions: $e');
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  /// Returns true if the member has an ACTIVE or PENDING saving of this type name
  bool hasSaving(String typeName) {
    return approvedSavings.any(
      (s) => (s['saving_type_name'] as String).toLowerCase().contains(typeName.toLowerCase()),
    );
  }

  /// Returns the deposit_request id for a saving type (null if mandatory / not found)
  int? getSavingId(String typeName) {
    final match = approvedSavings.firstWhereOrNull(
      (s) => (s['saving_type_name'] as String).toLowerCase().contains(typeName.toLowerCase()),
    );
    return match?['id'] as int?;
  }


  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _box.write('isDarkMode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  final selectedSavingFilter = 'Semua'.obs;
  final filterStartDate = Rxn<DateTime>();
  final filterEndDate = Rxn<DateTime>();

  final detailStartDate = Rxn<DateTime>();
  final detailEndDate = Rxn<DateTime>();

  List<Map<String, dynamic>> get filteredTransactions {
    final list = recentTransactions;
    return list.where((tx) {
      if (selectedSavingFilter.value != 'Semua') {
        final stName = (tx['saving_type'] ?? '').toString().toLowerCase();
        final filterName = selectedSavingFilter.value.toLowerCase();
        if (!stName.contains(filterName)) return false;
      }
      
      if (filterStartDate.value != null && filterEndDate.value != null) {
        try {
          final txDate = DateTime.parse(tx['date']).toLocal();
          final start = DateTime(filterStartDate.value!.year, filterStartDate.value!.month, filterStartDate.value!.day);
          final end = DateTime(filterEndDate.value!.year, filterEndDate.value!.month, filterEndDate.value!.day, 23, 59, 59);
          if (txDate.isBefore(start) || txDate.isAfter(end)) return false;
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> getDetailTransactions(String savingTypeName) {
    return recentTransactions.where((tx) {
      final stName = (tx['saving_type'] ?? '').toString().toLowerCase();
      if (!stName.contains(savingTypeName.toLowerCase())) return false;
      
      if (detailStartDate.value != null && detailEndDate.value != null) {
        try {
          final txDate = DateTime.parse(tx['date']).toLocal();
          final start = DateTime(detailStartDate.value!.year, detailStartDate.value!.month, detailStartDate.value!.day);
          final end = DateTime(detailEndDate.value!.year, detailEndDate.value!.month, detailEndDate.value!.day, 23, 59, 59);
          if (txDate.isBefore(start) || txDate.isAfter(end)) return false;
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Refresh all relevant data after changes
  Future<void> refreshAll() async {
    await fetchApprovedSavings();
    await fetchGrowthAnalytics();
    await fetchUnreadNotificationCount();
    await fetchRecentTransactions();
    await fetchLatestNews();
    try {
      if (Get.isRegistered<NotifikasiController>()) {
        Get.find<NotifikasiController>().fetchNotifications();
      }
    } catch (_) {}
  }

  Future<void> fetchLatestNews() async {
    isLoadingNews.value = true;
    try {
      final response = await authorizedGet('/api/news/economy');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final items = data['data'] as List;
          latestNews.assignAll(items.map((e) => ArticleModel.fromJson(e)).toList());
        }
      }
    } catch (_) {
    } finally {
      isLoadingNews.value = false;
    }
  }

  Future<void> openArticle(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka tautan berita');
    }
  }

  // Public method to expose Simpanan list UI
  Widget buildSimpananList(BuildContext context) => _buildSimpananList(context);

  void changeLanguage(String langCode, String countryCode) {
    var locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
    _box.write('langCode', langCode);
    _box.write('countryCode', countryCode);
  }

  void toggleNotifPenarikan(bool val) {
    isNotifPenarikanEnabled.value = val;
    _box.write('isNotifPenarikan', val);
    if (Get.isRegistered<NotifikasiController>()) {
      Get.find<NotifikasiController>().applyFilters();
    }
  }

  void toggleNotifPromosi(bool val) {
    isNotifPromosiEnabled.value = val;
    _box.write('isNotifPromosi', val);
    if (Get.isRegistered<NotifikasiController>()) {
      Get.find<NotifikasiController>().applyFilters();
    }
  }

  void increment() => count.value++;

  Future<void> logout() async {
    _box.remove('isLoggedIn');
    _box.remove('userId');
    _box.remove('memberId');
    _box.remove('userName');
    _box.remove('jwt_token');
    
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    _statusCheckTimer?.cancel();
    super.onClose();
  }
}

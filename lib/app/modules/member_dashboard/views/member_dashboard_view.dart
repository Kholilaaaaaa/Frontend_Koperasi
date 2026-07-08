import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/member_dashboard_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/growth_analytics_model.dart';
import 'tabs/history_view.dart';
import 'tabs/growth_view.dart';
import 'tabs/settings_view.dart';

class MemberDashboardView extends GetView<MemberDashboardController> {
  const MemberDashboardView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static const accentRed = Color(0xFF8A1515);
  static const bgLight = Color(0xFFF8F4F0);
  static const cardBg = Colors.white;

  static Color getBgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : bgLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: SafeArea(
        child: Obx(() => IndexedStack(
              index: controller.currentIndex.value,
              children: [
                _buildHomeContent(context),
                const HistoryView(),
                const GrowthView(),
                const SettingsView(),
              ],
            )),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── HOME CONTENT ─────────────────────────────────────────────────────────
  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildBalanceCard(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 28),
          _buildSavingsTrendSection(context),
          const SizedBox(height: 24),
          _buildSimpananTitle(context),
          _buildSimpananGrid(context),
          const SizedBox(height: 24),
          _buildNewsSection(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/logo_koperasi.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KOPERASI SIMPANKU',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
                Obx(() => Text(
                      controller.dynamicGreeting,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          // Notification bell
          Obx(() => GestureDetector(
                onTap: () async {
                  await Get.toNamed(Routes.NOTIFIKASI);
                  controller.fetchUnreadNotificationCount();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: themeColor,
                        size: 22,
                      ),
                    ),
                    if (controller.unreadNotificationCount.value > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${controller.unreadNotificationCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── BALANCE HERO CARD ────────────────────────────────────────────────────
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8A1515), Color(0xFF3E0505)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(120),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: name + card icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          controller.userName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'premium_member'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'total_simpanan'.tr,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() => Text(
                      controller.formatCurrency(controller.totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    )),
                const SizedBox(height: 20),
                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withAlpha(30),
                ),
                const SizedBox(height: 16),
                // Bottom row: ID + growth indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, color: Colors.white38, size: 14),
                        const SizedBox(width: 6),
                        Obx(() => Text(
                              'ID: ${controller.memberId}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            )),
                      ],
                    ),
                    Obx(() {
                      final growth = controller.growthData.value?.savingTrend.growthPct ?? 0.0;
                      final isPos = growth >= 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPos
                              ? const Color(0xFF10B981).withAlpha(40)
                              : Colors.red.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: isPos ? const Color(0xFF10B981) : Colors.redAccent,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isPos ? "+" : ""}${growth.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: isPos ? const Color(0xFF10B981) : Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'aksi_cepat'.tr,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black38,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.add_card_rounded,
                  label: 'buka_simpanan'.tr,
                  color: const Color(0xFF6B0D0D),
                  bgColor: const Color(0xFFFFF0F0),
                  onTap: () => Get.toNamed(Routes.BUKA_SIMPANAN),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'pengajuan_penarikan'.tr,
                  color: const Color(0xFF1A56A5),
                  bgColor: const Color(0xFFEEF4FF),
                  onTap: () => Get.toNamed(Routes.PENARIKAN),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.history_rounded,
                  label: 'riwayat_mutasi'.tr,
                  color: const Color(0xFF06736A),
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () => controller.changeTabIndex(1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'analisis_grafik'.tr,
                  color: const Color(0xFF92400E),
                  bgColor: const Color(0xFFFFF7ED),
                  onTap: () => controller.changeTabIndex(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? color.withAlpha(30) : bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SAVINGS TREND SECTION ────────────────────────────────────────────────
  Widget _buildSavingsTrendSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tren_simpanan'.tr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black38,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'grafik_pertumbuhan'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => controller.changeTabIndex(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'detail'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart card
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Obx(() {
              if (controller.isLoadingGrowth.value) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: themeColor,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }
              final data = controller.growthData.value;
              if (data == null || data.savingTrend.values.isEmpty) {
                return _buildChartPlaceholder(context);
              }
              return _buildMiniLineChart(data.savingTrend);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_rounded, size: 52, color: themeColor.withAlpha(60)),
          const SizedBox(height: 10),
          Text(
            'belum_ada_simpanan'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'grafik_akan_muncul'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLineChart(SavingTrendData trend) {
    final n = trend.values.length;
    final balanceSpots = List.generate(n, (i) => FlSpot(i.toDouble(), trend.values[i]));
    final depositSpots = List.generate(
        n, (i) => FlSpot(i.toDouble(), trend.depositData.length > i ? trend.depositData[i] : 0.0));
    final withdrawalSpots = List.generate(
        n, (i) => FlSpot(i.toDouble(), trend.withdrawalData.length > i ? trend.withdrawalData[i] : 0.0));

    final allVals = [
      ...trend.values,
      ...trend.depositData,
      ...trend.withdrawalData
    ].where((v) => v >= 0).toList();

    double minY = 0, maxY = 1000, interval = 250;
    if (allVals.isNotEmpty) {
      final minVal = allVals.reduce((a, b) => a < b ? a : b);
      final maxVal = allVals.reduce((a, b) => a > b ? a : b);
      double diff = maxVal - minVal;
      if (diff <= 0) {
        minY = (minVal * 0.85).clamp(0.0, double.infinity);
        maxY = minVal * 1.15 + 1;
      } else {
        minY = (minVal - diff * 0.15).clamp(0.0, double.infinity);
        maxY = maxVal + diff * 0.2;
      }
      
      // Ensure minY is 0 if there's a 0 in allVals
      if (minVal == 0) minY = 0;
      
      interval = (maxY - minY) / 4;
      if (interval <= 0) interval = 1;
    }

    String fmtY(double val) {
      if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
      if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
      return val.toStringAsFixed(0);
    }

    final isPos = trend.growthPct >= 0;
    final growthColor = isPos ? const Color(0xFF10B981) : Colors.red;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with stats
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_saldo'.tr,
                      style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.format(trend.totalBalance),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: growthColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: growthColor,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPos ? "+" : ""}${trend.growthPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: growthColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 10,
                    getTooltipColor: (_) => const Color(0xFF1A1A2E),
                    getTooltipItems: (touchedSpots) {
                      final idx = touchedSpots.first.spotIndex;
                      if (idx < 0 || idx >= trend.months.length) return [];
                      final date = trend.months[idx];
                      final saldo = trend.values.length > idx ? trend.values[idx] : 0.0;
                      final masuk = trend.depositData.length > idx ? trend.depositData[idx] : 0.0;
                      final keluar = trend.withdrawalData.length > idx ? trend.withdrawalData[idx] : 0.0;

                      return touchedSpots.map((ts) {
                        if (ts.barIndex != 2) {
                          return LineTooltipItem('', const TextStyle());
                        }
                        return LineTooltipItem(
                          '$date\n',
                          const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          children: [
                            TextSpan(
                              text: '● Saldo: ${fmt.format(saldo)}\n',
                              style: const TextStyle(
                                  color: Color(0xFFFFB0B0), fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                            if (masuk > 0)
                              TextSpan(
                                text: '▲ Masuk: ${fmt.format(masuk)}\n',
                                style: const TextStyle(
                                    color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                            if (keluar > 0)
                              TextSpan(
                                text: '▼ Keluar: ${fmt.format(keluar)}',
                                style: const TextStyle(
                                    color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.black.withAlpha(10), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1.0,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= trend.months.length) return const Text('');
                        final show = n <= 4
                            ? true
                            : (idx == 0 || idx == n - 1 || idx == n ~/ 2);
                        if (!show) return const Text('');
                        final raw = trend.months[idx];
                        final parts = raw.split(' ');
                        final label = parts.length >= 2 ? '${parts[0]} ${parts[1]}' : raw;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label,
                              style: const TextStyle(
                                  color: Colors.black38, fontSize: 8, fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Text(
                        fmtY(value),
                        style: const TextStyle(color: Colors.black38, fontSize: 8),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.black.withAlpha(20), width: 1),
                    left: BorderSide(color: Colors.black.withAlpha(20), width: 1),
                  ),
                ),
                lineBarsData: [
                  // Deposit – hijau dashed
                  LineChartBarData(
                    isCurved: false,
                    color: const Color(0xFF10B981),
                    barWidth: 1.5,
                    dashArray: [5, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 2.5,
                        color: const Color(0xFF10B981),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                    spots: depositSpots.where((s) => s.y > 0).toList(),
                  ),
                  // Withdrawal – merah dashed
                  LineChartBarData(
                    isCurved: false,
                    color: const Color(0xFFEF4444),
                    barWidth: 1.5,
                    dashArray: [5, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 2.5,
                        color: const Color(0xFFEF4444),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                    spots: withdrawalSpots.where((s) => s.y > 0).toList(),
                  ),
                  // Balance – merah gelap solid
                  LineChartBarData(
                    isCurved: false,
                    color: themeColor,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 4,
                        color: themeColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [themeColor.withAlpha(40), themeColor.withAlpha(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: balanceSpots,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Legend row
          Row(
            children: [
              _miniLegend('saldo'.tr, themeColor),
              const SizedBox(width: 14),
              _miniLegend('pemasukan'.tr, const Color(0xFF10B981)),
              const SizedBox(width: 14),
              _miniLegend('pengeluaran'.tr, const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── SIMPANAN LIST ────────────────────────────────────────────────────────
  Widget _buildSimpananTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'portofolio_simpanan'.tr,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.black38,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'rincian_simpanan_saya'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpananGrid(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    return Obx(() {
      if (controller.isLoadingSavings.value) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator(color: themeColor, strokeWidth: 2)),
        );
      }
      if (controller.approvedSavings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Icon(Icons.savings_outlined, size: 52, color: themeColor.withAlpha(60)),
                const SizedBox(height: 12),
                Text('belum_ada_simpanan'.tr, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black45)),
                const SizedBox(height: 6),
                Text('mulai_buka_simpanan'.tr,
                    style: const TextStyle(color: Colors.black26, fontSize: 12)),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: controller.approvedSavings.asMap().entries.map((entry) {
            final index = entry.key;
            final saving = entry.value;
            final String typeName = saving['saving_type_name'] as String? ?? '-';
            final double amount = (saving['balance'] ?? 0).toDouble();
            final isLast = index == controller.approvedSavings.length - 1;

            return Column(
              children: [
                _buildSimpananCard(context, typeName, amount),
                if (!isLast) const SizedBox(height: 10),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildSimpananCard(BuildContext context, String typeName, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    IconData icon;
    Color iconColor;
    Color iconBg;

    final lower = typeName.toLowerCase();
    if (lower.contains('wajib')) {
      icon = Icons.lock_rounded;
      iconColor = const Color(0xFF6B0D0D);
      iconBg = isDark ? const Color(0xFF3B1515) : const Color(0xFFFFF0F0);
    } else if (lower.contains('sukarela')) {
      icon = Icons.volunteer_activism_rounded;
      iconColor = isDark ? const Color(0xFF4CA0FF) : const Color(0xFF1A56A5);
      iconBg = isDark ? const Color(0xFF152A4A) : const Color(0xFFEEF4FF);
    } else if (lower.contains('pokok')) {
      icon = Icons.account_balance_rounded;
      iconColor = isDark ? const Color(0xFF20C997) : const Color(0xFF06736A);
      iconBg = isDark ? const Color(0xFF13352A) : const Color(0xFFECFDF5);
    } else {
      icon = Icons.savings_rounded;
      iconColor = isDark ? const Color(0xFFE28C41) : const Color(0xFF92400E);
      iconBg = isDark ? const Color(0xFF3B2515) : const Color(0xFFFFF7ED);
    }

    return GestureDetector(
      onTap: () {
        controller.changeTabIndex(1);
        
        // Optionally set filter if you want to show specific savings history
        final lower = typeName.toLowerCase();
        if (lower.contains('pokok')) {
          controller.selectedSavingFilter.value = 'Pokok';
        } else if (lower.contains('wajib')) {
          controller.selectedSavingFilter.value = 'Wajib';
        } else if (lower.contains('sukarela')) {
          controller.selectedSavingFilter.value = 'Sukarela';
        } else {
          controller.selectedSavingFilter.value = 'Semua';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeName.replaceAll(' ', '_').toLowerCase().tr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : Colors.black54,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(amount),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 18),
          ),
        ],
      ),
    ));
  }

  // ── NEWS SECTION ─────────────────────────────────────────────────────────
  Widget _buildNewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'berita_terbaru'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingNews.value) {
            return const Center(child: CircularProgressIndicator(color: themeColor));
          }
          if (controller.latestNews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('belum_ada_berita'.tr, style: const TextStyle(color: Colors.grey)),
            );
          }
          return SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: controller.latestNews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final article = controller.latestNews[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return GestureDetector(
                  onTap: () => controller.openArticle(article.link),
                  child: Container(
                    width: 240,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: article.thumbnailUrl.isNotEmpty
                              ? Image.network(
                                  article.thumbnailUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                                )
                              : Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      article.pubDateStr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Obx(() => Container(
          height: 76,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF3E0505),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: themeColor.withAlpha(100),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_rounded,
                'Home',
                isActive: controller.currentIndex.value == 0,
                onTap: () => controller.changeTabIndex(0),
              ),
              _buildNavItem(
                Icons.receipt_long_rounded,
                'Riwayat',
                isActive: controller.currentIndex.value == 1,
                onTap: () => controller.changeTabIndex(1),
              ),
              _buildNavItem(
                Icons.analytics_rounded,
                'Analitik',
                isActive: controller.currentIndex.value == 2,
                onTap: () => controller.changeTabIndex(2),
              ),
              _buildNavItem(
                Icons.manage_accounts_rounded,
                'Akun',
                isActive: controller.currentIndex.value == 3,
                onTap: () => controller.changeTabIndex(3),
              ),
            ],
          ),
        ));
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? Colors.white : Colors.white38,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

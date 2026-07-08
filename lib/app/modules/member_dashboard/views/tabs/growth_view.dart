import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/member_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/growth_analytics_model.dart';

class GrowthView extends StatelessWidget {
  const GrowthView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static Color getBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F6);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingGrowth.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: themeColor),
                  SizedBox(height: 16),
                  Text('loading_analytics'.tr, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            );
          }

          final data = controller.growthData.value;

          return RefreshIndicator(
            color: themeColor,
            onRefresh: () => controller.fetchGrowthAnalytics(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 32),
                  _buildHeaderTitle(context),
                  const SizedBox(height: 24),
                  _buildFilterSection(context, controller),
                  const SizedBox(height: 24),
                  if (data != null) ...[
                    _buildHealthScoreCard(context, data.health),
                    const SizedBox(height: 24),
                    _buildMainChartCard(context, data.savingTrend),
                    const SizedBox(height: 24),
                    _buildEconomicChartCard(context, data.economicData),
                    const SizedBox(height: 24),
                    ...data.aiInsights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAIInsightCard(context, insight),
                    )),
                    const SizedBox(height: 8),
                    _buildPredictionCard(context, data.prediction, hasSavings: data.savingTrend.totalBalance > 0),
                  ] else ...[
                    _buildErrorCard(context, controller.growthError.value),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white,
                border: Border.all(color: themeColor.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Icon(Icons.account_balance, color: themeColor, size: 20)),
            ),
            const SizedBox(width: 12),
            const Text('KOPERASI SIMPANAN HARKAT', style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.NOTIFIKASI),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_outlined, color: themeColor, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('growth_analytics'.tr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.5)),
        Text('analisis_pertumbuhan'.tr, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor)),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, MemberDashboardController controller) {
    final periods = ['mingguan'.tr, 'bulanan'.tr, 'tahunan'.tr];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Row(
        children: periods.map((p) {
          final isSelected = controller.selectedPeriod.value == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setPeriod(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: isSelected ? themeColor : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(p, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black38), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13))),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildHealthScoreCard(BuildContext context, HealthScore health) {
    Color statusColor;
    if (health.score >= 80) {
      statusColor = const Color(0xFF28A745);
    } else if (health.score >= 60) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [themeColor, themeColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: CircularProgressIndicator(
                    value: health.score / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Text('${health.score}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('financial_health_score'.tr, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(health.status, style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('desc_financial_health_score'.tr, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChartCard(BuildContext context, SavingTrendData trend) {
    if (trend.totalBalance <= 0) {
      return _buildSectionCard(
        context,
        title: 'trend_pertumbuhan_simpanan'.tr,
        subtitle: 'pertumbuhan_saldo_total'.tr,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.savings_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'belum_ada_riwayat_simpanan'.tr,
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'grafik_pertumbuhan_akan_muncul'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend.values[i]));
    }

    final isPositive = trend.growthPct >= 0;
    final growthColor = isPositive ? const Color(0xFF28A745) : Colors.red;

    return _buildSectionCard(
      context,
      title: 'trend_pertumbuhan_simpanan'.tr,
      subtitle: 'pertumbuhan_saldo_total'.tr,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: spots.isEmpty
                ? Center(child: Text('belum_ada_data_transaksi'.tr, style: const TextStyle(color: Colors.black38)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < trend.months.length) {
                              return Text(trend.months[idx], style: const TextStyle(color: Colors.black38, fontSize: 10));
                            }
                            return const Text('');
                          },
                          reservedSize: 22,
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true, color: themeColor, barWidth: 4, isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(colors: [themeColor.withAlpha(50), themeColor.withAlpha(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                          spots: spots,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: growthColor.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: growthColor, size: 16),
                    const SizedBox(width: 4),
                    Text('${isPositive ? "+" : ""}${trend.growthPct}%', style: TextStyle(color: growthColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPositive
                      ? 'simpanan_meningkat_bulan'.trParams({'pct': trend.growthPct.toString()})
                      : 'simpanan_menurun_bulan'.trParams({'pct': trend.growthPct.abs().toString()}),
                  style: const TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEconomicChartCard(BuildContext context, EconomicData eco) {
    List<FlSpot> inflationSpots = [];
    List<FlSpot> biRateSpots = [];
    List<FlSpot> usdSpots = [];

    for (int i = 0; i < eco.inflation.length; i++) {
      inflationSpots.add(FlSpot(i.toDouble(), eco.inflation[i]));
    }
    for (int i = 0; i < eco.biRate.length; i++) {
      biRateSpots.add(FlSpot(i.toDouble(), eco.biRate[i]));
    }
    // Normalize USD/IDR to fit chart scale
    for (int i = 0; i < eco.usdIdr.length; i++) {
      usdSpots.add(FlSpot(i.toDouble(), eco.usdIdr[i] / 5000));
    }

    final hasData = inflationSpots.isNotEmpty || biRateSpots.isNotEmpty;

    return _buildSectionCard(
      context,
      title: 'kondisi_ekonomi_nasional'.tr,
      subtitle: 'monitoring_inflasi_bi'.tr,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: !hasData
                ? Center(child: Text('data_ekonomi_belum_tersedia'.tr, style: const TextStyle(color: Colors.black38)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < eco.months.length) {
                              return Text(eco.months[idx], style: const TextStyle(color: Colors.black38, fontSize: 9));
                            }
                            return const Text('');
                          },
                          reservedSize: 22,
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        if (inflationSpots.isNotEmpty)
                          LineChartBarData(isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: false), spots: inflationSpots),
                        if (biRateSpots.isNotEmpty)
                          LineChartBarData(isCurved: true, color: themeColor, barWidth: 2, dotData: FlDotData(show: false), spots: biRateSpots),
                        if (usdSpots.isNotEmpty)
                          LineChartBarData(isCurved: true, color: const Color(0xFF00A389), barWidth: 2, dotData: FlDotData(show: false), spots: usdSpots),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(Colors.orange, 'inflasi'.tr),
              const SizedBox(width: 16),
              _buildLegendDot(themeColor, 'BI Rate'),
              const SizedBox(width: 16),
              _buildLegendDot(const Color(0xFF00A389), 'USD/IDR'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildAIInsightCard(BuildContext context, AiInsight insight) {
    IconData icon;
    Color tagColor;
    String tagText;

    switch (insight.type) {
      case 'warning':
        icon = Icons.warning_amber_rounded;
        tagColor = Colors.orange;
        tagText = 'peringatan'.tr;
        break;
      case 'success':
        icon = Icons.check_circle_outline;
        tagColor = const Color(0xFF28A745);
        tagText = 'positif'.tr;
        break;
      default:
        icon = Icons.info_outline;
        tagColor = Colors.blue;
        tagText = 'informasi'.tr;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withAlpha(25)),
        boxShadow: [BoxShadow(color: themeColor.withAlpha(13), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: themeColor, size: 20),
                  const SizedBox(width: 8),
                  Text('smart_ai_insight'.tr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: themeColor, letterSpacing: 1.2)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: tagColor.withAlpha(25), borderRadius: BorderRadius.circular(6)),
                child: Text(tagText, style: TextStyle(color: tagColor, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: tagColor, size: 18),
              const SizedBox(width: 8),
              Text(insight.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.message, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: themeColor.withAlpha(15), borderRadius: BorderRadius.circular(4)),
                child: Text('confidence_param'.trParams({'val': '${(insight.confidence * 100).toInt()}'}), style: const TextStyle(color: themeColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, GrowthPrediction prediction, {bool hasSavings = true}) {
    if (!hasSavings) {
      return const SizedBox.shrink(); // Hide prediction if no savings
    }

    final isPositive = prediction.nextMonthGrowthPct >= 0;
    final color = isPositive ? const Color(0xFF28A745) : Colors.red;

    return _buildSectionCard(
      context,
      title: 'prediction_analytics'.tr,
      subtitle: 'estimasi_pertumbuhan_bulan_depan'.tr,
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(color: color, value: prediction.probability.toDouble(), radius: 10, showTitle: false),
                  PieChartSectionData(color: color.withAlpha(30), value: (100 - prediction.probability).toDouble(), radius: 10, showTitle: false),
                ],
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('prediksi_bulan_depan'.tr, style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? "+" : ""}${prediction.nextMonthGrowthPct}%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
                ),
                Text(
                  'probabilitas_target'.trParams({'val': '${prediction.probability}'}),
                  style: const TextStyle(fontSize: 10, color: Colors.black26, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      prediction.trendDirection == 'up' ? Icons.arrow_upward : (prediction.trendDirection == 'down' ? Icons.arrow_downward : Icons.remove),
                      color: color, size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'trend_param'.trParams({'val': prediction.trendDirection == 'up' ? 'trend_naik'.tr : (prediction.trendDirection == 'down' ? 'trend_turun'.tr : 'trend_stabil'.tr)}),
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final controller = Get.find<MemberDashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.black26, size: 48),
          const SizedBox(height: 16),
          Text(error.isNotEmpty ? error : 'data_analytics_belum_tersedia'.tr, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchGrowthAnalytics(),
            style: ElevatedButton.styleFrom(backgroundColor: themeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('coba_lagi'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required String subtitle, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : themeColor)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

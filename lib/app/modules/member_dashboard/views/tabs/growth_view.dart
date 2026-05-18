import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/member_dashboard_controller.dart';
import '../../../../routes/app_routes.dart';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 32),
              _buildHeaderTitle(context),
              const SizedBox(height: 24),
              _buildFilterSection(context, controller),
              const SizedBox(height: 32),
              _buildMainChartCard(context),
              const SizedBox(height: 24),
              _buildEconomicChartCard(context),
              const SizedBox(height: 24),
              _buildAIInsightCard(context),
              const SizedBox(height: 24),
              _buildPredictionCard(context),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: themeColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.account_balance, color: themeColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'KOPERASI SIMPANAN HARKAT',
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.NOTIFIKASI),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
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
        const Text(
          'GROWTH ANALYTICS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          'Analisis Pertumbuhan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, MemberDashboardController controller) {
    final periods = ['Mingguan', 'Bulanan', 'Tahunan'];
    return Obx(() => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                decoration: BoxDecoration(
                  color: isSelected ? themeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    p,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black38,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildMainChartCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'TREND PERTUMBUHAN SIMPANAN',
      subtitle: 'Pertumbuhan Saldo Total',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: themeColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [themeColor.withAlpha(50), themeColor.withAlpha(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
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
                decoration: BoxDecoration(
                  color: const Color(0xFF28A745).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF28A745), size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(color: Color(0xFF28A745), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Simpanan meningkat 12% dibanding bulan lalu.',
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEconomicChartCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'KONDISI EKONOMI NASIONAL',
      subtitle: 'Monitoring Inflasi & BI Rate',
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.orange,
                barWidth: 2,
                dotData: FlDotData(show: false),
                spots: const [FlSpot(0, 4), FlSpot(2, 3.5), FlSpot(5, 5), FlSpot(8, 4.5), FlSpot(11, 4)],
              ),
              LineChartBarData(
                isCurved: true,
                color: themeColor,
                barWidth: 2,
                dotData: FlDotData(show: false),
                spots: const [FlSpot(0, 2), FlSpot(4, 2.5), FlSpot(7, 2.2), FlSpot(11, 2.8)],
              ),
              LineChartBarData(
                isCurved: true,
                color: const Color(0xFF00A389),
                barWidth: 2,
                dotData: FlDotData(show: false),
                spots: const [FlSpot(0, 1), FlSpot(3, 1.5), FlSpot(6, 1.2), FlSpot(11, 2)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  const Text('SMART AI INSIGHT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: themeColor, letterSpacing: 1.2)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: themeColor.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                child: const Text('AI ANALYTICS', style: TextStyle(color: themeColor, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Inflasi nasional meningkat menyebabkan daya beli menurun. Disarankan untuk mengalokasikan lebih banyak pada Simpanan Sukarela sebagai dana cadangan darurat.',
            style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'PREDICTION ANALYTICS',
      subtitle: 'Estimasi Pertumbuhan',
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(color: const Color(0xFF28A745), value: 85, radius: 10, showTitle: false),
                  PieChartSectionData(color: const Color(0xFF28A745).withAlpha(30), value: 15, radius: 10, showTitle: false),
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
                const Text('Prediksi Bulan Depan', style: TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('+8.5%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF28A745))),
                const Text(
                  'Probabilitas mencapai target: 85%',
                  style: TextStyle(fontSize: 10, color: Colors.black26, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w900, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : themeColor
            )
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

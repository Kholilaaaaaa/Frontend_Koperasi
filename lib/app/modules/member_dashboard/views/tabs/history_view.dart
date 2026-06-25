import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/member_dashboard_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  static const themeColor = Color(0xFF6B0D0D);
  static Color getBgColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F6);
  static const successColor = Color(0xFF28A745);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 24),
                _buildRiwayatHeader(),
                const SizedBox(height: 24),
                
                // 1. Top Summary Cards
                _buildTopSummary(),
                
                const SizedBox(height: 32),
                
                // 2. Savings Details
                const Text('RINCIAN PER SIMPANAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
                const SizedBox(height: 12),
                _buildSavingsGrid(),
                
                const SizedBox(height: 32),
                
                // 3. Search & Filter Bar
                _buildSearchAndFilter(),
                
                const SizedBox(height: 24),
                
                // 4. Transaction Mutation List
                _buildMutationList(),
                
                const SizedBox(height: 100), // Space for footer buttons
              ],
            ),
          ),
          
          // 5. Bottom Export Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFooterExport(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
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
        const Spacer(),
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



  Widget _buildRiwayatHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Riwayat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: themeColor,
          ),
        ),
        Text(
          'Aktivitas keuangan Anda',
          style: TextStyle(
            color: Colors.black38,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTopSummary() {
    final controller = Get.find<MemberDashboardController>();
    return Obx(() {
      final data = controller.growthData.value;
      final totalBalance = data?.savingTrend.totalBalance.toStringAsFixed(0) ?? '0';
      final totalPayroll = data?.payrollVsWithdrawal.payroll.fold<double>(0, (p, c) => p + c).toStringAsFixed(0) ?? '0';
      final totalWithdrawal = data?.payrollVsWithdrawal.withdrawal.fold<double>(0, (p, c) => p + c).toStringAsFixed(0) ?? '0';
      
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            _summaryCard('Saldo Aktif', totalBalance, themeColor),
            const SizedBox(width: 16),
            _summaryCard('Total Payroll', totalPayroll, successColor),
            const SizedBox(width: 16),
            _summaryCard('Withdrawal', totalWithdrawal, Colors.orange),
            const SizedBox(width: 16),
          ],
        ),
      );
    });
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.black.withAlpha(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black38)),
          const SizedBox(height: 8),
          Text('Rp $value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSavingsGrid() {
    final controller = Get.find<MemberDashboardController>();
    return Obx(() {
      final growthData = controller.growthData.value;
      if (growthData == null) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final distributions = growthData.savingTrend.distribution;
      
      if (distributions.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: const Text('Belum ada simpanan saat ini.', style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
        );
      }
      
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: distributions.map((dist) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _savingsCard(dist.name.toUpperCase(), '-', dist.value.toStringAsFixed(0)),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _savingsCard(String title, String account, String balance) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: themeColor.withAlpha(20)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor)),
          const SizedBox(height: 16),
          const Text('No. Rekening', style: TextStyle(fontSize: 8, color: Colors.black38)),
          Text(account, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          const Text('Saldo Saat Ini', style: TextStyle(fontSize: 8, color: Colors.black38)),
          Text('Rp $balance', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: themeColor)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lihat Detail', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, size: 20, color: Colors.black26),
                SizedBox(width: 12),
                Text('Cari transaksi...', style: TextStyle(fontSize: 12, color: Colors.black26)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: const Icon(Icons.calendar_month, size: 20, color: themeColor),
        ),
      ],
    );
  }

  Widget _buildMutationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MUTASI TERBARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1)),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Text('Belum ada riwayat transaksi', style: TextStyle(color: Colors.black38, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _mutationItem(String title, String date, String amount, String status, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: themeColor.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(isIncome ? Icons.south_west : Icons.north_east, size: 18, color: themeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 10, color: Colors.black38)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isIncome ? successColor : Colors.black87)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: successColor.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterExport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Export PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: themeColor,
                side: const BorderSide(color: themeColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('Export Excel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

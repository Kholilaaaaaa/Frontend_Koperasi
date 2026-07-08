import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/member_dashboard_controller.dart';
import '../../../../network/api_client.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  MemberDashboardController get controller => Get.find<MemberDashboardController>();

  static const themeColor = Color(0xFF6B0D0D);
  static const successColor = Color(0xFF28A745);
  static const warningColor = Color(0xFFF59E0B);
  static const infoColor = Color(0xFF3B82F6);
  static Color getBgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFFFF9F6);

  String _formatRupiah(double amount) {
    return amount
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    return Scaffold(
      backgroundColor: getBgColor(context),
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: () async {
          await controller.refreshAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 24),
              _buildRiwayatHeader(),
              const SizedBox(height: 20),
              _buildTopSummary(),
              const SizedBox(height: 28),
              _buildSavingsSection(),
              const SizedBox(height: 28),
              _buildMutationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo_koperasi.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'KOPERASI SIMPANKU',
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Obx(() => GestureDetector(
          onTap: () async {
            await Get.toNamed(Routes.NOTIFIKASI);
            controller.fetchUnreadNotificationCount();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_outlined, color: themeColor, size: 22),
              ),
              if (controller.unreadNotificationCount.value > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
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
    );
  }



  // ─────────────────────── HEADER ──────────────────────────────────

  Widget _buildRiwayatHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'riwayat'.tr,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: themeColor),
            ),
            SizedBox(height: 2),
            Text(
              'aktivitas_keuangan'.tr,
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.download_rounded, color: themeColor, size: 20),
            tooltip: 'export_data'.tr,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (String result) {
              if (result == 'PDF') {
                Get.snackbar('Export PDF', 'Sedang menyiapkan file PDF...', backgroundColor: Colors.black87, colorText: Colors.white);
              } else if (result == 'Excel') {
                Get.snackbar('Export Excel', 'Sedang menyiapkan file Excel...', backgroundColor: successColor, colorText: Colors.white);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'PDF',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('export_pdf'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('export_excel'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────── TOP SUMMARY ─────────────────────────────

  Widget _buildTopSummary() {
    final controller = Get.find<MemberDashboardController>();
    return Obx(() {
      final isLoading = controller.isLoadingGrowth.value;
      final data = controller.growthData.value;

      if (isLoading && data == null) {
        return _buildSummaryShimmer();
      }

      final double computedSavingsTotal = controller.approvedSavings.fold<double>(
        0.0,
        (sum, item) => sum + (item['balance'] ?? 0.0),
      );
      final totalBalance = (data?.savingTrend.totalBalance == null || data?.savingTrend.totalBalance == 0)
          ? computedSavingsTotal
          : data!.savingTrend.totalBalance;
      final totalPayroll =
          data?.payrollVsWithdrawal.payroll.fold<double>(0, (p, c) => p + c) ?? 0.0;
      final totalWithdrawal =
          data?.payrollVsWithdrawal.withdrawal.fold<double>(0, (p, c) => p + c) ?? 0.0;
      final isNewAccount = totalBalance == 0 && totalPayroll == 0 && totalWithdrawal == 0 && controller.recentTransactions.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNewAccount) ...[
            _buildNewAccountBanner(),
            const SizedBox(height: 16),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _summaryCard('total_simpanan'.tr, totalBalance, themeColor, Icons.account_balance_wallet_outlined),
                const SizedBox(width: 12),
                _summaryCard('total_payroll'.tr, totalPayroll, successColor, Icons.arrow_downward_rounded),
                const SizedBox(width: 12),
                _summaryCard('withdrawal'.tr, totalWithdrawal, warningColor, Icons.arrow_upward_rounded),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNewAccountBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [infoColor.withOpacity(0.12), infoColor.withOpacity(0.04)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: infoColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: infoColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: infoColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'akun_baru'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: infoColor),
                ),
                SizedBox(height: 3),
                Text(
                  'desc_akun_baru'.tr,
                  style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          3,
          (_) => Container(
            width: 150,
            height: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) {
    final isEmpty = amount == 0;
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color.withOpacity(0.7)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.4),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Rp ${_formatRupiah(amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isEmpty ? Colors.black26 : color,
            ),
          ),
          if (isEmpty) ...[
            const SizedBox(height: 2),
            Text('belum_ada_data'.tr, style: const TextStyle(fontSize: 8, color: Colors.black26)),
          ],
        ],
      ),
    );
  }

  // ─────────────────────── SAVINGS SECTION ─────────────────────────
  Widget _buildSavingsSection() {
    final controller = Get.find<MemberDashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'rincian_per_simpanan'.tr,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingSavings.value) {
            return _buildSavingsShimmer();
          }
          if (controller.approvedSavings.isEmpty) {
            return _buildEmptySavingsCard();
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.approvedSavings.map((saving) {
                final String typeName = saving['saving_type_name'] ?? 'Simpanan';
                // Use balance (recorded by admin) not amount (the original request amount)
                final double balance = (saving['balance'] ?? 0).toDouble();
                final String status = (saving['status'] ?? '').toString();
                final bool isPending = status == 'PENDING';
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _savingsCard(typeName.toUpperCase(), balance, status: status),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }


  Widget _buildEmptySavingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, size: 40, color: themeColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('simpanan_belum_tersedia'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black45)),
          const SizedBox(height: 4),
          Text(
            'desc_simpanan_belum_tersedia'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black38, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.withOpacity(0.6), size: 20),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildSavingsShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          2,
          (_) => Container(
            width: 260,
            height: 180,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _savingsCard(String title, double balance, {required String status}) {
    final bool isPending = status == 'PENDING';
    final bool isZeroBalance = balance == 0;
    
    String statusLabel = 'disetujui_pengurus'.tr;
    Color statusColor = successColor;
    IconData statusIcon = Icons.check_circle_outline;
    
    if (status == 'ACTIVE') {
      statusLabel = 'aktif'.tr;
      statusColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'INACTIVE') {
      statusLabel = 'nonaktif'.tr;
      statusColor = Colors.grey;
      statusIcon = Icons.cancel_outlined;
    } else if (status == 'DEACTIVATION_PENDING') {
      statusLabel = 'menunggu_nonaktif'.tr;
      statusColor = const Color(0xFFE65100);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (status == 'ACTIVATION_PENDING') {
      statusLabel = 'menunggu_aktif'.tr;
      statusColor = const Color(0xFFE65100);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (status == 'PENDING') {
      statusLabel = 'menunggu_persetujuan'.tr;
      statusColor = warningColor;
      statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPending || status == 'DEACTIVATION_PENDING' || status == 'ACTIVATION_PENDING'
              ? warningColor.withOpacity(0.3)
              : isZeroBalance
                  ? Colors.black.withOpacity(0.06)
                  : themeColor.withOpacity(0.12),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + badge
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isPending ? warningColor : isZeroBalance ? Colors.black38 : themeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: warningColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'menunggu'.tr,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: warningColor),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'ACTIVE' ? 'aktif'.tr : (status == 'INACTIVE' ? 'nonaktif'.tr : 'proses'.tr),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 14),

          // Status Simpanan
          Text(
            'status_simpanan'.tr,
            style: const TextStyle(fontSize: 9, color: Colors.black38, letterSpacing: 0.3),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                statusIcon,
                size: 13,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Jumlah Simpanan (dicatat oleh pengurus)
          Text('jumlah_simpanan'.tr, style: const TextStyle(fontSize: 9, color: Colors.black38, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(
            isPending ? 'Rp -' : 'Rp ${_formatRupiah(balance)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isPending ? Colors.black26 : isZeroBalance ? Colors.black38 : themeColor,
            ),
          ),

          // Info keterangan
          if (isPending) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: warningColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 11, color: warningColor),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'desc_saldo_pending'.tr,
                      style: TextStyle(fontSize: 9, color: warningColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == 'ACTIVE' && isZeroBalance) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: successColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 11, color: successColor),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'desc_saldo_aktif'.tr,
                      style: TextStyle(fontSize: 9, color: successColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showSavingDetailSheet(title, balance, status),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending ? warningColor.withOpacity(0.1) : isZeroBalance ? Colors.black.withOpacity(0.07) : themeColor,
              foregroundColor: isPending ? warningColor : isZeroBalance ? Colors.black38 : Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('lihat_detail'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── MUTATION SECTION ────────────────────────

  Widget _buildMutationSection() {
    final controller = Get.find<MemberDashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'mutasi_terbaru'.tr,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1),
            ),
            Obx(() {
              final totalTx = controller.recentTransactions.length;
              if (totalTx > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'n_transaksi'.trParams({'count': totalTx.toString()}),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 16),
        Builder(builder: (context) => _buildFilterBar(context)),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingTransactions.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: themeColor),
              ),
            );
          }
          if (controller.recentTransactions.isEmpty) {
            return _buildEmptyMutation();
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = controller.recentTransactions[index];
              return _buildTransactionItem(tx);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final type = tx['type'] ?? 'DEPOSIT';
    final isIncoming = type == 'DEPOSIT' || type == 'DEBIT';
    final double amount = (tx['amount'] ?? 0).toDouble();
    final String status = tx['status'] ?? 'SUCCESS';
    final bool isPending = status == 'PENDING';
    
    DateTime? dt;
    try {
      if (tx['date'] != null) {
        dt = DateTime.parse(tx['date']);
      }
    } catch (_) {}
    
    final dateStr = dt != null ? "${dt.day} ${_getBulan(dt.month)}" : '-';
    final timeStr = dt != null ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}" : '';
    
    final color = isIncoming ? successColor : themeColor;
    final prefix = isIncoming ? '+' : '-';
    
    return GestureDetector(
      onTap: () => _showTransactionDetail(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date block (BCA style left block)
            Container(
              width: 55,
              padding: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.black.withOpacity(0.08), width: 1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (timeStr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Middle: description & type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (tx['saving_type'] ?? 'Simpanan').toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx['description'] ?? '-',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black38,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Right: amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$prefix${_formatRupiah(amount)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                if (isPending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: warningColor),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> tx) {
    final type = tx['type'] ?? 'DEPOSIT';
    final isIncoming = type == 'DEPOSIT' || type == 'DEBIT';
    final double amount = (tx['amount'] ?? 0).toDouble();
    final String status = tx['status'] ?? 'SUCCESS';
    final bool isPending = status == 'PENDING';
    
    DateTime? dt;
    try {
      if (tx['date'] != null) {
        dt = DateTime.parse(tx['date']);
      }
    } catch (_) {}
    
    final dateStr = dt != null ? "${dt.day} ${_getBulan(dt.month)} ${dt.year}" : '-';
    final timeStr = dt != null ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}" : '';
    
    final amountColor = isIncoming ? successColor : themeColor;
    final prefix = isIncoming ? '+' : '-';
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rincian Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: themeColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    isIncoming ? 'Simpanan Masuk' : 'Penarikan Dana',
                    style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$prefix Rp ${_formatRupiah(amount)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? warningColor.withOpacity(0.1) : successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPending ? 'MENUNGGU PERSETUJUAN' : 'BERHASIL',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isPending ? warningColor : successColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Divider(color: Colors.black.withOpacity(0.06), height: 1),
            const SizedBox(height: 20),
            _detailRow('Jenis Simpanan', (tx['saving_type'] ?? '-').toString().toUpperCase()),
            _detailRow('Waktu Transaksi', dt != null ? '$dateStr, Pukul $timeStr WIB' : '-'),
            _detailRow('Keterangan', tx['description'] ?? '-'),
            const SizedBox(height: 16),
            if (tx['transfer_proof'] != null && tx['transfer_proof'] != '-') ...[
              OutlinedButton.icon(
                onPressed: () => _showProofDialog(tx['transfer_proof']),
                icon: const Icon(Icons.receipt_long_rounded, size: 18, color: themeColor),
                label: const Text(
                  'Lihat Bukti Transfer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: themeColor),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  side: const BorderSide(color: themeColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
            ],
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Tutup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showProofDialog(String proofUrl) {
    // Tentukan URL penuh.
    final String fullUrl = proofUrl.startsWith('http') ? proofUrl : '$baseUrl$proofUrl';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bukti Transfer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(color: themeColor),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar bukti transfer',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _downloadProof(fullUrl),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Simpan Ke Perangkat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadProof(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String path = "/storage/emulated/0/Download";
        final dir = Directory(path);
        if (!await dir.exists()) {
          path = (await Directory.systemTemp.createTemp()).path;
        }

        final fileName = "bukti_transfer_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File("$path/$fileName");
        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar(
          'Unduhan Berhasil',
          'Bukti transfer disimpan di: $path/$fileName',
          backgroundColor: successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Unduhan Gagal',
          'Server merespons dengan status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Unduhan Gagal',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold, height: 1.4),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _getBulan(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Widget _buildEmptyMutation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, size: 28, color: themeColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 14),
          const Text('Belum Ada Transaksi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black45)),
          const SizedBox(height: 6),
          const Text(
            'Semua mutasi debit dan kredit akan\ntercatat dan tampil di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black38, height: 1.5),
          ),
        ],
      ),
    );
  }
  Future<void> _pickDateRange(BuildContext context, {bool isDetail = false}) async {
    final controller = Get.find<MemberDashboardController>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: isDetail
          ? (controller.detailStartDate.value != null && controller.detailEndDate.value != null
              ? DateTimeRange(start: controller.detailStartDate.value!, end: controller.detailEndDate.value!)
              : null)
          : (controller.filterStartDate.value != null && controller.filterEndDate.value != null
              ? DateTimeRange(start: controller.filterStartDate.value!, end: controller.filterEndDate.value!)
              : null),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: themeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isDetail) {
        controller.detailStartDate.value = picked.start;
        controller.detailEndDate.value = picked.end;
      } else {
        controller.filterStartDate.value = picked.start;
        controller.filterEndDate.value = picked.end;
      }
    }
  }

  Widget _buildFilterBar(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: PopupMenuButton<String>(
                initialValue: controller.selectedSavingFilter.value,
                onSelected: (val) {
                  controller.selectedSavingFilter.value = val;
                },
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, size: 14, color: themeColor),
                    const SizedBox(width: 6),
                    Text(
                      'Tipe: ${controller.selectedSavingFilter.value}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black45),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Semua', child: Text('Semua Simpanan', style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: 'Pokok', child: Text('Simpanan Pokok', style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: 'Wajib', child: Text('Simpanan Wajib', style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: 'Sukarela', child: Text('Simpanan Sukarela', style: TextStyle(fontSize: 12))),
                ],
              ),
            )),
            const SizedBox(width: 10),
            Obx(() {
              final start = controller.filterStartDate.value;
              final end = controller.filterEndDate.value;
              final hasFilter = start != null && end != null;
              final label = hasFilter ? '${start.day}/${start.month} - ${end.day}/${end.month}' : 'Filter Tanggal';
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hasFilter ? themeColor.withOpacity(0.3) : Colors.black.withOpacity(0.06)),
                ),
                child: InkWell(
                  onTap: () => _pickDateRange(context),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: themeColor),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasFilter ? themeColor : Colors.black87,
                        ),
                      ),
                      if (hasFilter) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            controller.filterStartDate.value = null;
                            controller.filterEndDate.value = null;
                          },
                          child: const Icon(Icons.close, size: 14, color: Colors.black45),
                        ),
                      ] else ...[
                        const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black45),
                      ]
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSavingDetailSheet(String title, double balance, String status) {
    final controller = Get.find<MemberDashboardController>();
    controller.detailStartDate.value = null;
    controller.detailEndDate.value = null;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == 'ACTIVE' 
                        ? 'Status: Aktif' 
                        : (status == 'INACTIVE' 
                            ? 'Status: Nonaktif' 
                            : (status == 'DEACTIVATION_PENDING' 
                                ? 'Status: Menunggu Nonaktif' 
                                : (status == 'ACTIVATION_PENDING' 
                                    ? 'Status: Menunggu Aktif' 
                                    : 'Status: Menunggu Persetujuan'))),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: status == 'ACTIVE' 
                          ? const Color(0xFF2E7D32) 
                          : (status == 'INACTIVE' 
                              ? Colors.grey 
                              : (status == 'PENDING' ? warningColor : const Color(0xFFE65100))),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Saldo', style: TextStyle(fontSize: 9, color: Colors.black38)),
                    const SizedBox(height: 3),
                    Text(
                      'Rp ${_formatRupiah(balance)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: themeColor),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.black.withOpacity(0.06), height: 1),
            const SizedBox(height: 16),
            Builder(builder: (context) => _buildDetailFilterBar(context)),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                final txs = controller.getDetailTransactions(title);
                if (txs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.03)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded, size: 28, color: Colors.black26),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada riwayat transaksi',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return _buildTransactionItem(tx);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailFilterBar(BuildContext context) {
    final controller = Get.find<MemberDashboardController>();
    return Obx(() {
      final start = controller.detailStartDate.value;
      final end = controller.detailEndDate.value;
      final hasFilter = start != null && end != null;
      final label = hasFilter ? '${start.day}/${start.month} - ${end.day}/${end.month}' : 'Filter Rentang Tanggal';
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hasFilter ? themeColor.withOpacity(0.3) : Colors.black.withOpacity(0.04)),
        ),
        child: InkWell(
          onTap: () => _pickDateRange(context, isDetail: true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 14, color: themeColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasFilter ? themeColor : Colors.black54,
                    ),
                  ),
                ],
              ),
              if (hasFilter)
                GestureDetector(
                  onTap: () {
                    controller.detailStartDate.value = null;
                    controller.detailEndDate.value = null;
                  },
                  child: const Icon(Icons.close, size: 14, color: Colors.black45),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black38),
            ],
          ),
        ),
      );
    });
  }

}


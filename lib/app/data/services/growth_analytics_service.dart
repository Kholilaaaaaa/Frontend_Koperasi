import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../network/api_client.dart';
import '../models/growth_analytics_model.dart';

/// Hasil dari fetchGrowthAnalytics: bisa sukses, error biasa, atau sebelum tanggal bergabung.
class GrowthAnalyticsResult {
  final GrowthAnalyticsModel? data;
  final bool isBeforeJoinDate;
  final String? errorMessage;

  GrowthAnalyticsResult({
    this.data,
    this.isBeforeJoinDate = false,
    this.errorMessage,
  });

  bool get isSuccess => data != null && !isBeforeJoinDate;
}

/// Model untuk jenis simpanan.
class SavingTypeItem {
  final int id;
  final String name;
  final String code;
  SavingTypeItem({required this.id, required this.name, required this.code});
  factory SavingTypeItem.fromJson(Map<String, dynamic> json) {
    return SavingTypeItem(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String? ?? json['name'] as String,
    );
  }
}

/// Service untuk mengambil data analytics pertumbuhan dari backend.
class GrowthAnalyticsService {
  /// Fetch daftar jenis simpanan yang dimiliki member.
  static Future<List<SavingTypeItem>> fetchSavingTypes() async {
    try {
      final response = await authorizedGet('/api/member/saving-types');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final list = data['saving_types'] as List<dynamic>? ?? [];
          return list.map((e) => SavingTypeItem.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('[GrowthAnalyticsService] fetchSavingTypes error: $e');
    }
    return [];
  }

  /// Fetch data analytics pertumbuhan dari backend.
  /// [startDate] dan [endDate] menentukan rentang data.
  /// [savingTypeId] jika null = semua jenis simpanan.
  static Future<GrowthAnalyticsResult> fetchGrowthAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    int? savingTypeId,
  }) async {
    try {
      final now = DateTime.now();
      final params = <String>[];
      if (startDate != null) {
        final fmt = DateFormat('yyyy-MM-dd');
        params.add('start_date=${fmt.format(startDate)}');
        params.add('end_date=${fmt.format(endDate ?? now)}');
      }
      if (savingTypeId != null) {
        params.add('saving_type_id=$savingTypeId');
      }
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';

      final response = await authorizedGet(
        '/api/growth-analytics$query',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return GrowthAnalyticsResult(data: GrowthAnalyticsModel.fromJson(data));
        }
      }

      if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (data['error'] == 'before_join_date') {
          return GrowthAnalyticsResult(
            isBeforeJoinDate: true,
            errorMessage: data['message'] as String?,
          );
        }
      }

      print('[GrowthAnalyticsService] Error: ${response.statusCode} - ${response.body}');
      return GrowthAnalyticsResult(errorMessage: 'Gagal memuat data analytics (${response.statusCode})');
    } catch (e) {
      print('[GrowthAnalyticsService] Exception: $e');
      return GrowthAnalyticsResult(errorMessage: 'Error: $e');
    }
  }
}


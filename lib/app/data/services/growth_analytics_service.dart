import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../network/api_client.dart';
import '../models/growth_analytics_model.dart';

/// Service untuk mengambil data analytics pertumbuhan dari backend.
/// Berkomunikasi dengan endpoint: GET /api/growth-analytics
class GrowthAnalyticsService {
  /// Fetch data analytics pertumbuhan dari backend.
  /// [period] bisa 'Mingguan', 'Bulanan', atau 'Tahunan'.
  static Future<GrowthAnalyticsModel?> fetchGrowthAnalytics({
    String period = 'Bulanan',
  }) async {
    try {
      final response = await authorizedGet(
        '/api/growth-analytics?period=$period',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return GrowthAnalyticsModel.fromJson(data);
        }
      }

      print('[GrowthAnalyticsService] Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('[GrowthAnalyticsService] Exception: $e');
      return null;
    }
  }
}

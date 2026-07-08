// Model data untuk response endpoint /api/growth-analytics
// Digunakan oleh GrowthView untuk menampilkan data analitik real-time.

class GrowthAnalyticsModel {
  final SavingTrendData savingTrend;
  final EconomicData economicData;
  final EconomicSummary economicSummary;
  final EconomicHealth economicHealth;
  final List<AiInsight> aiInsights;
  final GrowthPrediction prediction;
  final PayrollWithdrawalData payrollVsWithdrawal;
  final HealthScore health;
  final MemberInfo memberInfo;

  GrowthAnalyticsModel({
    required this.savingTrend,
    required this.economicData,
    required this.economicSummary,
    required this.economicHealth,
    required this.aiInsights,
    required this.prediction,
    required this.payrollVsWithdrawal,
    required this.health,
    required this.memberInfo,
  });

  factory GrowthAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return GrowthAnalyticsModel(
      savingTrend: SavingTrendData.fromJson(json['saving_trend'] ?? {}),
      economicData: EconomicData.fromJson(json['economic_data'] ?? {}),
      economicSummary: EconomicSummary.fromJson(json['economic_summary'] ?? {}),
      economicHealth: EconomicHealth.fromJson(json['economic_health'] ?? {}),
      aiInsights: (json['ai_insights'] as List<dynamic>?)
              ?.map((e) => AiInsight.fromJson(e))
              .toList() ??
          [],
      prediction: GrowthPrediction.fromJson(json['prediction'] ?? {}),
      payrollVsWithdrawal:
          PayrollWithdrawalData.fromJson(json['payroll_vs_withdrawal'] ?? {}),
      health: HealthScore.fromJson(json['health'] ?? {}),
      memberInfo: MemberInfo.fromJson(json['member_info'] ?? {}),
    );
  }
}

class SavingTrendData {
  final List<String> months;
  final List<double> values;
  final List<double> depositData;
  final List<double> withdrawalData;
  final double growthPct;
  final double totalBalance;
  final int totalTx;
  final int activeMembers;
  final List<SavingDistribution> distribution;
  final String? selectedSavingTypeName;

  SavingTrendData({
    required this.months,
    required this.values,
    required this.depositData,
    required this.withdrawalData,
    required this.growthPct,
    required this.totalBalance,
    required this.totalTx,
    required this.activeMembers,
    required this.distribution,
    this.selectedSavingTypeName,
  });

  factory SavingTrendData.fromJson(Map<String, dynamic> json) {
    return SavingTrendData(
      months: List<String>.from(json['months'] ?? []),
      values: (json['values'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      depositData: (json['deposit_data'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      withdrawalData: (json['withdrawal_data'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      growthPct: (json['growth_pct'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      totalTx: (json['total_tx'] as num?)?.toInt() ?? 0,
      activeMembers: (json['active_members'] as num?)?.toInt() ?? 0,
      distribution: (json['distribution'] as List<dynamic>?)
              ?.map((e) => SavingDistribution.fromJson(e))
              .toList() ??
          [],
      selectedSavingTypeName: json['selected_saving_type_name'] as String?,
    );
  }
}

class SavingDistribution {
  final String name;
  final double value;

  SavingDistribution({required this.name, required this.value});

  factory SavingDistribution.fromJson(Map<String, dynamic> json) {
    return SavingDistribution(
      name: json['name'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FoodCommodity {
  final String name;
  final double price;

  FoodCommodity({required this.name, required this.price});

  factory FoodCommodity.fromJson(Map<String, dynamic> json) {
    return FoodCommodity(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EconomicData {
  final List<double> inflation;
  final List<double> biRate;
  final List<double> usdIdr;
  final List<double> foodPrices;
  final double? foodPriceChangePct;
  final List<String> months;
  final List<FoodCommodity> foodCommodities;

  EconomicData({
    required this.inflation,
    required this.biRate,
    required this.usdIdr,
    required this.foodPrices,
    this.foodPriceChangePct,
    required this.months,
    required this.foodCommodities,
  });

  factory EconomicData.fromJson(Map<String, dynamic> json) {
    return EconomicData(
      inflation: (json['inflation'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      biRate: (json['bi_rate'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      usdIdr: (json['usd_idr'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      foodPrices: (json['food_prices'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      foodPriceChangePct: (json['food_price_change_pct'] as num?)?.toDouble(),
      months: List<String>.from(json['months'] ?? []),
      foodCommodities: (json['food_commodities'] as List<dynamic>?)
              ?.map((e) => FoodCommodity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EconomicSummary {
  final double? latestInflation;
  final double? latestBiRate;
  final double? latestUsdIdr;
  final double? latestFoodPrice;
  final double? foodPriceChangePct;
  final double? avgInflation;
  final double? avgBiRate;
  final double? avgUsdIdr;
  final String source;
  final String? lastUpdated;

  EconomicSummary({
    this.latestInflation,
    this.latestBiRate,
    this.latestUsdIdr,
    this.latestFoodPrice,
    this.foodPriceChangePct,
    this.avgInflation,
    this.avgBiRate,
    this.avgUsdIdr,
    this.source = 'Bank Indonesia',
    this.lastUpdated,
  });

  factory EconomicSummary.fromJson(Map<String, dynamic> json) {
    return EconomicSummary(
      latestInflation: (json['latest_inflation'] as num?)?.toDouble(),
      latestBiRate: (json['latest_bi_rate'] as num?)?.toDouble(),
      latestUsdIdr: (json['latest_usd_idr'] as num?)?.toDouble(),
      latestFoodPrice: (json['latest_food_price'] as num?)?.toDouble(),
      foodPriceChangePct: (json['food_price_change_pct'] as num?)?.toDouble(),
      avgInflation: (json['avg_inflation'] as num?)?.toDouble(),
      avgBiRate: (json['avg_bi_rate'] as num?)?.toDouble(),
      avgUsdIdr: (json['avg_usd_idr'] as num?)?.toDouble(),
      source: json['source'] ?? 'Bank Indonesia',
      lastUpdated: json['last_updated'] as String?,
    );
  }
}

class RadarScore {
  final String label;
  final int value;

  RadarScore({required this.label, required this.value});

  factory RadarScore.fromJson(Map<String, dynamic> json) {
    return RadarScore(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toInt() ?? 50,
    );
  }
}

class EconomicHealth {
  final int score;
  final String status;
  final List<RadarScore> radarScores;

  EconomicHealth({
    required this.score,
    required this.status,
    required this.radarScores,
  });

  factory EconomicHealth.fromJson(Map<String, dynamic> json) {
    return EconomicHealth(
      score: (json['score'] as num?)?.toInt() ?? 50,
      status: json['status'] ?? 'Stabil',
      radarScores: (json['radar_scores'] as List<dynamic>?)
              ?.map((e) => RadarScore.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AiInsight {
  final String type; // "warning", "success", "info"
  final String title;
  final String message;
  final double confidence;

  AiInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.confidence,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GrowthPrediction {
  final double nextMonthGrowthPct;
  final int probability;
  final String trendDirection; // "up", "down", "stable"
  final double predictedBalance;

  GrowthPrediction({
    required this.nextMonthGrowthPct,
    required this.probability,
    required this.trendDirection,
    required this.predictedBalance,
  });

  factory GrowthPrediction.fromJson(Map<String, dynamic> json) {
    return GrowthPrediction(
      nextMonthGrowthPct:
          (json['next_month_growth_pct'] as num?)?.toDouble() ?? 0.0,
      probability: (json['probability'] as num?)?.toInt() ?? 50,
      trendDirection: json['trend_direction'] ?? 'stable',
      predictedBalance:
          (json['predicted_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PayrollWithdrawalData {
  final List<String> months;
  final List<double> payroll;
  final List<double> withdrawal;

  PayrollWithdrawalData({
    required this.months,
    required this.payroll,
    required this.withdrawal,
  });

  factory PayrollWithdrawalData.fromJson(Map<String, dynamic> json) {
    return PayrollWithdrawalData(
      months: List<String>.from(json['months'] ?? []),
      payroll: (json['payroll'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      withdrawal: (json['withdrawal'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}

class HealthScore {
  final int score;
  final String status; // "Sangat Baik", "Stabil", "Waspada", "Risiko Tinggi"

  HealthScore({required this.score, required this.status});

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      score: (json['score'] as num?)?.toInt() ?? 50,
      status: json['status'] ?? 'Stabil',
    );
  }
}

/// Info anggota yang dikembalikan oleh backend (termasuk tanggal bergabung)
class MemberInfo {
  final String? dateJoined; // format: 'YYYY-MM-DD'

  MemberInfo({this.dateJoined});

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      dateJoined: json['date_joined'] as String?,
    );
  }
}

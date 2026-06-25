/// Model data untuk response endpoint /api/growth-analytics
/// Digunakan oleh GrowthView untuk menampilkan data analitik real-time.

class GrowthAnalyticsModel {
  final SavingTrendData savingTrend;
  final EconomicData economicData;
  final List<AiInsight> aiInsights;
  final GrowthPrediction prediction;
  final PayrollWithdrawalData payrollVsWithdrawal;
  final HealthScore health;

  GrowthAnalyticsModel({
    required this.savingTrend,
    required this.economicData,
    required this.aiInsights,
    required this.prediction,
    required this.payrollVsWithdrawal,
    required this.health,
  });

  factory GrowthAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return GrowthAnalyticsModel(
      savingTrend: SavingTrendData.fromJson(json['saving_trend'] ?? {}),
      economicData: EconomicData.fromJson(json['economic_data'] ?? {}),
      aiInsights: (json['ai_insights'] as List<dynamic>?)
              ?.map((e) => AiInsight.fromJson(e))
              .toList() ??
          [],
      prediction: GrowthPrediction.fromJson(json['prediction'] ?? {}),
      payrollVsWithdrawal:
          PayrollWithdrawalData.fromJson(json['payroll_vs_withdrawal'] ?? {}),
      health: HealthScore.fromJson(json['health'] ?? {}),
    );
  }
}

class SavingTrendData {
  final List<String> months;
  final List<double> values;
  final double growthPct;
  final double totalBalance;
  final int totalTx;
  final int activeMembers;
  final List<SavingDistribution> distribution;

  SavingTrendData({
    required this.months,
    required this.values,
    required this.growthPct,
    required this.totalBalance,
    required this.totalTx,
    required this.activeMembers,
    required this.distribution,
  });

  factory SavingTrendData.fromJson(Map<String, dynamic> json) {
    return SavingTrendData(
      months: List<String>.from(json['months'] ?? []),
      values: (json['values'] as List<dynamic>?)
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

class EconomicData {
  final List<double> inflation;
  final List<double> biRate;
  final List<double> usdIdr;
  final List<String> months;

  EconomicData({
    required this.inflation,
    required this.biRate,
    required this.usdIdr,
    required this.months,
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
      months: List<String>.from(json['months'] ?? []),
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

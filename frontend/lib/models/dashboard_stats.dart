// models/dashboard_stats.dart
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_stats.g.dart';

@JsonSerializable()
class DashboardStats {
  final int transactionsToday;
  final int transactionsThisWeek;
  final double revenueToday;
  final double revenueThisWeek;
  final int failedTransactions;
  final List<RevenueData> revenueTrend;

  DashboardStats({
    required this.transactionsToday,
    required this.transactionsThisWeek,
    required this.revenueToday,
    required this.revenueThisWeek,
    required this.failedTransactions,
    required this.revenueTrend,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

@JsonSerializable()
class RevenueData {
  final String date;
  final double revenue;

  RevenueData({
    required this.date,
    required this.revenue,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) => _$RevenueDataFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueDataToJson(this);
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      transactionsToday: (json['transactionsToday'] as num).toInt(),
      transactionsThisWeek: (json['transactionsThisWeek'] as num).toInt(),
      revenueToday: (json['revenueToday'] as num).toDouble(),
      revenueThisWeek: (json['revenueThisWeek'] as num).toDouble(),
      failedTransactions: (json['failedTransactions'] as num).toInt(),
      revenueTrend: (json['revenueTrend'] as List<dynamic>)
          .map((e) => RevenueData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'transactionsToday': instance.transactionsToday,
      'transactionsThisWeek': instance.transactionsThisWeek,
      'revenueToday': instance.revenueToday,
      'revenueThisWeek': instance.revenueThisWeek,
      'failedTransactions': instance.failedTransactions,
      'revenueTrend': instance.revenueTrend,
    };

RevenueData _$RevenueDataFromJson(Map<String, dynamic> json) => RevenueData(
  date: json['date'] as String,
  revenue: (json['revenue'] as num).toDouble(),
);

Map<String, dynamic> _$RevenueDataToJson(RevenueData instance) =>
    <String, dynamic>{'date': instance.date, 'revenue': instance.revenue};

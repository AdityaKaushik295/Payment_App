// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentListResponse _$PaymentListResponseFromJson(Map<String, dynamic> json) =>
    PaymentListResponse(
      payments: (json['payments'] as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentListResponseToJson(
  PaymentListResponse instance,
) => <String, dynamic>{'payments': instance.payments, 'total': instance.total};

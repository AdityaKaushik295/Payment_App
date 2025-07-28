// models/payment_list_response.dart
import 'package:json_annotation/json_annotation.dart';
import 'payment.dart';

part 'payment_list_response.g.dart';

@JsonSerializable()
class PaymentListResponse {
  final List<Payment> payments;
  final int total;

  PaymentListResponse({
    required this.payments,
    required this.total,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) => _$PaymentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentListResponseToJson(this);
}
enum PaymentStatus { success, failed, pending }
enum PaymentMethod { credit_card, debit_card, paypal, bank_transfer, upi, wallet }

class Payment {
  final String id;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String receiver;
  final String? description;
  final String? transactionId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.receiver,
    this.description,
    this.transactionId,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Custom fromJson to handle type inconsistencies
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      method: _parsePaymentMethod(json['method']),
      status: _parsePaymentStatus(json['status']),
      receiver: json['receiver'] as String,
      description: json['description']?.toString(),
      transactionId: json['transactionid']?.toString(),
      failureReason: json['failurereason']?.toString(),
      createdAt: DateTime.parse(json['createdat']),
      updatedAt: DateTime.parse(json['updatedat']),
    );
  }

  /// Optional: safer toJson in case you need it
  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'method': method.name,
    'status': status.name,
    'receiver': receiver,
    'description': description,
    'transactionid': transactionId,
    'failurereason': failureReason,
    'createdat': createdAt.toIso8601String(),
    'updatedat': updatedAt.toIso8601String(),
  };

  static PaymentMethod _parsePaymentMethod(dynamic value) {
    if (value is String) {
      return PaymentMethod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PaymentMethod.wallet, // fallback
      );
    }
    throw Exception('Invalid PaymentMethod: $value');
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    if (value is String) {
      return PaymentStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PaymentStatus.pending, // fallback
      );
    }
    throw Exception('Invalid PaymentStatus: $value');
  }

  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.credit_card:
        return 'Credit Card';
      case PaymentMethod.debit_card:
        return 'Debit Card';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.bank_transfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case PaymentStatus.success:
        return 'Success';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }
}

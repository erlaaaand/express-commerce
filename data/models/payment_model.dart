class PaymentModel {
  final String orderId;
  final String paymentToken;
  final String paymentUrl;
  final int amount;
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionId;
  final String? paymentType;

  PaymentModel({
    required this.orderId,
    required this.paymentToken,
    required this.paymentUrl,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.transactionId,
    this.paymentType,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      paymentToken: json['paymentToken'] ?? json['token'] ?? '',
      paymentUrl: json['paymentUrl'] ?? json['redirect_url'] ?? '',
      amount: json['amount'] ?? json['gross_amount'] ?? 0,
      status: json['status'] ?? json['transaction_status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      transactionId: json['transactionId'] ?? json['transaction_id'],
      paymentType: json['paymentType'] ?? json['payment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentToken': paymentToken,
      'paymentUrl': paymentUrl,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'paymentType': paymentType,
    };
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isSuccess => status.toLowerCase() == 'success' || 
                        status.toLowerCase() == 'settlement' ||
                        status.toLowerCase() == 'capture';
  bool get isFailed => status.toLowerCase() == 'failed' || 
                       status.toLowerCase() == 'deny' ||
                       status.toLowerCase() == 'cancel' ||
                       status.toLowerCase() == 'expire';

  PaymentModel copyWith({
    String? orderId,
    String? paymentToken,
    String? paymentUrl,
    int? amount,
    String? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? transactionId,
    String? paymentType,
  }) {
    return PaymentModel(
      orderId: orderId ?? this.orderId,
      paymentToken: paymentToken ?? this.paymentToken,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      transactionId: transactionId ?? this.transactionId,
      paymentType: paymentType ?? this.paymentType,
    );
  }
}

class CheckoutRequest {
  final String shippingAddress;
  final String? notes;

  CheckoutRequest({
    required this.shippingAddress,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'shippingAddress': shippingAddress,
      if (notes != null) 'notes': notes,
    };
  }
}

class CheckoutResponse {
  final String orderId;
  final String paymentToken;
  final String paymentUrl;
  final int totalAmount;

  CheckoutResponse({
    required this.orderId,
    required this.paymentToken,
    required this.paymentUrl,
    required this.totalAmount,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      paymentToken: json['paymentToken'] ?? json['token'] ?? '',
      paymentUrl: json['paymentUrl'] ?? json['redirect_url'] ?? '',
      totalAmount: json['totalAmount'] ?? json['gross_amount'] ?? 0,
    );
  }
}
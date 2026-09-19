// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT MODEL
// ═══════════════════════════════════════════════════════════════════════════
//
// Backend responses vary by endpoint:
//
// POST /api/payment/submit → data:
// {
//   "paymentId": "6aaec909a362496443b2fc11",
//   "gymName": "Astha Bhardwaj",
//   "gymId": "asthabhardwaj007",
//   "plan": "STARTER",
//   "amount": 5000,
//   "paymentStatus": "PENDING"
// }
//
// POST /api/payment/approve → data:
// {
//   "paymentId": "6aaec909a362496443b2fc11",
//   "paymentStatus": "APPROVED",
//   "membershipStatus": "ACTIVE",
//   "membershipStartDate": "2026-09-19T17:47:54.632Z",
//   "membershipEndDate": "2026-10-19T17:47:54.632Z"
// }
//
// POST /api/payment/reject → data:
// {
//   "paymentId": "6aaed3de061e0c339541b37a",
//   "paymentStatus": "REJECTED",
//   "membershipStatus": "PENDING"
// }
// ═══════════════════════════════════════════════════════════════════════════

class PaymentModel {
  final String paymentId;
  final String? gymName;
  final String? gymId;
  final String? plan;
  final num? amount;
  final String paymentStatus;
  final String? membershipStatus;
  final String? membershipStartDate;
  final String? membershipEndDate;

  const PaymentModel({
    required this.paymentId,
    this.gymName,
    this.gymId,
    this.plan,
    this.amount,
    required this.paymentStatus,
    this.membershipStatus,
    this.membershipStartDate,
    this.membershipEndDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: (json['paymentId'] ?? '').toString(),
      gymName: json['gymName']?.toString(),
      gymId: json['gymId']?.toString(),
      plan: json['plan']?.toString(),
      amount: json['amount'] is num ? json['amount'] as num : null,
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      membershipStatus: json['membershipStatus']?.toString(),
      membershipStartDate: json['membershipStartDate']?.toString(),
      membershipEndDate: json['membershipEndDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    if (gymName != null) 'gymName': gymName,
    if (gymId != null) 'gymId': gymId,
    if (plan != null) 'plan': plan,
    if (amount != null) 'amount': amount,
    'paymentStatus': paymentStatus,
    if (membershipStatus != null) 'membershipStatus': membershipStatus,
    if (membershipStartDate != null) 'membershipStartDate': membershipStartDate,
    if (membershipEndDate != null) 'membershipEndDate': membershipEndDate,
  };

  @override
  String toString() =>
      'PaymentModel(paymentId: $paymentId, gymId: $gymId, '
      'plan: $plan, amount: $amount, paymentStatus: $paymentStatus, '
      'membershipStatus: $membershipStatus)';
}

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT SUBMIT REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/payment/submit
// Body: {
//   "ownerId": "6aaec8ffa362496443b2fc10",
//   "gymId": "asthabhardwaj007",
//   "plan": "STARTER",
//   "amount": 5000
// }
// ═══════════════════════════════════════════════════════════════════════════

class PaymentSubmitRequest {
  final String ownerId;
  final String gymId;
  final String plan;
  final num amount;

  const PaymentSubmitRequest({
    required this.ownerId,
    required this.gymId,
    required this.plan,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'ownerId': ownerId,
    'gymId': gymId,
    'plan': plan,
    'amount': amount,
  };
}

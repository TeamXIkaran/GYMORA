// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT MODEL
// ═══════════════════════════════════════════════════════════════════════════
//
// Backend responses:
//
// POST /api/payment/submit
//
// Request: { "ownerId": "6ab147e9f23477a887d1a8ae" }
//
// Response:
// {
//   "success": true,
//   "message": "Payment approved and membership activated successfully",
//   "data": {
//     "paymentId": "6ab147ecf23477a887d1a8af",
//     "gymName": "Karan Bisht",
//     "gymId": "0002",
//     "plan": "STARTER",
//     "amount": 5000,
//     "paymentStatus": "APPROVED",
//     "membershipStatus": "ACTIVE",
//     "membershipStartDate": "2026-09-21T15:21:48.347Z",
//     "membershipEndDate": "2026-10-21T15:21:48.347Z"
//   }
// }
//
// GET /api/payment/status/{paymentId}
//
// {
//   "success": true,
//   "data": {
//     "paymentId": "6ab147ecf23477a887d1a8af",
//     "paymentStatus": "APPROVED",
//     "membershipStatus": "ACTIVE"
//   }
// }
//
// POST /api/payment/approve
//
// {
//   "paymentId": "6aaec909a362496443b2fc11",
//   "paymentStatus": "APPROVED",
//   "membershipStatus": "ACTIVE",
//   "membershipStartDate": "2026-09-19T17:47:54.632Z",
//   "membershipEndDate": "2026-10-19T17:47:54.632Z"
// }
//
// POST /api/payment/reject
//
// {
//   "paymentId": "6aaed3de061e0c339541b37a",
//   "paymentStatus": "REJECTED",
//   "membershipStatus": "PENDING"
// }
//
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
    final rawAmount = json['amount'];

    num? parsedAmount;

    if (rawAmount is num) {
      parsedAmount = rawAmount;
    } else if (rawAmount != null) {
      parsedAmount = num.tryParse(rawAmount.toString());
    }

    return PaymentModel(
      paymentId: (json['paymentId'] ?? '').toString(),
      gymName: json['gymName']?.toString(),
      gymId: json['gymId']?.toString(),
      plan: json['plan']?.toString(),
      amount: parsedAmount,
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      membershipStatus: json['membershipStatus']?.toString(),
      membershipStartDate: json['membershipStartDate']?.toString(),
      membershipEndDate: json['membershipEndDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      if (gymName != null) 'gymName': gymName,
      if (gymId != null) 'gymId': gymId,
      if (plan != null) 'plan': plan,
      if (amount != null) 'amount': amount,
      'paymentStatus': paymentStatus,
      if (membershipStatus != null) 'membershipStatus': membershipStatus,
      if (membershipStartDate != null)
        'membershipStartDate': membershipStartDate,
      if (membershipEndDate != null) 'membershipEndDate': membershipEndDate,
    };
  }

  @override
  String toString() {
    return 'PaymentModel('
        'paymentId: $paymentId, '
        'gymId: $gymId, '
        'plan: $plan, '
        'amount: $amount, '
        'paymentStatus: $paymentStatus, '
        'membershipStatus: $membershipStatus'
        ')';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT SUBMIT REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/payment/submit
//
// Body: { "ownerId": "6ab147e9f23477a887d1a8ae" }
//
// ═══════════════════════════════════════════════════════════════════════════

class PaymentSubmitRequest {
  final String ownerId;

  const PaymentSubmitRequest({required this.ownerId});

  Map<String, dynamic> toJson() {
    return {'ownerId': ownerId};
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OWNER MODEL
// ═══════════════════════════════════════════════════════════════════════════
//
// Backend response (GET /api/owner/profile → data.owner):
// {
//   "_id": "6aaece1c04339912ba696a3c",
//   "gymName": "Test Gym 2",
//   "gymId": "TEST201",
//   "ownerName": "Test Owner 2",
//   "email": "radhamadav31@gmail.com",
//   "phone": "9876543210",
//   "plan": "STARTER",
//   "paymentStatus": "APPROVED",
//   "membershipStatus": "ACTIVE",
//   "createdAt": "2026-09-19T18:02:04.884Z",
//   "updatedAt": "2026-09-19T18:02:54.012Z",
//   "membershipEndDate": "2026-10-19T18:02:53.940Z",
//   "membershipStartDate": "2026-09-19T18:02:53.940Z"
// }
//
// Backend response (POST /api/owner/login → data.owner):
// {
//   "id": "6aaece1c04339912ba696a3c",
//   "gymName": "Test Gym 2",
//   "gymId": "TEST201",
//   "ownerName": "Test Owner 2",
//   "email": "radhamadav31@gmail.com",
//   "plan": "STARTER",
//   "membershipStatus": "ACTIVE",
//   "membershipStartDate": "2026-09-19T18:02:53.940Z",
//   "membershipEndDate": "2026-10-19T18:02:53.940Z"
// }
// ═══════════════════════════════════════════════════════════════════════════

class OwnerModel {
  final String id;
  final String gymName;
  final String gymId;
  final String ownerName;
  final String email;
  final String? phone;
  final String? plan;
  final String? paymentStatus;
  final String? membershipStatus;
  final String? membershipStartDate;
  final String? membershipEndDate;
  final String? createdAt;
  final String? updatedAt;

  const OwnerModel({
    required this.id,
    required this.gymName,
    required this.gymId,
    required this.ownerName,
    required this.email,
    this.phone,
    this.plan,
    this.paymentStatus,
    this.membershipStatus,
    this.membershipStartDate,
    this.membershipEndDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Login returns "id", Profile returns "_id" — handle both
  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      gymName: (json['gymName'] ?? '').toString(),
      gymId: (json['gymId'] ?? '').toString(),
      ownerName: (json['ownerName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      plan: json['plan']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      membershipStatus: json['membershipStatus']?.toString(),
      membershipStartDate: json['membershipStartDate']?.toString(),
      membershipEndDate: json['membershipEndDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gymName': gymName,
    'gymId': gymId,
    'ownerName': ownerName,
    'email': email,
    if (phone != null) 'phone': phone,
    if (plan != null) 'plan': plan,
    if (paymentStatus != null) 'paymentStatus': paymentStatus,
    if (membershipStatus != null) 'membershipStatus': membershipStatus,
    if (membershipStartDate != null) 'membershipStartDate': membershipStartDate,
    if (membershipEndDate != null) 'membershipEndDate': membershipEndDate,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };

  @override
  String toString() =>
      'OwnerModel(id: $id, gymName: $gymName, gymId: $gymId, '
      'ownerName: $ownerName, email: $email, plan: $plan, '
      'membershipStatus: $membershipStatus)';
}

// ═══════════════════════════════════════════════════════════════════════════
// OWNER LOGIN REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/owner/login
// Body: { "gymId": "TEST201", "password": "password123" }
// ═══════════════════════════════════════════════════════════════════════════

class OwnerLoginRequest {
  final String gymId;
  final String password;

  const OwnerLoginRequest({required this.gymId, required this.password});

  Map<String, dynamic> toJson() => {'gymId': gymId, 'password': password};
}

// ═══════════════════════════════════════════════════════════════════════════
// OWNER LOGIN RESPONSE
// ═══════════════════════════════════════════════════════════════════════════
//
// Backend response (POST /api/owner/login → data):
// {
//   "token": "eyJhbGciOiJIUzI1NiIs...",
//   "owner": {
//     "id": "6aaece1c04339912ba696a3c",
//     "gymName": "Test Gym 2",
//     "gymId": "TEST201",
//     "ownerName": "Test Owner 2",
//     "email": "radhamadav31@gmail.com",
//     "plan": "STARTER",
//     "membershipStatus": "ACTIVE",
//     "membershipStartDate": "2026-09-19T18:02:53.940Z",
//     "membershipEndDate": "2026-10-19T18:02:53.940Z"
//   }
// }
// ═══════════════════════════════════════════════════════════════════════════

class OwnerLoginResponse {
  final String token;
  final OwnerModel owner;

  const OwnerLoginResponse({required this.token, required this.owner});

  factory OwnerLoginResponse.fromJson(Map<String, dynamic> json) {
    return OwnerLoginResponse(
      token: (json['token'] ?? '').toString(),
      owner: OwnerModel.fromJson(json['owner'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  String toString() =>
      'OwnerLoginResponse(token: ${token.length > 10 ? '${token.substring(0, 10)}...' : token}, owner: $owner)';
}

// ═══════════════════════════════════════════════════════════════════════════
// PURCHASE REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/owner/purchase
// Body: {
//   "gymName": "Astha Bhardwaj",
//   "gymId": "asthabhardwaj007",
//   "password": "password123",
//   "ownerName": "Astha",
//   "ownerEmail": "astha@gmail.com",
//   "ownerPhone": "9876543210",
//   "plan": "STARTER"
// }
// ═══════════════════════════════════════════════════════════════════════════
// In PurchaseRequest class
class PurchaseRequest {
  final String gymName;
  final String gymId;
  final String password;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final String plan;

  const PurchaseRequest({
    required this.gymName,
    required this.gymId,
    required this.password,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.plan,
  });

  Map<String, dynamic> toJson() => {
    'gymName': gymName,
    'gymId': gymId,
    'password': password,
    'ownerName': ownerName,
    'email': ownerEmail, // was 'ownerEmail'
    'phone': ownerPhone, // was 'ownerPhone'
    'plan': plan,
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// PURCHASE RESPONSE
// ═══════════════════════════════════════════════════════════════════════════
//
// Backend response (POST /api/owner/purchase → data):
// {
//   "ownerId": "6aaec8ffa362496443b2fc10",
//   "gymName": "Astha Bhardwaj",
//   "gymId": "asthabhardwaj007",
//   "plan": "STARTER",
//   "paymentStatus": "PENDING"
// }
// ═══════════════════════════════════════════════════════════════════════════

class PurchaseResponse {
  final String ownerId;
  final String gymName;
  final String gymId;
  final String plan;
  final String paymentStatus;

  const PurchaseResponse({
    required this.ownerId,
    required this.gymName,
    required this.gymId,
    required this.plan,
    required this.paymentStatus,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      ownerId: (json['ownerId'] ?? '').toString(),
      gymName: (json['gymName'] ?? '').toString(),
      gymId: (json['gymId'] ?? '').toString(),
      plan: (json['plan'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
    );
  }

  @override
  String toString() =>
      'PurchaseResponse(ownerId: $ownerId, gymId: $gymId, plan: $plan, '
      'paymentStatus: $paymentStatus)';
}

// ═══════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/owner/forgot-password
// Body: { "email": "radhamadav31@gmail.com" }
//
// Response: { "success": true, "message": "OTP sent successfully to your registered email" }
// (No "data" key — just success + message)
// ═══════════════════════════════════════════════════════════════════════════

class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// ═══════════════════════════════════════════════════════════════════════════
// VERIFY OTP REQUEST
// ═══════════════════════════════════════════════════════════════════════════
//
// POST /api/owner/verify-otp
// Body: { "email": "radhamadav31@gmail.com", "otp": "123456" }
//
// Response: { "success": true, "message": "OTP verified successfully" }
// (No "data" key — just success + message)
// ═══════════════════════════════════════════════════════════════════════════

class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}
// ─────────────────────────────────────────────────────────────────────
// ADD THIS CLASS TO YOUR owner_model.dart FILE
// ─────────────────────────────────────────────────────────────────────

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'newPassword': newPassword,
  };
}

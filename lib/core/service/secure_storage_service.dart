import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SecureStorageService._internal();

  // ============================================================
  // AUTH / USER KEYS
  // ============================================================

  static const String _keyToken = 'auth_token';
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyAppToken = 'app_token';

  // ============================================================
  // GYMO ROLE KEYS
  // Owner / Trainer / Client
  // ============================================================

  static const String _keyGymRole = 'gym_role';

  // ============================================================
  // PROFILE KEYS
  // ============================================================

  static const String _keyMobile = 'mobile';
  static const String _keyAlterMobile = 'alter_mobile';
  static const String _keyGender = 'gender';
  static const String _keyAddress = 'address';
  static const String _keyProfileImage = 'profile_image';
  static const String _keyDob = 'profile_dob';
  static const String _keyDepartment = 'profile_department';

  // ============================================================
  // ACCOUNT STATUS KEYS
  // ============================================================

  static const String _keyNdaSubmitted = 'nda_submitted';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  // ============================================================
  // SAVE USER DATA
  // ============================================================

  Future<void> saveUserData({
    required String token,
    required String employeeId,
    required String username,
    required String email,
    required String role,
    bool ndaSubmitted = false,
    bool onboardingCompleted = false,
  }) async {
    await _secureStorage.write(key: _keyToken, value: token);

    await _secureStorage.write(key: _keyEmployeeId, value: employeeId);

    await _secureStorage.write(key: _keyUsername, value: username);

    await _secureStorage.write(key: _keyEmail, value: email);

    await _secureStorage.write(key: _keyRole, value: role);

    // GYMO role
    await _secureStorage.write(key: _keyGymRole, value: role.toLowerCase());

    await _secureStorage.write(
      key: _keyNdaSubmitted,
      value: ndaSubmitted.toString(),
    );

    await _secureStorage.write(
      key: _keyOnboardingCompleted,
      value: onboardingCompleted.toString(),
    );
  }

  // ============================================================
  // GET USER DATA
  // ============================================================

  Future<Map<String, dynamic>?> getUserData() async {
    final token = await _secureStorage.read(key: _keyToken);

    if (token == null) {
      return null;
    }

    final role = await _secureStorage.read(key: _keyRole);

    return {
      'token': token,
      'employeeId': await _secureStorage.read(key: _keyEmployeeId),
      'username': await _secureStorage.read(key: _keyUsername),
      'email': await _secureStorage.read(key: _keyEmail),
      'role': role,
      'gymRole': role?.toLowerCase(),
      'ndaSubmitted':
          (await _secureStorage.read(key: _keyNdaSubmitted)) == 'true',
      'onboardingCompleted':
          (await _secureStorage.read(key: _keyOnboardingCompleted)) == 'true',
    };
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String?> getToken() async {
    return _secureStorage.read(key: _keyToken);
  }

  // ============================================================
  // USER / EMPLOYEE
  // ============================================================

  Future<String?> getEmployeeId() async {
    return _secureStorage.read(key: _keyEmployeeId);
  }

  Future<String?> getUserName() async {
    return _secureStorage.read(key: _keyUsername);
  }

  Future<String?> getEmail() async {
    return _secureStorage.read(key: _keyEmail);
  }

  // ============================================================
  // GYMO ROLE
  // ============================================================

  Future<String?> getRole() async {
    return _secureStorage.read(key: _keyRole);
  }

  Future<String?> getGymRole() async {
    final role = await _secureStorage.read(key: _keyGymRole);

    return role?.toLowerCase();
  }

  // ============================================================
  // ROLE CHECKS
  // ============================================================

  Future<bool> isOwner() async {
    final role = await getGymRole();
    return role == 'owner';
  }

  Future<bool> isTrainer() async {
    final role = await getGymRole();
    return role == 'trainer';
  }

  Future<bool> isClient() async {
    final role = await getGymRole();
    return role == 'client';
  }

  // ============================================================
  // UPDATE ROLE
  // ============================================================

  Future<void> setGymRole(String role) async {
    final normalizedRole = role.trim().toLowerCase();

    await _secureStorage.write(key: _keyRole, value: normalizedRole);

    await _secureStorage.write(key: _keyGymRole, value: normalizedRole);
  }

  // ============================================================
  // FCM / APP TOKEN
  // ============================================================

  Future<void> saveAppToken(String token) async {
    await _secureStorage.write(key: _keyAppToken, value: token);
  }

  Future<String?> getAppToken() async {
    return _secureStorage.read(key: _keyAppToken);
  }

  Future<void> deleteAppToken() async {
    await _secureStorage.delete(key: _keyAppToken);
  }

  // ============================================================
  // PROFILE DATA
  // ============================================================

  Future<void> saveProfileData({
    required String mobile,
    required String alterMobile,
    required String gender,
    required String address,
    String? profileImage,
    String? dob,
    String? department,
  }) async {
    await _secureStorage.write(key: _keyMobile, value: mobile);

    await _secureStorage.write(key: _keyAlterMobile, value: alterMobile);

    await _secureStorage.write(key: _keyGender, value: gender);

    await _secureStorage.write(key: _keyAddress, value: address);

    if (profileImage != null) {
      await _secureStorage.write(key: _keyProfileImage, value: profileImage);
    }

    await _secureStorage.write(key: _keyDob, value: dob ?? '');

    await _secureStorage.write(key: _keyDepartment, value: department ?? '');
  }

  // ============================================================
  // GET PROFILE DATA
  // ============================================================

  Future<Map<String, String?>?> getProfileData() async {
    final mobile = await _secureStorage.read(key: _keyMobile);

    if (mobile == null) {
      return null;
    }

    return {
      'mobile': mobile,
      'alterMobile': await _secureStorage.read(key: _keyAlterMobile),
      'gender': await _secureStorage.read(key: _keyGender),
      'address': await _secureStorage.read(key: _keyAddress),
      'profileImage': await _secureStorage.read(key: _keyProfileImage),
      'dob': await _secureStorage.read(key: _keyDob),
      'department': await _secureStorage.read(key: _keyDepartment),
    };
  }

  // ============================================================
  // INDIVIDUAL PROFILE FIELDS
  // ============================================================

  Future<String?> getMobile() async {
    return _secureStorage.read(key: _keyMobile);
  }

  Future<String?> getAlterMobile() async {
    return _secureStorage.read(key: _keyAlterMobile);
  }

  Future<String?> getGender() async {
    return _secureStorage.read(key: _keyGender);
  }

  Future<String?> getAddress() async {
    return _secureStorage.read(key: _keyAddress);
  }

  Future<String?> getProfileImage() async {
    return _secureStorage.read(key: _keyProfileImage);
  }

  Future<String?> getDob() async {
    return _secureStorage.read(key: _keyDob);
  }

  Future<String?> getDepartment() async {
    return _secureStorage.read(key: _keyDepartment);
  }

  // ============================================================
  // CLEAR PROFILE DATA
  // ============================================================

  Future<void> clearProfileData() async {
    await _secureStorage.delete(key: _keyMobile);

    await _secureStorage.delete(key: _keyAlterMobile);

    await _secureStorage.delete(key: _keyGender);

    await _secureStorage.delete(key: _keyAddress);

    await _secureStorage.delete(key: _keyProfileImage);

    await _secureStorage.delete(key: _keyDob);

    await _secureStorage.delete(key: _keyDepartment);
  }

  // ============================================================
  // NDA STATUS
  // ============================================================

  Future<void> setNdaSubmitted(bool submitted) async {
    await _secureStorage.write(
      key: _keyNdaSubmitted,
      value: submitted.toString(),
    );
  }

  Future<bool> isNdaSubmitted() async {
    final value = await _secureStorage.read(key: _keyNdaSubmitted);

    return value == 'true';
  }

  // ============================================================
  // ONBOARDING STATUS
  // ============================================================

  Future<void> setOnboardingCompleted(bool completed) async {
    await _secureStorage.write(
      key: _keyOnboardingCompleted,
      value: completed.toString(),
    );
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _secureStorage.read(key: _keyOnboardingCompleted);

    return value == 'true';
  }

  // ============================================================
  // LOGOUT / CLEAR ALL DATA
  // ============================================================

  Future<void> clearUserData() async {
    await _secureStorage.deleteAll();
  }
}

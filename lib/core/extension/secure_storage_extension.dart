import 'package:flutter/material.dart';
import 'package:karan_fitness/core/service/secure_storage_service.dart';

extension SecureStorageExtensions on BuildContext {
  SecureStorageService get _storage => SecureStorageService();

  Future<String?> getCurrentEmployeeId() async {
    final userData = await _storage.getUserData();
    return userData?['employeeId']?.toString();
  }

  Future<String?> getCurrentUsername() async {
    final userData = await _storage.getUserData();
    return userData?['username']?.toString();
  }

  Future<String?> getCurrentUserEmail() async {
    final userData = await _storage.getUserData();
    return userData?['email']?.toString();
  }

  Future<String?> getCurrentUserRole() async {
    final userData = await _storage.getUserData();
    return userData?['role']?.toString().toLowerCase();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return _storage.getUserData();
  }

  Future<bool> isOwner() async {
    return await getCurrentUserRole() == 'owner';
  }

  Future<bool> isTrainer() async {
    return await getCurrentUserRole() == 'trainer';
  }

  Future<bool> isClient() async {
    return await getCurrentUserRole() == 'client';
  }
}

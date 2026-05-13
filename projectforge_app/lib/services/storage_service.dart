import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../config/app_constants.dart';

class StorageService extends GetxService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConstants.userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.userDataKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = DioClient.createDio();
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.auth}/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final accessToken = data['accessToken'] ?? data['token'];
      final refreshToken = data['refreshToken'];

      if (accessToken != null) {
        await _storage.write(key: 'access_token', value: accessToken.toString());
        if (refreshToken != null) {
          await _storage.write(key: 'refresh_token', value: refreshToken.toString());
        }
        return true;
      }
      return false;
    } catch (e) {
      print('🔴 GİRİŞ HATASI: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      await _dio.post(
        '${ApiConstants.auth}/register',
        data: {'fullName': fullName, 'email': email, 'password': password},
      );
      return true;
    } catch (e) {
      print('🔴 KAYIT HATASI: $e');
      return false;
    }
  }
}
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

      final token = response.data['data']['token'];
      await _storage.write(key: 'access_token', value: token);
      return true;
    } catch (e) {
      return false; 
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      await _dio.post(
        '${ApiConstants.auth}/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
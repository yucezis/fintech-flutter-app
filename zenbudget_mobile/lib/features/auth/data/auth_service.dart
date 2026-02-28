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

      print('DEBUG: Backendden gelen cevap: ${response.data}');

      final token = (response.data['data'] != null) 
          ? response.data['data']['token'] 
          : response.data['token'];

      if (token != null) {
        await _storage.write(key: 'access_token', value: token.toString());
        return true;
      } else {
        print('🔴 HATA: Cevap geldi ama içerisinde "token" bulunamadı!');
        return false;
      }
    } catch (e) {
      print('🔴 GİRİŞ HATASI DETAYI: $e'); 
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
      print('🔴 KAYIT HATASI DETAYI: $e');
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
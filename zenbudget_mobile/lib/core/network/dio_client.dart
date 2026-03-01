import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');

    print('🟡 İSTEK GİDİYOR: ${options.path}');
    print('🟡 EKLENEN TOKEN: $token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRefreshRequest = err.requestOptions.path.contains('/auth/refresh');

    if (err.response?.statusCode == 401 && !_isRefreshing && !isRefreshRequest) {
      _isRefreshing = true;
      print('🔴 401 HATASI - Token yenileniyor...');

      try {
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken == null) {
          print('🔴 Refresh token yok, oturum kapatılıyor.');
          await _storage.deleteAll();
          return handler.next(err);
        }

        final response = await _dio.post(
          '${ApiConstants.auth}/refresh',
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
        print('✅ Token yenilendi, istek tekrarlanıyor.');

        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);

      } catch (e) {
        print('🔴 Token yenileme başarısız: $e');
        await _storage.deleteAll();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
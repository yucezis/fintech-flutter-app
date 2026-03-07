import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthUtils {
  static final _storage = const FlutterSecureStorage();

  static Future<String?> getUserId() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = json.decode(decoded) as Map<String, dynamic>;

    return map['sub'] ??
           map['userId'] ??
           map['nameid'] ??
           map['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
  }
}
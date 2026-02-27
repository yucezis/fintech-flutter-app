 import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';



// Tüm uygulamadan AuthService'e tek bir noktadan erişmemizi sağlar

final authServiceProvider = Provider<AuthService>((ref) {

  return AuthService();

});
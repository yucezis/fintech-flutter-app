import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    
    redirect: (context, state) async {
      final authService = ref.read(authServiceProvider);
      
      final isLoggedIn = await authService.isLoggedIn();
    
      final isOnAuth = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register';

      if (!isLoggedIn && !isOnAuth) {
        return '/login';
      }
      if (isLoggedIn && isOnAuth) {
        return '/dashboard';
      }

      return null;
    },
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
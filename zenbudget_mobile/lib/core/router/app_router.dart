import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenbudget_mobile/features/profile/prensentation/profile_screen.dart' show ProfileScreen;

import '../../features/ai_chat/prensentation/aichat_screen.dart';
import '../../features/assets/prensentation/assets_screen.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transaction_screen.dart';
import '../layout/main_layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    
    redirect: (context, state) async {
      final authService = ref.read(authServiceProvider);
      final isLoggedIn = await authService.isLoggedIn();
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && isOnAuth) return '/dashboard';
      return null;
    },
    
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/transactions', builder: (context, state) => const TransactionScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/aichat', builder: (context, state) => const AichatScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/assets', builder: (context, state) => const AssetsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});
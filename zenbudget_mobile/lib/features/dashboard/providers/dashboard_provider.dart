import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_service.dart';

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  return await DashboardService().getSummary();
});
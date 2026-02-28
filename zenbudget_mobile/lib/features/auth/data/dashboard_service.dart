import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<dynamic> recentTransactions;

  DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.recentTransactions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: json['recentTransactions'] ?? [],
    );
  }
}

class DashboardService {
  final Dio _dio = DioClient.createDio();

  Future<DashboardSummary> getSummary() async {
    final response = await _dio.get(ApiConstants.dashboard);
    return DashboardSummary.fromJson(response.data['data'] ?? response.data);
  }
}
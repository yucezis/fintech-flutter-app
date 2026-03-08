import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import 'transaction_model.dart';

class TransactionService {
  final Dio _dio = DioClient.createDio();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/transactions');
      print('DEBUG - İstek URL: ${ApiConstants.baseUrl}/transactions');
      
      print('DEBUG - Backendden Gelen Veri Tipi: ${response.data.runtimeType}');
      print('DEBUG - Backendden Gelen Veri: ${response.data}');

      List<dynamic> dataList = [];

      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map) {
        final mapData = response.data as Map<String, dynamic>;
        
        if (mapData.containsKey('data') && mapData['data'] is List) {
  dataList = mapData['data'];
} else if (mapData.containsKey('data') && mapData['data'] is Map) {
  // data bir obje, içinde items veya $values olabilir
  final dataObj = mapData['data'] as Map<String, dynamic>;
  if (dataObj.containsKey('items') && dataObj['items'] is List) {
    dataList = dataObj['items'];
  } else if (dataObj.containsKey('\$values') && dataObj['\$values'] is List) {
    dataList = dataObj['\$values'];
  } else if (dataObj.containsKey('transactions') && dataObj['transactions'] is List) {
    dataList = dataObj['transactions'];
  } else {
    // data'nın tam içeriğini görelim
    print('🔴 data objesi içeriği: ${dataObj.keys}');
    return [];
  }
}
      }

      return dataList.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      print('🔴 İŞLEMLER ÇEKİLİRKEN HATA DETAYI: $e');
      throw Exception('İşlemler yüklenemedi');
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/transactions',
        data: transaction.toJson(),
      );
      return true;
    } catch (e) {
      print('🔴 İŞLEM EKLENİRKEN HATA: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}/transactions/$id');
      return true;
    } catch (e) {
      print('🔴 İŞLEM SİLİNİRKEN HATA: $e');
      return false;
    }
  }
}
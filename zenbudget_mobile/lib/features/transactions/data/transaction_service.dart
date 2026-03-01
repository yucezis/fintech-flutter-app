import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import 'transaction_model.dart';

class TransactionService {
  final Dio _dio = DioClient.createDio();

  // Tüm işlemleri getir
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/v1/transactions');
      
      // Ajanlarımızı yerleştiriyoruz ki backend'in tam olarak ne döndüğünü görelim
      print('DEBUG - Backendden Gelen Veri Tipi: ${response.data.runtimeType}');
      print('DEBUG - Backendden Gelen Veri: ${response.data}');

      List<dynamic> dataList = [];

      // 1. Senaryo: Backend direkt liste dönüyorsa -> [ {...}, {...} ]
      if (response.data is List) {
        dataList = response.data;
      } 
      // 2. Senaryo: Backend objenin içinde sarılı dönüyorsa -> { "data": [...] } veya { "items": [...] }
      else if (response.data is Map) {
        final mapData = response.data as Map<String, dynamic>;
        
        if (mapData.containsKey('data') && mapData['data'] is List) {
          dataList = mapData['data'];
        } else if (mapData.containsKey('items') && mapData['items'] is List) {
          dataList = mapData['items'];
        } else if (mapData.containsKey('\$values') && mapData['\$values'] is List) {
          dataList = mapData['\$values'];
        } else {
          print('🔴 HATA: Obje geldi ama içinde liste bulunamadı! Anahtarlar: ${mapData.keys}');
          return []; // Çökmeyi engellemek için boş liste dön
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
        '${ApiConstants.baseUrl}/api/v1/transactions',
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
      await _dio.delete('${ApiConstants.baseUrl}/api/v1/transactions/$id');
      return true;
    } catch (e) {
      print('🔴 İŞLEM SİLİNİRKEN HATA: $e');
      return false;
    }
  }
}
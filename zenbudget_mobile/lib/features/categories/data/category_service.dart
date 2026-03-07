import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import 'category_model.dart';

class CategoryService {
  final Dio _dio = DioClient.createDio();

  Future<List<CategoryModel>> getCategories({String? type}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/v1/categories',
        queryParameters: type != null ? {'type': type} : null,
      );

      List<dynamic> dataList = [];
      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        if (map.containsKey('data') && map['data'] is List) {
          dataList = map['data'];
        }
      }

      return dataList.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      print('🔴 KATEGORİLER ÇEKİLİRKEN HATA: $e');
      return [];
    }
  }
}
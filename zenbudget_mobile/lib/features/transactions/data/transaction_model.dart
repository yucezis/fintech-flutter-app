class TransactionModel {
  final String? id; 
  final double amount;
  final String type; 
  final String categoryId; 
  final String? categoryName; 
  final String description; 
  final DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.description = '',
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    
    String? extractedCategoryName;
    if (json['category'] != null && json['category'] is Map) {
      extractedCategoryName = json['category']['name']; 
    } else {
      extractedCategoryName = json['categoryName']; 
    }

    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'].toString(), 
      categoryId: json['categoryId'],
      categoryName: extractedCategoryName,
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'type': type, 
      'categoryId': categoryId,
      'description': description,
      'date': date.toUtc().toIso8601String(), 
    };
  }
}
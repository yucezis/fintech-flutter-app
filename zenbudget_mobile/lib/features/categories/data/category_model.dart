class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isSystem;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isSystem,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#4F8EF7',
      type: json['type'].toString(),
      isSystem: json['isSystem'] ?? false,
    );
  }
}
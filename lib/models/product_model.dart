class ProductModel {
  final String id;
  final String brand;
  final String category;
  final String categoryId;
  final String imageUrl;
  final String name;
  final double price;
  final double rating;

  ProductModel({
    required this.id,
    required this.brand,
    required this.category,
    required this.categoryId,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.rating,
  });
  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      brand: data['brand'] ?? '',
      category: data['category'] ?? '',
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}

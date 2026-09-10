import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<ProductModel>> searchProducts(
    String searchText,
  ) async {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    // Get all products
    final snapshot =
        await _firestore
            .collection('products')
            .get();

    // Convert Firestore documents to ProductModel
    final products = snapshot.docs.map((doc) {
      return ProductModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();

    // Search by name OR brand
    final results = products.where((product) {

      final productName =
          product.name.toLowerCase();

      final productBrand =
          product.brand.toLowerCase();

      return productName.contains(query) ||
          productBrand.contains(query);

    }).toList();

    return results;
  }
}
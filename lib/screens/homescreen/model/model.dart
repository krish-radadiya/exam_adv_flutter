import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final int? id;
  final String name;
  final double price;
  final String category;
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isFavorite = false,
  });

  // Convert a Product into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  // Extract a Product object from a Map.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Extract a Product object from a Firestore DocumentSnapshot.
  factory Product.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id as int?,
      name: data['name'] ?? '',
      price: (data['price'] as num).toDouble() ?? 0.0,
      category: data['category'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}

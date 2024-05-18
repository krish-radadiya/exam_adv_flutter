import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  int? id;
  String name;
  double price;
  String category;
  bool isFavorite;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'],
    );
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      id: doc.id as int,
      name: doc['name'],
      price: doc['price'],
      category: doc['category'],
      isFavorite: doc['isFavorite'] ?? false,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/homescreen/model/model.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Future<List<Product>> getAllProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
  }

  Future<void> updateFavoriteStatus(String productId, bool isFavorite) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isFavorite': isFavorite,
      });
    } catch (e) {
      print('Error updating favorite status: $e');
      throw e;
    }
  }

  // Get favorite products for a specific user
  Future<List<Product>> getFavoriteProducts(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    List<String> favoriteProductIds =
        snapshot.docs.map((doc) => doc.id).toList();
    List<Product> favoriteProducts = [];
    for (String productId in favoriteProductIds) {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productId).get();
      if (productSnapshot.exists) {
        favoriteProducts.add(Product.fromDocument(productSnapshot));
      }
    }
    return favoriteProducts;
  }
}

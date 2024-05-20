import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/homescreen/model/model.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getAllProducts() async {
    QuerySnapshot snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id as String?)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Future<void> addFavoriteProduct(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set({});
  }

  Future<void> removeFavoriteProduct(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

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

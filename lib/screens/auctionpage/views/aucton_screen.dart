import 'package:flutter/material.dart';
import '../../../utils/firestore_helper.dart';
import '../../homescreen/model/model.dart';

class FavoriteScreen extends StatefulWidget {
  final String userId;

  FavoriteScreen({required this.userId});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Products'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: firestoreHelper.getFavoriteProducts(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Product> products = snapshot.data ?? [];
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: ${product.price}'),
                  trailing: IconButton(
                    icon: Icon(product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      _toggleFavoriteStatus(
                          product.id.toString(), !product.isFavorite);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _toggleFavoriteStatus(String productId, bool isFavorite) async {
    try {
      await firestoreHelper.updateFavoriteStatus(productId, isFavorite);
    } catch (e) {
      // Handle error, if any
      print('Error toggling favorite status: $e');
    }
  }
}

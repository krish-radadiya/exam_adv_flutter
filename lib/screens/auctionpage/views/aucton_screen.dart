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
      body: FutureBuilder<List<Product>>(
        future: firestoreHelper.getFavoriteProducts(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite products found.'));
          } else {
            List<Product> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: ${product.price}'),
                  trailing: IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
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
      if (isFavorite) {
        await firestoreHelper.addFavoriteProduct(widget.userId, productId);
      } else {
        await firestoreHelper.removeFavoriteProduct(widget.userId, productId);
      }
      setState(() {});
    } catch (e) {
      print('Error toggling favorite status: $e');
    }
  }
}

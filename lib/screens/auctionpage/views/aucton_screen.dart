import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../homescreen/controller/home_controller.dart';

class FavoriteScreen extends StatelessWidget {
  final String userId;
  final HomeController homeController = Get.find();

  FavoriteScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Products'),
      ),
      body: Obx(() {
        if (homeController.favorites.isEmpty) {
          return const Center(child: Text('No favorite products found.'));
        } else {
          return ListView.builder(
            itemCount: homeController.favorites.length,
            itemBuilder: (context, index) {
              final product = homeController.favorites[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Price: ${product.price}'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    homeController.removeFromFavorites(product);
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }
}

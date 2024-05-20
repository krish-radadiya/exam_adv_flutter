import 'package:get/get.dart';
import '../../../utils/firestore_helper.dart';
import '../model/model.dart';

class HomeController extends GetxController {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  var products = <Product>[].obs;
  var favorites = <Product>[].obs;
  final String userId;

  HomeController(this.userId);

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchFavoriteProducts();
  }

  void fetchProducts() async {
    var productList = await firestoreHelper.getAllProducts();
    products.assignAll(productList);
  }

  void addProduct(Product product) async {
    await firestoreHelper.addProduct(product);
    fetchProducts();
  }

  void updateProduct(Product product) async {
    await firestoreHelper.updateProduct(product);
    fetchProducts();
  }

  void deleteProduct(String id) async {
    await firestoreHelper.deleteProduct(id);
    fetchProducts();
  }

  void addToFavorites(Product product) async {
    await firestoreHelper.addFavoriteProduct(userId, product.id! as String);
    fetchFavoriteProducts();
  }

  void removeFromFavorites(Product product) async {
    await firestoreHelper.removeFavoriteProduct(userId, product.id! as String);
    fetchFavoriteProducts();
  }

  void fetchFavoriteProducts() async {
    var favoriteList = await firestoreHelper.getFavoriteProducts(userId);
    favorites.assignAll(favoriteList);
  }
}

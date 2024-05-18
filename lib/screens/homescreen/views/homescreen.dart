import 'package:flutter/material.dart';
import '../../../utils/db_helper.dart';
import '../../../utils/firestore_helper.dart';
import '../../auctionpage/views/aucton_screen.dart';
import '../model/model.dart';

class Homescreen extends StatefulWidget {
  final String userId;

  Homescreen({required this.userId});

  @override
  _HomescreenState createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  List<Product>? _products;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    var products = await DBHelper().fetchProducts();
    setState(() {
      _products = products;
    });
  }

  void _showAlertDialog(BuildContext context, {Product? product}) {
    if (product != null) {
      _productNameController.text = product.name;
      _productPriceController.text = product.price.toString();
      _productCategoryController.text = product.category;
    } else {
      _productNameController.clear();
      _productPriceController.clear();
      _productCategoryController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Update Product'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                  ),
                ),
                TextField(
                  controller: _productPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Product Price',
                  ),
                ),
                TextField(
                  controller: _productCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Product Category',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _productNameController.clear();
                _productPriceController.clear();
                _productCategoryController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                String productName = _productNameController.text;
                double productPrice =
                    double.tryParse(_productPriceController.text) ?? 0.0;
                String productCategory = _productCategoryController.text;

                if (productName.isEmpty ||
                    productCategory.isEmpty ||
                    productPrice <= 0) {
                  // Show an error message if the input is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please fill all fields with valid values')),
                  );
                  return;
                }

                if (product == null) {
                  // Insert the product into the database
                  await DBHelper().insertProduct(Product(
                    name: productName,
                    price: productPrice,
                    category: productCategory,
                  ));
                } else {
                  // Update the product in the database
                  await DBHelper().updateProduct(Product(
                    id: product.id,
                    name: productName,
                    price: productPrice,
                    category: productCategory,
                  ));
                }

                _productNameController.clear();
                _productPriceController.clear();
                _productCategoryController.clear();

                _fetchProducts();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(int id) async {
    await DBHelper().deleteProduct(id);
    _fetchProducts();
  }

  void _addToFavorites(Product product) async {
    await FirestoreHelper()
        .addFavoriteProduct(widget.userId, product.id.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FavoriteScreen(userId: widget.userId)),
              );
            },
          ),
        ],
      ),
      body: _products == null
          ? const Center(child: CircularProgressIndicator())
          : _products!.isEmpty
              ? const Center(child: Text('NO DATA FOUND...'))
              : ListView.builder(
                  itemCount: _products!.length,
                  itemBuilder: (context, index) {
                    final product = _products![index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Category: ${product.category}, Price: ${product.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showAlertDialog(context, product: product),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                              ),
                              onPressed: () => _addToFavorites(product),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () => _deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlertDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}

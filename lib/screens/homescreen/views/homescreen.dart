import 'package:flutter/material.dart';
import '../../../utils/db_helper.dart';
import '../../../utils/firestore_helper.dart';
import '../../auctionpage/views/aucton_screen.dart';
import '../model/model.dart';

class Homescreen extends StatefulWidget {
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

                // Clear the text fields
                _productNameController.clear();
                _productPriceController.clear();
                _productCategoryController.clear();

                // Fetch and update the products list
                _fetchProducts();

                // Close the dialog
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
    await FirestoreHelper().updateFavoriteStatus(product.id.toString(), true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteScreen()),
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
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Category: ${product.category}, Price: ${product.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _showAlertDialog(context, product: product),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () => _addToFavorites(product),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAlertDialog(context),
          tooltip: 'Add Product',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

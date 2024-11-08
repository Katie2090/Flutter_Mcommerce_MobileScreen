import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'cart_manager.dart';
import 'FavoritesManager.dart';
import 'cart.dart';
import 'FavoritesScreen.dart';
import 'detail.dart';
import 'package:badges/badges.dart' as badges_pkg;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Future<List>? _myFuture;
  List products = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _myFuture = _getProducts();
  }

  Future<List> _getProducts() async {
    var url = Uri.parse("http://192.168.111.33:5050/products");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      products = jsonDecode(response.body);
      return products;
    } else {
      throw Exception("Failed to load products");
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) =>
        product['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _showCreateProductForm() {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final description = detailController.text;
              final priceText = priceController.text;
              final price = double.tryParse(priceText) ?? 0.0;

              if (title.isEmpty || price == 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a valid title and price")),
                );
                return;
              }

              final productData = {
                'title': title,
                'description': description,
                'price': price,
                'image': 'https://picsum.photos/200/300',
              };

              _addProduct(productData);
              Navigator.of(ctx).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductForm(Map<String, dynamic> product) {
    final titleController = TextEditingController(text: product['title']);
    final detailController = TextEditingController(text: product['description']);
    final priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = {
                'id': product['id'],
                'title': titleController.text,
                'description': detailController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'image': product['image'],
              };

              _editProduct(updatedProduct);
              Navigator.of(ctx).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(Map productData) async {
    var url = Uri.parse("http://192.168.111.33:5050/products");
    var response = await http.post(url, body: jsonEncode(productData), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 201) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to add product");
    }
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    var url = Uri.parse("http://192.168.111.33:5050/products/${product['id']}");
    var response = await http.put(url, body: jsonEncode(product), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to update product");
    }
  }

  Future<void> _deleteProduct(int productId) async {
    var url = Uri.parse("http://192.168.111.33:5050/products/$productId");
    var response = await http.delete(url);
    if (response.statusCode == 200) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to delete product");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Products",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Consumer<CartManager>(
            builder: (_, cartManager, __) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: badges_pkg.Badge(
                badgeContent: Text(
                  "${cartManager.cartItems.length}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: Icon(Icons.shopping_cart, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<FavoritesManager>(
            builder: (_, favoritesManager, __) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
              child: badges_pkg.Badge(
                badgeContent: Text(
                  "${favoritesManager.favoriteCount}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: Icon(Icons.favorite, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProductForm,
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List>(
        future: _myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading products"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No products found"));
          }

          var displayedProducts = filteredProducts;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText: "Search product",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: displayedProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      var product = displayedProducts[index] as Map<String, dynamic>;
                      var imageUrl = product['image'] ?? '';
                      var title = product['title'] ?? 'No Title';
                      var price = product['price'] ?? 0.0;
                      var description = product['description'] ?? 'No Description';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                data: product['id'],
                                imageUrl: imageUrl,
                                description: description,
                              ),
                            ),
                          );
                        },
                        child: Consumer<FavoritesManager>(
                          builder: (context, favoritesManager, _) {
                            bool isFavorite = favoritesManager.isFavorite(product['id']);
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15.0),
                                            topRight: Radius.circular(15.0),
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 130,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: double.infinity,
                                                height: 130,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? Colors.red : Colors.white,
                                            ),
                                            onPressed: () {
                                              favoritesManager.toggleFavorite(product);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${price.toString()}",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<CartManager>(context, listen: false).addItem({
                                              'id': product['id'],
                                              'title': title,
                                              'description': description,
                                              'price': price,
                                              'image': imageUrl,
                                            });
                                          },
                                          icon: Icon(
                                            Icons.add_shopping_cart,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _showEditProductForm(product);
                                          },
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _deleteProduct(product['id']);
                                          },
                                          icon: Icon(Icons.delete, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

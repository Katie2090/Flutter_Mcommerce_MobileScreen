import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cart_manager.dart';
import 'cart.dart';

class DetailScreen extends StatefulWidget {
  final int data;
  final String imageUrl;
  final String description; // New parameter for description

  DetailScreen({required this.data, required this.imageUrl, required this.description}); // Updated constructor

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int quantity = 1;

  Future<Map<String, dynamic>> _getProductDetail() async {
    var url = Uri.parse("http://192.168.111.33:5050/products/${widget.data}");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load product details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text('Back', style: TextStyle(color: Colors.black)),
        actions: [
          Consumer<CartManager>(
            builder: (context, cartManager, child) => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                ),
                if (cartManager.totalItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartManager.totalItemCount}',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getProductDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Product details are unavailable.'));
          } else {
            final product = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Image.network(
                            widget.imageUrl.isNotEmpty
                                ? widget.imageUrl
                                : 'https://via.placeholder.com/150',
                            height: 250,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 100);
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          product['title'] ?? 'No Title',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "${product['price'] ?? '0.00'} \$",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.description, // Display main description here
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Divider(thickness: 1, color: Colors.grey[400]),

                        // Additional description section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Product Details",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "This product is perfect for anyone looking for quality and affordability. It offers exceptional value with top-notch ingredients and a versatile formula suited for all skin types.",
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "How to Use",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Apply a small amount to cleansed face in the morning and evening. Follow with your regular moisturizer.",
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[900]!, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product['price'] ?? '0.00'}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              icon: Icon(Icons.remove),
                              color: Colors.black,
                              iconSize: 18,
                            ),
                            Text(
                              quantity.toString().padLeft(2, '0'), // Adds leading zero
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: Icon(Icons.add),
                              color: Colors.black,
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<CartManager>(context, listen: false)
                              .addItem({
                            'id': product['id'] ?? 0,
                            'title': product['title'] ?? 'No Title',
                            'price': product['price'] ?? 0.00,
                            'quantity': quantity,
                            'image': widget.imageUrl,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

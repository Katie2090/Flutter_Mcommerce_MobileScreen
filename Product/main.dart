import 'package:fake_store/Product/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'FavoritesManager.dart';
import 'cart_manager.dart';
import 'detail.dart';
import 'product_list.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartManager()),
        ChangeNotifierProvider(create: (_) => FavoritesManager()),
      ],
      child: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final List<String> imagePaths = [
    'assets/images/pic/1.jpg',
    'assets/images/pic/2.jpg',
    'assets/images/pic/3.png',
    'assets/images/pic/4.jpg',
    'assets/images/pic/5.jpg',
    'assets/images/pic/6.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()), // Replace with your CartScreen widget
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Pinchai"),
              accountEmail: Text("meyching@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage("https://example.com/image.jpg"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.line_style, size: 50),
              title: const Text("Product List", style: TextStyle(fontSize: 18)),
              subtitle: const Text("Display all product items..."),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductList()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, size: 50),
              title: const Text("Profile", style: TextStyle(fontSize: 18)),
              subtitle: const Text("View or edit your profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(data: 1, imageUrl: '', description: '',)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_page, size: 50),
              title: const Text("Contact Us", style: TextStyle(fontSize: 18)),
              subtitle: const Text("Contact our team if there is an issue"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(data: 1, imageUrl: '', description: '',)));
              },
            ),
            const Spacer(),
            const Text("Version 1.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "OUR TOP ITEM'S",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton(context, "All", Colors.black),
                _buildCategoryButton(context, "Face", Colors.purple),
                _buildCategoryButton(context, "Body", Colors.green),
                _buildCategoryButton(context, "Hair", Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length, // Display 6 containers
                itemBuilder: (context, index) {
                  return _buildProductCard(context, imagePaths[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductList()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.point_of_sale, size: 40, color: Colors.green),
                      SizedBox(height: 4),
                      Text(
                        "POINT OF SALE",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductList()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.list_alt, size: 40, color: Colors.blue),
                      SizedBox(height: 4),
                      Text(
                        "Product List",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(150),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildProductCard(BuildContext context, String imagePath) {
    return Container(
      width: 300, // Adjust width as necessary
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(150),topLeft: Radius.circular(150))),
        color: Colors.purple[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(150)),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "THE ORDINARY",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "\$64",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

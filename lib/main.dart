import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'checkout.dart';

void main() {
  runApp(HealthyMarketApp());
}

class HealthyMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Market',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green[900], fontFamily: 'Arial'),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: ProductListPage(),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  String? nutrition;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.nutrition,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  List<Product> cart = [];
  String selectedCategory = '全部';
  final List<String> categories = ['全部', '肉類', '蔬菜', '冷凍食品', '乳製品 & 雞蛋'];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = (json.decode(response.body) as List).map((p) => Product.fromJson(p)).toList();
      });
    }
  }

  List<Product> getFilteredProducts() {
    if (selectedCategory == '全部') {
      return products;
    } else {
      return products.where((product) => product.category == selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              "Healthy Market",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "請輸入要搜索的商品",
                          prefixIcon: Icon(Icons.search, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.black54, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckoutPage(cart: cart)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    selectedColor: Colors.blue,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: getFilteredProducts().length,
              itemBuilder: (context, index) {
                final product = getFilteredProducts()[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 80),
                      ),
                    ),
                    title: Text(product.name, style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Text('${product.category} - \$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        setState(() => cart.add(product));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../main.dart';

class CheckoutPage extends StatelessWidget {
  final List<Product> cart;

  CheckoutPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cart[index].name),
                  subtitle: Text("\$${cart[index].price}"),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("返回"),
          ),
        ],
      ),
    );
  }
}
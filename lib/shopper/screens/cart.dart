import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_app/shopper/models/cart.dart';
import 'package:my_app/shopper/models/catalog.dart';

class ShopCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: Column(
        children: [
          Consumer<CartModel>(
            builder: (context, value, child) {
              return value.items.isEmpty
                  ? null
                  : ListView(
                      children: value.items
                          .map(
                            (Item item) => Container(
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                    );
            },
          ),
        ],
      ),
    );
  }
}

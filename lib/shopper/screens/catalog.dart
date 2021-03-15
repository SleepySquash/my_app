import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_app/shopper/models/catalog.dart';
import 'package:my_app/shopper/models/cart.dart';

class ShopCatalogBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.logout, color: Theme.of(context).buttonColor),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              }),
          Expanded(
            child: Center(
              child: Text(
                'Catalog',
                style: Theme.of(context).primaryTextTheme.headline6,
              ),
            ),
          ),
          IconButton(
              icon: Icon(Icons.shop, color: Theme.of(context).buttonColor),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              }),
        ],
      ),
    );
  }
}

class ShopCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          ShopCatalogBar(),
          Expanded(
            child: Consumer<CatalogModel>(
              builder: (context, value, child) {
                return ListView(
                  children: value.items.map((Item item) {
                    return _MyListItem(item);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyListItem extends StatelessWidget {
  final Item item;
  _MyListItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var inCart =
        context.select<CartModel, bool>((cart) => cart.items.contains(item.id));

    return Container(
      color: item.color,
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar()),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).primaryTextTheme.bodyText1,
            ),
          ),
          IconButton(
            icon: Icon(inCart ? Icons.remove : Icons.add),
            onPressed: () {
              var cart = context.read<CartModel>();
              inCart ? cart.remove(item) : cart.add(item);
            },
          ),
        ],
      ),
    );
  }
}

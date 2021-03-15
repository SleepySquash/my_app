import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_app/shopper/models/cart.dart';
import 'package:my_app/shopper/models/catalog.dart';

import 'package:my_app/shopper/screens/login.dart';
import 'package:my_app/shopper/screens/cart.dart';
import 'package:my_app/shopper/screens/catalog.dart';

class ShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => CatalogModel()),
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp(
        title: "Shop Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => ShopLogin(),
          '/catalog': (context) => ShopCatalog(),
          '/cart': (context) => ShopCart(),
        },
      ),
    );
  }
}

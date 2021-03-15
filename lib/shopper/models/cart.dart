import 'package:flutter/foundation.dart';
import 'package:my_app/shopper/models/catalog.dart';

class CartModel extends ChangeNotifier {
  CatalogModel? _catalog;
  final List<int> _itemIds = [];

  CatalogModel get catalog => _catalog!;
  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    notifyListeners();
  }

  List<Item> get items =>
      _itemIds.map((int id) => _catalog!.items[id]).toList();
  int get totalPrice =>
      items.fold(0, (previousValue, element) => previousValue + element.price);

  void add(Item item) {
    _itemIds.add(item.id);
    notifyListeners();
  }

  void remove(Item item) {
    _itemIds.remove(item.id);
    notifyListeners();
  }
}

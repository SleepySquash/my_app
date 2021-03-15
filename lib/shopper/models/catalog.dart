import 'package:flutter/material.dart';

class CatalogModel {
  List<Item> items = [
    Item(0, 'Code Smell'),
    Item(1, 'Control Flow'),
    Item(2, 'Interpreter'),
    Item(3, 'Recursion'),
    Item(4, 'Sprint'),
    Item(5, 'Heisenbug'),
    Item(6, 'Spaghetti'),
    Item(7, 'Hydra Code'),
    Item(8, 'Off-By-One'),
    Item(9, 'Scope'),
    Item(10, 'Callback'),
    Item(11, 'Closure'),
    Item(12, 'Automata'),
    Item(13, 'Bit Shift'),
    Item(14, 'Currying'),
  ];
}

@immutable
class Item {
  final int id;
  final String name;
  final Color color;
  final int price = 43;

  Item(this.id, this.name)
      : color = Colors.primaries[id % Colors.primaries.length];

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Item && other.id == id;
}

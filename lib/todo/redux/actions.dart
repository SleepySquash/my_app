import 'package:my_app/todo/model/model.dart';

class AddItemAction {
  final String item;
  AddItemAction(this.item);
}

class RemoveItemAction {
  final Item item;
  RemoveItemAction(this.item);
}

class RemoveItemsAction {}

class GetItemsAction {}

class LoadedItemsAction {
  final List<Item> items;
  LoadedItemsAction(this.items);
}

class ItemCompletedAction {
  final Item item;
  ItemCompletedAction(this.item);
}

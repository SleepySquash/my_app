import 'package:my_app/todo/model/model.dart';
import 'package:my_app/todo/redux/actions.dart';

import 'package:redux/redux.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    items: itemReducer(state.items, action),
  );
}

Reducer<List<Item>> itemReducer = combineReducers<List<Item>>([
  TypedReducer<List<Item>, AddItemAction>(addItemReducer),
  TypedReducer<List<Item>, RemoveItemAction>(removeItemReducer),
  TypedReducer<List<Item>, RemoveItemsAction>(removeItemsReducer),
  TypedReducer<List<Item>, LoadedItemsAction>(loadItemsReducer),
  TypedReducer<List<Item>, ItemCompletedAction>(itemCompletedReducer),
]);

List<Item> addItemReducer(List<Item> items, AddItemAction action) {
  AppState.id++;
  return []
    ..addAll(items)
    ..add(Item(id: AppState.id, body: action.item));
}

List<Item> removeItemReducer(List<Item> items, RemoveItemAction action) =>
    List.unmodifiable(List.from(items)..remove(action.item));

List<Item> removeItemsReducer(List<Item> items, RemoveItemsAction action) {
  AppState.id = 0;
  return [];
}

List<Item> loadItemsReducer(List<Item> items, LoadedItemsAction action) =>
    action.items;

List<Item> itemCompletedReducer(List<Item> items, ItemCompletedAction action) {
  return items
      .map((item) => item.id == action.item.id
          ? item.copyWith(completed: !item.completed)
          : item)
      .toList();
}

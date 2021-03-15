import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:my_app/todo/model/model.dart';
import 'package:my_app/todo/redux/actions.dart';
import 'package:my_app/todo/redux/reducers.dart';
import 'package:my_app/todo/redux/middleware.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Store<AppState> store = Store<AppState>(
      appStateReducer,
      initialState: AppState.initialState(),
      middleware: appStateMiddleware(),
    );

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: "TODO App",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(GetItemsAction()),
          builder: (BuildContext context, Store<AppState> store) =>
              TodoHomePage(store),
        ),
      ),
    );
  }
}

class TodoHomePage extends StatelessWidget {
  final Store<AppState> store;
  TodoHomePage(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TODO App')),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel viewModel) => Column(
          children: [
            AddItemWidget(viewModel),
            Expanded(child: ItemListWidget(viewModel)),
            RemoveItemsButton(viewModel),
          ],
        ),
      ),
    );
  }
}

class AddItemWidget extends StatefulWidget {
  final _ViewModel model;
  AddItemWidget(this.model);

  @override
  _AddItemWidget createState() => _AddItemWidget();
}

class _AddItemWidget extends State<AddItemWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Add an item',
      ),
      onSubmitted: (String s) {
        widget.model.onAddItem(s);
        controller.text = '';
      },
    );
  }
}

class ItemListWidget extends StatelessWidget {
  final _ViewModel model;
  ItemListWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: model.items
          .map((Item item) => ListTile(
                title: Text(item.body),
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => model.onRemoveItem(item),
                ),
                trailing: Checkbox(
                  value: item.completed,
                  onChanged: (b) {
                    model.onCompletedItem(item);
                  },
                ),
              ))
          .toList(),
    );
  }
}

class RemoveItemsButton extends StatelessWidget {
  final _ViewModel model;
  RemoveItemsButton(this.model);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Delete all items'),
      onPressed: () => model.onRemoveItems(),
    );
  }
}

class _ViewModel {
  final List<Item> items;
  final Function(Item) onCompletedItem;
  final Function(String) onAddItem;
  final Function(Item) onRemoveItem;
  final Function() onRemoveItems;

  _ViewModel({
    required this.items,
    required this.onCompletedItem,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onRemoveItems,
  });

  factory _ViewModel.create(Store<AppState> store) {
    _onAddItem(String body) {
      store.dispatch(AddItemAction(body));
    }

    _onRemoveItem(Item item) {
      store.dispatch(RemoveItemAction(item));
    }

    _onRemoveItems() {
      store.dispatch(RemoveItemsAction());
    }

    _onCompleted(Item item) {
      store.dispatch(ItemCompletedAction(item));
    }

    return _ViewModel(
      items: store.state.items,
      onCompletedItem: _onCompleted,
      onAddItem: _onAddItem,
      onRemoveItem: _onRemoveItem,
      onRemoveItems: _onRemoveItems,
    );
  }
}

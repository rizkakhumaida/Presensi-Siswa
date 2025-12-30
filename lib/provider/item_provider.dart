import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => _items;

  void addItem(String name, int qty) {
    _items.add(Item(
      id: DateTime.now().toString(),
      name: name,
      quantity: qty,
    ));
    notifyListeners();
  }

  void updateItem(String id, String name, int qty) {
    int index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = Item(id: id, name: name, quantity: qty);
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

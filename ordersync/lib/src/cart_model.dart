import 'package:flutter/material.dart';
import 'models.dart';

/// Shared, observable shopping cart for the customer portal. Kept deliberately
/// simple (no external state package) so the data flow stays easy to follow.
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.total);
  double get deliveryFee => _items.isEmpty ? 0 : 120;
  double get tax => subtotal * 0.05;
  double get total => subtotal + deliveryFee + tax;

  void add(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void replaceAt(int index, CartItem item) {
    _items[index] = item;
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void setQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
    } else {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// Makes the [CartModel] available to the whole customer subtree and rebuilds
/// dependents when it changes.
class CartScope extends InheritedNotifier<CartModel> {
  const CartScope({
    super.key,
    required CartModel cart,
    required super.child,
  }) : super(notifier: cart);

  static CartModel of(BuildContext context) {
    final CartScope? scope =
        context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found in context');
    return scope!.notifier!;
  }
}

import 'package:flutter/material.dart';

import '../../cart_model.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'checkout_screen.dart';
import 'dish_customizer.dart';

/// The customer cart. Edits push the full-screen customiser (data forward) and
/// apply the returned item (data backward) to instantly recalculate the bill.
class CartPage extends StatelessWidget {
  final VoidCallback onBrowseMenu;
  const CartPage({super.key, required this.onBrowseMenu});

  Future<void> _editItem(
      BuildContext context, CartModel cart, int index) async {
    final updated = await Navigator.push<CartItem>(
      context,
      MaterialPageRoute(
        builder: (_) => DishCustomizerScreen(item: cart.items[index]),
      ),
    );
    if (updated != null) {
      cart.replaceAt(index, updated); // returned data -> recalculation
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context); // rebuilds when the cart changes
    if (cart.isEmpty) {
      return _EmptyCart(onBrowseMenu: onBrowseMenu);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Dismissible(
                key: ValueKey('${item.dish.id}-$index'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => cart.removeAt(index),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: StatusColors.offline.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: StatusColors.offline),
                ),
                child: _CartRow(
                  item: item,
                  onEdit: () => _editItem(context, cart, index),
                  onQuantity: (q) => cart.setQuantity(index, q),
                ),
              );
            },
          ),
        ),
        _BillSummary(cart: cart),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onEdit;
  final ValueChanged<int> onQuantity;

  const _CartRow({
    required this.item,
    required this.onEdit,
    required this.onQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = [
      item.size,
      item.spiceLabel,
      ...item.selectedAddOns.map((a) => a.name),
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: DishImage(dish: item.dish, iconScale: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.dish.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(rs(item.total),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.brand)),
                      const Spacer(),
                      QuantityStepper(
                        quantity: item.quantity,
                        size: 30,
                        onChanged: onQuantity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillSummary extends StatelessWidget {
  final CartModel cart;
  const _BillSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          _line(context, 'Subtotal', rs(cart.subtotal)),
          _line(context, 'Delivery Fee', rs(cart.deliveryFee)),
          _line(context, 'Tax (5%)', rs(cart.tax)),
          const Divider(height: 20),
          _line(context, 'Total', rs(cart.total), bold: true),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CheckoutScreen(cart: cart)),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text('Checkout · ${rs(cart.total)}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value,
      {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: Theme.of(context)
          .colorScheme
          .onSurface
          .withValues(alpha: bold ? 1 : 0.75),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowseMenu;
  const _EmptyCart({required this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Add some delicious dishes to get started',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onBrowseMenu,
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
}

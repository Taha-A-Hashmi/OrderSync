import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// "My Orders" — a scrollable history of the customer's past and active orders.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static final List<_PastOrder> _orders = [
    _PastOrder('OS-1041', 'Chicken Karahi · Kashmiri Chai', 1670,
        OrderStatus.delivered, '2 days ago'),
    _PastOrder('OS-1039', 'Zinger Burger · Loaded Fries', 1100,
        OrderStatus.delivered, '5 days ago'),
    _PastOrder('OS-1031', 'Chicken Biryani ×2', 1440, OrderStatus.delivered,
        '1 week ago'),
    _PastOrder('OS-1024', 'Nihari · Extra Naan', 950, OrderStatus.delivered,
        '2 weeks ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 4, left: 2),
            child: SectionHeader('Recent Orders'),
          );
        }
        final order = _orders[i - 1];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: order.status.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(order.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(width: 8),
                          StatusBadge(
                              label: order.status.label,
                              color: order.status.color),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(order.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.5,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 2),
                      Text(order.when,
                          style: TextStyle(
                              fontSize: 11.5,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.45))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(rs(order.total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brand)),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Reordering ${order.id}…')));
                      },
                      child: const Text('Reorder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PastOrder {
  final String id;
  final String summary;
  final double total;
  final OrderStatus status;
  final String when;
  _PastOrder(this.id, this.summary, this.total, this.status, this.when);
}

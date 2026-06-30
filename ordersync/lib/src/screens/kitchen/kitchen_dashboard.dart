import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models.dart';
import '../../sample_data.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Portal 2 — Kitchen / Dispatch Interface. A tablet-optimised landscape queue
/// of live tickets with prep-time Progress Indicators, big status ElevatedButtons
/// and a rider-assignment Dialog Box.
class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  final List<Order> _tickets = SampleData.kitchenTickets();
  final Map<String, double> _progress = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Animate the prep-time countdown for tickets currently being prepared.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        for (final t in _tickets) {
          if (t.status == OrderStatus.preparing) {
            _progress[t.id] = ((_progress[t.id] ?? 0) + 0.018).clamp(0.0, 1.0);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _countOf(OrderStatus s) => _tickets.where((t) => t.status == s).length;

  void _advance(Order order) {
    setState(() {
      switch (order.status) {
        case OrderStatus.placed:
          order.status = OrderStatus.accepted;
        case OrderStatus.accepted:
          order.status = OrderStatus.preparing;
          _progress[order.id] = 0;
        case OrderStatus.preparing:
          order.status = OrderStatus.ready;
        default:
          break;
      }
    });
  }

  Future<void> _assignRider(Order order) async {
    final online = SampleData.riders().where((r) => r.online).toList();
    Rider? selected = online.isNotEmpty ? online.first : null;

    final rider = await showDialog<Rider>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Assign a rider · ${order.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select an available rider to dispatch this order.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              RadioGroup<Rider>(
                groupValue: selected,
                onChanged: (v) => setLocal(() => selected = v),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final r in online)
                      RadioListTile<Rider>(
                        value: r,
                        title: Text(r.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${r.vehicle} · ${r.plate} · ⭐ ${r.rating}'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed:
                  selected == null ? null : () => Navigator.pop(ctx, selected),
              child: const Text('Assign & Dispatch'),
            ),
          ],
        ),
      ),
    );

    if (rider != null) {
      setState(() {
        order.assignedRider = rider;
        order.status = OrderStatus.assigned;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${order.id} assigned to ${rider.name}')));
    }
  }

  void _dispatch(Order order) {
    setState(() => _tickets.remove(order));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} dispatched & cleared')));
  }

  int _columnsFor(double width) {
    if (width >= 1180) return 3;
    if (width >= 720) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Dispatch'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: StatusBadge(
                  label: 'Station 1 · Online',
                  color: StatusColors.online,
                  icon: Icons.circle),
            ),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.staffLogin),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Live stats strip ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _stat('New', _countOf(OrderStatus.placed),
                    StatusColors.newOrder),
                _stat('Preparing', _countOf(OrderStatus.preparing),
                    StatusColors.preparing),
                _stat('Ready', _countOf(OrderStatus.ready),
                    StatusColors.ready),
                _stat('Assigned', _countOf(OrderStatus.assigned),
                    StatusColors.assigned),
              ],
            ),
          ),
          Expanded(
            child: _tickets.isEmpty
                ? const _AllClear()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _columnsFor(constraints.maxWidth);
                      const spacing = 14.0;
                      final cardWidth = columns == 1
                          ? constraints.maxWidth - 32
                          : (constraints.maxWidth -
                                  32 -
                                  spacing * (columns - 1)) /
                              columns;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final order in _tickets)
                              SizedBox(
                                width: cardWidth,
                                child: _TicketCard(
                                  order: order,
                                  progress: _progress[order.id] ?? 0,
                                  onAdvance: () => _advance(order),
                                  onAssign: () => _assignRider(order),
                                  onDispatch: () => _dispatch(order),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Order order;
  final double progress;
  final VoidCallback onAdvance;
  final VoidCallback onAssign;
  final VoidCallback onDispatch;

  const _TicketCard({
    required this.order,
    required this.progress,
    required this.onAdvance,
    required this.onAssign,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(order.customerName,
                          style: TextStyle(
                              fontSize: 13,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                StatusBadge(label: order.status.label, color: order.status.color),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: scheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.5))),
                ),
              ],
            ),
            const Divider(height: 20),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${item.quantity}×',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppTheme.brand)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.dish.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            Text('${item.size} · ${item.spiceLabel}',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Prep-time progress indicator
            if (order.status == OrderStatus.preparing) ...[
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 15, color: StatusColors.preparing),
                  const SizedBox(width: 6),
                  Text('Prep ${(progress * 100).round()}% · '
                      '${((1 - progress) * order.prepMinutes).ceil()} min left',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: StatusColors.preparing,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Action buttons
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (order.status) {
      case OrderStatus.placed:
        return _bigButton('Accept Order', Icons.check_rounded,
            StatusColors.newOrder, onAdvance);
      case OrderStatus.accepted:
        return _bigButton('Start Preparing', Icons.outdoor_grill_rounded,
            StatusColors.preparing, onAdvance);
      case OrderStatus.preparing:
        return _bigButton('Mark as Ready', Icons.done_all_rounded,
            StatusColors.ready, onAdvance);
      case OrderStatus.ready:
        return _bigButton('Assign Rider', Icons.delivery_dining_rounded,
            AppTheme.brand, onAssign);
      case OrderStatus.assigned:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StatusColors.assigned.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining_rounded,
                      color: StatusColors.assigned),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Rider: ${order.assignedRider?.name ?? ''}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onDispatch,
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Complete Dispatch'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _bigButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          const Text('All tickets cleared!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('The kitchen queue is empty.',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

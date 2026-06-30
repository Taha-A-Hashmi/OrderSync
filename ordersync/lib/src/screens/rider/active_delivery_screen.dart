import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mock_map.dart';

/// The Rider "Active Delivery" navigation view. A mapping widget fills the
/// screen via [Expanded] and large OutlinedButtons advance the physical
/// status. The route can only be dismissed (popped) once delivery completes.
class ActiveDeliveryScreen extends StatefulWidget {
  final Order mission;
  const ActiveDeliveryScreen({super.key, required this.mission});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  int _stage = 0; // 0 -> picked up, 1 -> arrived, 2 -> delivered

  static const _actions = ['Confirm Pick Up', 'Mark Arrived', 'Mark Delivered'];
  static const _titles = [
    'Head to the kitchen',
    'Drive to the customer',
    'You have arrived',
  ];

  void _advance() {
    if (_stage < _actions.length - 1) {
      setState(() => _stage++);
    } else {
      // Delivery complete -> return result to the dashboard.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false, // cannot leave until the delivery is finished
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Finish the delivery before leaving')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Active · ${widget.mission.id}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: StatusBadge(
                    label: 'ON DELIVERY',
                    color: StatusColors.enRoute,
                    icon: Icons.circle),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ---- Navigation map fills the screen ----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: MockMap(
                  startLabel: 'Kitchen',
                  endLabel: widget.mission.customerName,
                ),
              ),
            ),

            // ---- Status + actions panel ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage indicator
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        _stageDot(i),
                        if (i < 2)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: i < _stage
                                  ? AppTheme.brand
                                  : scheme.surfaceContainerHighest,
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_titles[_stage],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                          _stage == 0
                              ? Icons.storefront_rounded
                              : Icons.location_on_rounded,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _stage == 0
                              ? 'OrderSync Kitchen, Supply Bazaar'
                              : widget.mission.address,
                          style: TextStyle(
                              color:
                                  scheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Large OutlinedButtons for physical status updates.
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Calling customer… (Phase 4 dialer)')));
                            },
                            icon: const Icon(Icons.call_rounded),
                            label: const Text('Call'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _stage == 2
                                  ? StatusColors.delivered
                                  : AppTheme.brand,
                              side: BorderSide(
                                color: _stage == 2
                                    ? StatusColors.delivered
                                    : AppTheme.brand,
                                width: 1.8,
                              ),
                            ),
                            onPressed: _advance,
                            icon: Icon(_stage == 2
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded),
                            label: Text(_actions[_stage]),
                          ),
                        ),
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

  Widget _stageDot(int i) {
    final reached = i <= _stage;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: reached ? AppTheme.brand : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: reached
              ? AppTheme.brand
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          width: 2,
        ),
      ),
      child: Icon(
        [Icons.shopping_bag_rounded, Icons.navigation_rounded, Icons.home_rounded][i],
        size: 15,
        color: reached
            ? Colors.black
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

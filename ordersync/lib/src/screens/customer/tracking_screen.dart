import 'dart:async';

import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mock_map.dart';

/// Live Tracking Dashboard. A [Stack] layers the (mock) map at the base with a
/// floating Card overlaid at the bottom showing the rider's details and a Call
/// IconButton — exactly as described in the proposal. Real Google Maps + native
/// dialing arrive in Phase 4.
class TrackingScreen extends StatefulWidget {
  final Order order;
  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  int _stage = 0; // 0 picked up, 1 on the way, 2 arrived, 3 delivered
  int _eta = 18;

  static const _stages = [
    'Picked up from kitchen',
    'On the way to you',
    'Arriving now',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted) return;
      setState(() {
        if (_stage < _stages.length - 1) _stage++;
        _eta = (_eta - 6).clamp(0, 18);
        if (_stage == _stages.length - 1) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _callRider() {
    final rider = widget.order.assignedRider;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call your rider?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rider?.name ?? 'Rider',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(rider?.phone ?? ''),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('Dialing rider… (native dialer integrates in Phase 4)'),
              ));
            },
            icon: const Icon(Icons.call_rounded),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final delivered = _stage == _stages.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          // ---- Base layer: the map ----
          const Positioned.fill(child: MockMap(startLabel: 'Kitchen')),

          // ---- Top status bar ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              stage: _stage,
              stageLabel: _stages[_stage],
              eta: _eta,
              delivered: delivered,
            ),
          ),

          // ---- Floating rider card ----
          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: _RiderCard(
              order: widget.order,
              statusLabel: _stages[_stage],
              delivered: delivered,
              onCall: _callRider,
              onDone: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int stage;
  final String stageLabel;
  final int eta;
  final bool delivered;

  const _TopBar({
    required this.stage,
    required this.stageLabel,
    required this.eta,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(delivered ? 'Order delivered 🎉' : stageLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(
                        delivered
                            ? 'Enjoy your meal!'
                            : 'Estimated arrival in $eta min',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: delivered ? 'DONE' : 'LIVE',
                  color: delivered ? StatusColors.delivered : StatusColors.enRoute,
                  icon: Icons.circle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (stage + 1) / 4,
                minHeight: 7,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  final Order order;
  final String statusLabel;
  final bool delivered;
  final VoidCallback onCall;
  final VoidCallback onDone;

  const _RiderCard({
    required this.order,
    required this.statusLabel,
    required this.delivered,
    required this.onCall,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final rider = order.assignedRider;
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Rider avatar (Image widget with graceful fallback).
                ClipOval(
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Image.network(
                      'https://i.pravatar.cc/120?img=12',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppTheme.brand,
                        alignment: Alignment.center,
                        child: Text(
                          (rider?.name ?? 'R')[0],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rider?.name ?? 'Your rider',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('${rider?.vehicle ?? ''} · ${rider?.plate ?? ''}',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 15, color: AppTheme.brandAlt),
                          const SizedBox(width: 2),
                          Text('${rider?.rating ?? 4.8}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call rider (IconButton) + message.
                _circleButton(context, Icons.message_outlined, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('In-app chat arrives in Phase 3')));
                }),
                const SizedBox(width: 8),
                _circleButton(context, Icons.call_rounded, onCall,
                    filled: true),
              ],
            ),
            if (delivered) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDone,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _circleButton(BuildContext context, IconData icon, VoidCallback onTap,
      {bool filled = false}) {
    return Material(
      color: filled
          ? StatusColors.ready
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon,
              size: 20, color: filled ? Colors.white : null),
        ),
      ),
    );
  }
}

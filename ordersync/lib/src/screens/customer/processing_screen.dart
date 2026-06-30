import 'package:flutter/material.dart';

import '../../models.dart';
import '../../sample_data.dart';
import '../../theme.dart';
import 'tracking_screen.dart';

/// Brief "Processing" screen — a CircularProgressIndicator while the order is
/// confirmed, then a Push Replacement to live tracking so the user cannot
/// navigate back to the spinner.
class ProcessingScreen extends StatefulWidget {
  final Order order;
  const ProcessingScreen({super.key, required this.order});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _step = 0;
  static const _steps = [
    'Sending order to the kitchen',
    'Kitchen confirmed your order',
    'Assigning a nearby rider',
  ];

  @override
  void initState() {
    super.initState();
    _advance();
  }

  Future<void> _advance() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() => _step = i);
    }
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Assign a rider and hand the order forward to the tracking screen.
    widget.order
      ..assignedRider = SampleData.riders().first
      ..status = OrderStatus.pickedUp;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TrackingScreen(order: widget.order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(strokeWidth: 5),
                    ),
                    Text('🍳', style: TextStyle(fontSize: 34)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('Order ${widget.order.id}',
                  style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Placing your order...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 28),
              for (var i = 0; i < _steps.length; i++)
                _stepRow(_steps[i], done: i <= _step, active: i == _step),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(String label, {required bool done, required bool active}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: done
                ? const Icon(Icons.check_circle_rounded,
                    color: StatusColors.ready, size: 22)
                : active
                    ? const CircularProgressIndicator(strokeWidth: 2.4)
                    : Icon(Icons.radio_button_unchecked_rounded,
                        size: 22,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3)),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: done || active ? 1 : 0.5))),
        ],
      ),
    );
  }
}

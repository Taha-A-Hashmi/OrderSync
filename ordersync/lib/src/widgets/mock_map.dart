import 'package:flutter/material.dart';
import '../theme.dart';

/// A lightweight, self-contained stylised map used wherever the proposal calls
/// for a "Google Maps Widget". The real Google Maps SDK is integrated in
/// Phase 4 — for the Phase 1/2 UI this CustomPaint mock keeps the app fully
/// offline and runnable on every platform while still showing a live route and
/// an animated rider marker.
class MockMap extends StatefulWidget {
  final bool animate;
  final String startLabel;
  final String endLabel;

  const MockMap({
    super.key,
    this.animate = true,
    this.startLabel = 'Kitchen',
    this.endLabel = 'You',
  });

  @override
  State<MockMap> createState() => _MockMapState();
}

class _MockMapState extends State<MockMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant MockMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _MapPainter(
              progress: widget.animate ? _controller.value : 0.45,
              isDark: isDark,
              brand: AppTheme.brand,
              startLabel: widget.startLabel,
              endLabel: widget.endLabel,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color brand;
  final String startLabel;
  final String endLabel;

  _MapPainter({
    required this.progress,
    required this.isDark,
    required this.brand,
    required this.startLabel,
    required this.endLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? const Color(0xFF202028) : const Color(0xFFE9ECF1);
    final block = isDark ? const Color(0xFF2A2A35) : const Color(0xFFF7F8FB);
    final road = isDark ? const Color(0xFF14141A) : const Color(0xFFD3D8E0);

    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // City blocks separated by "roads".
    final blockPaint = Paint()..color = block;
    final roadPaint = Paint()..color = road;
    const cell = 54.0;
    const gap = 12.0;
    for (double y = -20; y < size.height; y += cell + gap) {
      canvas.drawRect(
          Rect.fromLTWH(0, y + cell, size.width, gap), roadPaint);
      for (double x = -20; x < size.width; x += cell + gap) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cell, cell),
            const Radius.circular(6),
          ),
          blockPaint,
        );
        canvas.drawRect(
            Rect.fromLTWH(x + cell, y, gap, size.height), roadPaint);
      }
    }

    // Delivery route (two smooth bends across the map).
    final start = Offset(size.width * 0.16, size.height * 0.82);
    final end = Offset(size.width * 0.84, size.height * 0.18);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.40,
          size.width * 0.52, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.52, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = brand.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Endpoints.
    _drawPin(canvas, start, const Color(0xFF22C55E));
    _drawPin(canvas, end, const Color(0xFFEF4444));

    // Animated rider marker travelling along the route.
    final metric = path.computeMetrics().first;
    final tangent =
        metric.getTangentForOffset(metric.length * progress.clamp(0, 1));
    if (tangent != null) {
      final p = tangent.position;
      canvas.drawCircle(p, 16, Paint()..color = brand.withValues(alpha: 0.22));
      canvas.drawCircle(p, 9, Paint()..color = Colors.white);
      canvas.drawCircle(p, 6, Paint()..color = brand);
    }

    _drawLabel(canvas, start, startLabel, size);
    _drawLabel(canvas, end, endLabel, size);
  }

  void _drawPin(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(
        center, 13, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(center, 9, Paint()..color = color);
    canvas.drawCircle(center, 3.2, Paint()..color = Colors.white);
  }

  void _drawLabel(Canvas canvas, Offset anchor, String text, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padX = 7.0;
    final padY = 3.0;
    double left = anchor.dx - tp.width / 2 - padX;
    double top = anchor.dy - 34;
    left = left.clamp(4.0, size.width - tp.width - 2 * padX - 4);
    top = top.clamp(4.0, size.height - 24);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          left, top, tp.width + padX * 2, tp.height + padY * 2),
      const Radius.circular(8),
    );
    canvas.drawRRect(
        rect, Paint()..color = Colors.black.withValues(alpha: 0.65));
    tp.paint(canvas, Offset(left + padX, top + padY));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

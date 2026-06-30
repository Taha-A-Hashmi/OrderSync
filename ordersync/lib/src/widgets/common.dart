import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// Image widget for a dish. Tries to load a real network photo and, while it
/// loads or if there is no connectivity, shows a cohesive tinted gradient with
/// the dish emoji — so the menu always looks intentional, online or offline.
class DishImage extends StatelessWidget {
  final Dish dish;
  final double? height;
  final double iconScale;

  const DishImage({
    super.key,
    required this.dish,
    this.height,
    this.iconScale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        dish.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _fallback(showSpinner: true, progress: progress);
        },
        errorBuilder: (context, error, stack) => _fallback(),
      ),
    );
  }

  Widget _fallback({bool showSpinner = false, ImageChunkEvent? progress}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dish.tint.withValues(alpha: 0.95),
            dish.tint.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            dish.emoji,
            style: TextStyle(fontSize: 52 * iconScale),
          ),
          if (showSpinner)
            Positioned(
              right: 10,
              bottom: 10,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress != null && progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A compact, vibrantly-coloured status accent chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: icon == null ? 10 : 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// The OrderSync wordmark + glyph used on the login screen and drawers.
class BrandMark extends StatelessWidget {
  final double size;
  final bool showText;

  const BrandMark({super.key, this.size = 44, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.brand, AppTheme.brandAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.sync_alt_rounded,
          color: Colors.black, size: size * 0.55),
    );
    if (!showText) return logo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(width: size * 0.3),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Order',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextSpan(
              text: 'Sync',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.brand,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

/// Small +/- quantity control reused in the cart and customiser.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final double size;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(context, Icons.remove_rounded,
              () => onChanged(quantity - 1)),
          SizedBox(
            width: size,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          _btn(context, Icons.add_rounded, () => onChanged(quantity + 1)),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon,
            size: 18, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

/// Section heading with an optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Currency helper — the app is set in Abbottabad, so prices are in PKR.
String rs(num value) => 'Rs ${value.round()}';

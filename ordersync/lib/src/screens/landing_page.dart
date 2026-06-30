import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../sample_data.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Public marketing landing page — the app's entry point. Customers reach the
/// ordering experience from here; staff access is intentionally not shown.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _goToLogin(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.login);

  void _goToStaff(BuildContext context) =>
      Navigator.pushNamed(context, AppRoutes.staffLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 880;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _TopBar(
                        onSignIn: () => _goToLogin(context),
                        onStaff: () => _goToStaff(context))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : 20, vertical: 8),
                    child: _Hero(isWide: isWide, onOrder: () => _goToLogin(context)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : 20, vertical: 20),
                    child: const _StatsStrip(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : 20, vertical: 12),
                    child: _Features(isWide: isWide),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isWide ? 48 : 20, 24, isWide ? 48 : 20, 8),
                    child: const _PopularStrip(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isWide ? 48 : 20),
                    child: _CtaBanner(onOrder: () => _goToLogin(context)),
                  ),
                ),
                SliverToBoxAdapter(
                    child: _Footer(onStaff: () => _goToStaff(context))),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onStaff;
  const _TopBar({required this.onSignIn, required this.onStaff});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 880;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20, vertical: 16),
      child: Row(
        children: [
          const BrandMark(size: 40),
          const Spacer(),
          if (isWide) ...[
            TextButton(onPressed: onSignIn, child: const Text('Menu')),
            const SizedBox(width: 4),
          ],
          // Staff & Admin entry (kitchen / rider consoles).
          TextButton.icon(
            onPressed: onStaff,
            icon: const Icon(Icons.shield_outlined, size: 18),
            label: const Text('Staff'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSignIn,
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isWide;
  final VoidCallback onOrder;
  const _Hero({required this.isWide, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    final text = _heroText(context, onOrder);
    final art = const _HeroArt();
    if (!isWide) {
      return Column(
        children: [
          text,
          const SizedBox(height: 24),
          SizedBox(height: 240, child: art),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: text),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: SizedBox(height: 360, child: art)),
      ],
    );
  }

  Widget _heroText(BuildContext context, VoidCallback onOrder) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.brand.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('🔥 Now delivering across Abbottabad',
              style: TextStyle(
                  color: AppTheme.brand,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
        const SizedBox(height: 18),
        Text(
          'Hot food,\ndelivered live.',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 56 : 38,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Order from your favourite local kitchens and watch your rider '
            'approach in real time — from our wok to your doorstep.',
            textAlign: isWide ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.shopping_bag_rounded),
                label: const Text('Order Now',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text('Explore Menu',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1A0B), Color(0xFF3A2410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.25)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Text('🍲', style: TextStyle(fontSize: 120)),
          ),
          Positioned(
            left: 24,
            bottom: 90,
            child: Text('🍔', style: TextStyle(fontSize: 64)),
          ),
          Positioned(
            right: 40,
            bottom: 40,
            child: Text('🛵', style: TextStyle(fontSize: 72)),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_searching_rounded,
                      color: AppTheme.brand, size: 30),
                  SizedBox(height: 8),
                  Text('Live GPS tracking',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  Text('Your rider, on the map, in real time',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      children: const [
        _Stat('12+', 'Signature dishes'),
        _Stat('25 min', 'Avg delivery'),
        _Stat('4.8★', 'Customer rating'),
        _Stat('100%', 'Live tracked'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.brand)),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
      ],
    );
  }
}

class _Features extends StatelessWidget {
  final bool isWide;
  const _Features({required this.isWide});

  static const _items = [
    (Icons.my_location_rounded, 'Real-time tracking',
        'Follow your rider on a live map from pickup to your door.'),
    (Icons.bolt_rounded, 'One-tap dispatch',
        'Kitchens accept and dispatch orders in a single tap.'),
    (Icons.delivery_dining_rounded, 'Local rider fleet',
        'A dedicated fleet of nearby riders keeps food piping hot.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final item in _items)
        _FeatureCard(icon: item.$1, title: item.$2, body: item.$3),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Why OrderSync'),
        const SizedBox(height: 14),
        if (isWide)
          Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 16),
              ],
            ],
          )
        else
          Column(
            children: [
              for (final c in cards)
                Padding(
                    padding: const EdgeInsets.only(bottom: 12), child: c),
            ],
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _FeatureCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.brand, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(body,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _PopularStrip extends StatelessWidget {
  const _PopularStrip();

  @override
  Widget build(BuildContext context) {
    final dishes = SampleData.menu.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Popular right now'),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final dish = dishes[i];
              return SizedBox(
                width: 150,
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: DishImage(dish: dish)),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dish.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5)),
                            Text(rs(dish.price),
                                style: const TextStyle(
                                    color: AppTheme.brand,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CtaBanner extends StatelessWidget {
  final VoidCallback onOrder;
  const _CtaBanner({required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.brand, AppTheme.brandAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Hungry yet?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Sign in and place your first order in under a minute.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.7),
                  fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: onOrder,
            child: const Text('Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onStaff;
  const _Footer({required this.onStaff});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          const BrandMark(size: 34),
          const SizedBox(height: 10),
          Text('Real-time food delivery for high-traffic local kitchens.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 14),
          // Staff & Admin portal — kitchen/rider console login & onboarding.
          OutlinedButton.icon(
            onPressed: onStaff,
            icon: const Icon(Icons.shield_outlined, size: 18),
            label: const Text('Staff & Admin Portal'),
          ),
          const SizedBox(height: 16),
          Text('© 2026 OrderSync · Abbottabad, Pakistan',
              style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.45))),
        ],
      ),
    );
  }
}

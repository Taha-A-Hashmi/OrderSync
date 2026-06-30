import 'package:flutter/material.dart';

import '../../cart_model.dart';
import '../../models.dart';
import '../../sample_data.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'dish_customizer.dart';

/// Customer "Menu Discovery" screen — a TabBar to switch between categories and
/// a responsive GridView of signature dishes. Tapping an item triggers the
/// customisation Bottom Sheet (Phase 1).
class MenuPage extends StatefulWidget {
  final VoidCallback onViewCart;
  const MenuPage({super.key, required this.onViewCart});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _query = '';

  Future<void> _customize(Dish dish) async {
    final cart = CartScope.of(context);
    final item = await showDishCustomizer(context, dish);
    if (item == null || !mounted) return;
    cart.add(item); // pass the configured item forward into the cart
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${item.dish.name} added to cart'),
        action: SnackBarAction(
            label: 'View Cart', onPressed: widget.onViewCart),
      ));
  }

  int _columnsFor(double width) {
    if (width >= 1100) return 4;
    if (width >= 760) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final categories = SampleData.categories;
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          // ---- Search field ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dishes, e.g. Karahi',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() => _query = ''),
                      ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // ---- Category tabs ----
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppTheme.brand,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelColor: AppTheme.brand,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              tabs: [for (final c in categories) Tab(text: c)],
            ),
          ),
          const Divider(height: 1),

          // ---- Per-category grids ----
          Expanded(
            child: TabBarView(
              children: [
                for (final category in categories)
                  _buildGrid(SampleData.byCategory(category)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Dish> dishes) {
    final filtered = _query.isEmpty
        ? dishes
        : dishes
            .where((d) =>
                d.name.toLowerCase().contains(_query.toLowerCase()) ||
                d.description.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return const _EmptyMenu();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: filtered.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, i) =>
              _DishCard(dish: filtered[i], onTap: () => _customize(filtered[i])),
        );
      },
    );
  }
}

class _DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback onTap;
  const _DishCard({required this.dish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + veg dot.
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: DishImage(dish: dish)),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: dish.isVeg
                                ? StatusColors.ready
                                : StatusColors.offline,
                            width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dish.isVeg
                                ? StatusColors.ready
                                : StatusColors.offline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text block.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.5)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppTheme.brandAlt),
                      const SizedBox(width: 2),
                      Text('${dish.rating}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(rs(dish.price),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppTheme.brand)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.brand,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.black, size: 22),
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

class _EmptyMenu extends StatelessWidget {
  const _EmptyMenu();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🍽️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text('No dishes match your search',
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

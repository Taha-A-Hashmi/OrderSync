import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../cart_model.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'cart_page.dart';
import 'menu_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';

/// Customer portal shell — owns the shared cart and ties the four destinations
/// together with a Bottom Navigation Bar, a Drawer and a Floating Action
/// Button (Phase 1 navigation chrome + Phase 2 Bottom/Drawer navigation).
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  final CartModel _cart = CartModel();
  int _index = 0;

  static const _titles = ['OrderSync', 'Your Cart', 'My Orders', 'Profile'];

  late final List<Widget> _pages = [
    MenuPage(onViewCart: () => _select(1)),
    CartPage(onBrowseMenu: () => _select(0)),
    const OrdersPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  void _select(int i) => setState(() => _index = i);

  UserSession get _session {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is UserSession
        ? args
        : const UserSession(
            name: 'Ayesha Khan',
            email: 'ayesha@ordersync.pk',
            role: UserRole.customer);
  }

  @override
  Widget build(BuildContext context) {
    return CartScope(
      cart: _cart,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_index]),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _select(0),
            ),
            // Cart action with a live badge driven by the CartModel.
            AnimatedBuilder(
              animation: _cart,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Badge(
                  isLabelVisible: _cart.count > 0,
                  label: Text('${_cart.count}'),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () => _select(1),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: IndexedStack(index: _index, children: _pages),
        floatingActionButton: _index == 0
            ? AnimatedBuilder(
                animation: _cart,
                builder: (context, _) => _cart.isEmpty
                    ? const SizedBox.shrink()
                    : FloatingActionButton.extended(
                        onPressed: () => _select(1),
                        icon: const Icon(Icons.shopping_cart_checkout_rounded),
                        label: Text('View Cart · ${rs(_cart.subtotal)}'),
                      ),
              )
            : null,
        bottomNavigationBar: AnimatedBuilder(
          animation: _cart,
          builder: (context, _) => NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: 'Menu'),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _cart.count > 0,
                  label: Text('${_cart.count}'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: const Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Orders'),
              const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final session = _session;
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.brand,
                    child: Text(
                      session.name.isNotEmpty ? session.name[0] : 'U',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(session.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: scheme.onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 8),
            _drawerItem(Icons.restaurant_menu_rounded, 'Browse Menu', () {
              Navigator.pop(context);
              _select(0);
            }),
            _drawerItem(Icons.shopping_bag_rounded, 'My Cart', () {
              Navigator.pop(context);
              _select(1);
            }),
            _drawerItem(Icons.receipt_long_rounded, 'My Orders', () {
              Navigator.pop(context);
              _select(2);
            }),
            _drawerItem(Icons.person_rounded, 'Profile', () {
              Navigator.pop(context);
              _select(3);
            }),
            const Divider(height: 8),
            _drawerItem(Icons.help_outline_rounded, 'Help & Support',
                () => Navigator.pop(context)),
            _drawerItem(Icons.info_outline_rounded, 'About OrderSync', () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'OrderSync',
                applicationVersion: 'Phase 1 & 2 · v1.0',
                applicationIcon: const BrandMark(size: 40, showText: false),
                children: const [
                  Text(
                      'A real-time, cross-platform food delivery ecosystem for '
                      'high-traffic local food businesses.'),
                ],
              );
            }),
            const Spacer(),
            const Divider(height: 8),
            // Log out -> back to the public landing page via pushReplacement.
            _drawerItem(Icons.logout_rounded, 'Log out', () {
              Navigator.pushReplacementNamed(context, AppRoutes.landing);
            }, color: StatusColors.offline),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
    );
  }
}

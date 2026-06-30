import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../models.dart';
import '../../sample_data.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/mock_map.dart';
import 'active_delivery_screen.dart';

/// Portal 3 — Delivery Rider Interface. A status Switch in the AppBar toggles
/// Online/Offline; while online the rider sees the idle map and an Active
/// Mission Card. Accepting a mission pushes the full-screen delivery flow.
class RiderDashboard extends StatefulWidget {
  const RiderDashboard({super.key});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  bool _online = false;
  int _completed = 0;
  double _earnings = 0;

  final List<Order> _missions = [
    Order(
      id: 'OS-1042',
      customerName: 'Ayesha Khan',
      address: 'House 12, Street 4, Supply Bazaar',
      items: [CartItem(dish: SampleData.menu[0]), CartItem(dish: SampleData.menu[9])],
    ),
    Order(
      id: 'OS-1045',
      customerName: 'Hassan Raza',
      address: 'Flat 7B, Jinnahabad',
      items: [CartItem(dish: SampleData.menu[3], quantity: 2)],
    ),
  ];

  Future<void> _acceptMission(Order mission) async {
    // Push the Active Delivery screen; it only pops once delivery completes.
    final delivered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ActiveDeliveryScreen(mission: mission)),
    );
    if (delivered == true) {
      setState(() {
        _missions.remove(mission);
        _completed++;
        _earnings += 180 + mission.itemCount * 20;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${mission.id} delivered · +${rs(180)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider'),
        actions: [
          // Prominent Online/Offline Switch in the AppBar.
          Row(
            children: [
              Text(_online ? 'Online' : 'Offline',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _online
                          ? StatusColors.online
                          : StatusColors.offline)),
              Switch(
                value: _online,
                onChanged: (v) => setState(() => _online = v),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.staffLogin),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _online ? _buildOnline(context) : const _OfflineView(),
    );
  }

  Widget _buildOnline(BuildContext context) {
    return Column(
      children: [
        // Earnings strip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              _stat(Icons.check_circle_outline_rounded, 'Deliveries',
                  '$_completed'),
              const SizedBox(width: 12),
              _stat(Icons.account_balance_wallet_outlined, 'Earnings',
                  rs(_earnings)),
            ],
          ),
        ),
        Expanded(
          child: _missions.isEmpty
              ? _idleMap('No missions right now', 'Stay online — new orders\nwill appear here.')
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: MockMap(
                            startLabel: 'Kitchen', endLabel: 'Drop-off'),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: const [
                            Icon(Icons.bolt_rounded,
                                color: AppTheme.brand, size: 20),
                            SizedBox(width: 4),
                            Text('New Mission Available',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MissionCard(
                        mission: _missions.first,
                        onAccept: () => _acceptMission(_missions.first),
                        onDecline: () =>
                            setState(() => _missions.removeAt(0)),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _idleMap(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: MockMap(animate: false, endLabel: 'Drop-off')),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.brand),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Order mission;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _MissionCard({
    required this.mission,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mission.id,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18)),
                const Spacer(),
                StatusBadge(
                    label: '+ ${rs(180 + mission.itemCount * 20)}',
                    color: StatusColors.ready),
              ],
            ),
            const SizedBox(height: 14),
            _leg(context, Icons.storefront_rounded, StatusColors.online,
                'PICKUP', 'OrderSync Kitchen, Supply Bazaar'),
            Padding(
              padding: const EdgeInsets.only(left: 19),
              child: SizedBox(
                height: 22,
                child: VerticalDivider(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                  thickness: 1.5,
                ),
              ),
            ),
            _leg(context, Icons.location_on_rounded, StatusColors.offline,
                'DROP-OFF', mission.address),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text('${mission.itemCount} items · ${mission.customerName}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.route_rounded,
                    size: 16, color: AppTheme.brand),
                const SizedBox(width: 4),
                const Text('3.2 km',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Accept Mission'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _leg(BuildContext context, IconData icon, Color color, String label,
      String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: color)),
              const SizedBox(height: 2),
              Text(address,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: StatusColors.offline.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.power_settings_new_rounded,
                  size: 44, color: StatusColors.offline),
            ),
            const SizedBox(height: 22),
            const Text("You're offline",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Flip the switch in the top bar to go online\nand start receiving delivery missions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 1.4,
                  color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

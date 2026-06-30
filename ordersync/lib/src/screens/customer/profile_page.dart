import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Customer profile + app settings. Hosts the Light/Dark Switch that flips the
/// whole app theme (state lives on [OrderSyncApp]).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;
  bool _promos = false;
  bool _saveCart = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = OrderSyncApp.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---- Profile header ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.brand,
                  child: const Text('A',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ayesha Khan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('ayesha@ordersync.pk',
                          style: TextStyle(
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13)),
                      const SizedBox(height: 8),
                      const StatusBadge(
                          label: '⭐ Gold Member', color: AppTheme.brandAlt),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toast('Edit profile (Phase 3)'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ---- Appearance ----
        const SectionHeader('Appearance'),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Charcoal theme for low-light ordering'),
            secondary: Icon(app.isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            value: app.isDark,
            onChanged: (v) => app.setDarkMode(v),
          ),
        ),
        const SizedBox(height: 18),

        // ---- Notifications ----
        const SectionHeader('Notifications'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Order updates'),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Promotions & offers'),
                secondary: const Icon(Icons.local_offer_outlined),
                value: _promos,
                onChanged: (v) => setState(() => _promos = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Save cart between sessions'),
                subtitle: const Text('Restored via local cache in Phase 4'),
                secondary: const Icon(Icons.save_outlined),
                value: _saveCart,
                onChanged: (v) => setState(() => _saveCart = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ---- Account ----
        const SectionHeader('Account'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _tile(Icons.location_on_outlined, 'Saved addresses'),
              const Divider(height: 1),
              _tile(Icons.payment_outlined, 'Payment methods'),
              const Divider(height: 1),
              _tile(Icons.help_outline_rounded, 'Help & support'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _toast('$label (Phase 3)'),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

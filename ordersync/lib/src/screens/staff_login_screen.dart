import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models.dart';
import '../theme.dart';

/// Unlisted Kitchen / Rider console login. This endpoint is never linked from
/// the public landing or customer login — only reachable directly at `/staff`
/// (or via the hidden long-press on the landing footer). Access is gated by a
/// single set of admin credentials.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  // Demo admin credentials for the restricted consoles.
  static const String adminEmail = 'taha@ordersync.com';
  static const String adminPassword = 'admin';

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: StaffLoginScreen.adminEmail);
  final _passwordController =
      TextEditingController(text: StaffLoginScreen.adminPassword);

  UserRole _console = UserRole.kitchen;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enterConsole() {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final emailOk = _emailController.text.trim().toLowerCase() ==
        StaffLoginScreen.adminEmail;
    final passwordOk =
        _passwordController.text == StaffLoginScreen.adminPassword;

    if (!emailOk || !passwordOk) {
      setState(() => _error = 'Invalid admin credentials. Access denied.');
      return;
    }

    final session = UserSession(
      name: _console == UserRole.kitchen ? 'Kitchen Station 1' : 'Bilal Ahmed',
      email: _emailController.text.trim(),
      role: _console,
    );
    Navigator.pushReplacementNamed(context, _console.route,
        arguments: session);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Restricted Access'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.landing),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Restricted badge
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: StatusColors.offline.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                StatusColors.offline.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: StatusColors.offline, size: 34),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Staff Console',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    'Authorized personnel only. Choose a console and sign in '
                    'with your admin credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 24),

                  // Console picker
                  Center(
                    child: SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.kitchen,
                          label: Text('Kitchen'),
                          icon: Icon(Icons.soup_kitchen_rounded),
                        ),
                        ButtonSegment(
                          value: UserRole.rider,
                          label: Text('Rider'),
                          icon: Icon(Icons.delivery_dining_rounded),
                        ),
                      ],
                      selected: {_console},
                      onSelectionChanged: (s) =>
                          setState(() => _console = s.first),
                    ),
                  ),
                  const SizedBox(height: 22),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Admin email',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Admin password',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StatusColors.offline.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                StatusColors.offline.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: StatusColors.offline, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: StatusColors.offline,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _enterConsole,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: Text('Enter ${_console.label} Console'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Admin onboarding: register a new kitchen or rider account.
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      _console == UserRole.kitchen
                          ? AppRoutes.kitchenSignup
                          : AppRoutes.riderSignup,
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(_console == UserRole.kitchen
                        ? 'Register a new kitchen'
                        : 'Onboard a new rider'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.landing),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back to OrderSync'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

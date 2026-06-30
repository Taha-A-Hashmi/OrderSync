import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models.dart';
import '../theme.dart';

/// Dummy (UI-only) account creation screen, parameterised by [role] so it
/// serves customers, kitchen staff and riders. No backend yet — real
/// registration is wired to Firebase Auth in Phase 3; on submit this simply
/// validates the form and drops the new user into their portal.
class SignupScreen extends StatefulWidget {
  final UserRole role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController(text: '+92 ');
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // Role-specific fields.
  final _kitchenName = TextEditingController();
  final _plate = TextEditingController();
  String? _area;
  String? _vehicle;

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  static const _areas = [
    'Supply Bazaar',
    'Jinnahabad',
    'Mandian',
    'PMA Road',
    'Kakul Road',
    'Nawan Shehr',
  ];
  static const _vehicles = ['Motorcycle', 'Scooter', 'Bicycle', 'Car'];

  bool get _isStaff => widget.role != UserRole.customer;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _kitchenName.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please accept the terms to continue')));
      return;
    }

    // Dummy account — no persistence. Log the new user straight into their
    // portal (Firebase-backed registration arrives in Phase 3).
    final session = UserSession(
      name: _name.text.trim(),
      email: _email.text.trim(),
      role: widget.role,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Welcome, ${_name.text.trim()}! Account created.')));
    Navigator.pushReplacementNamed(context, widget.role.route,
        arguments: session);
  }

  void _goToLogin() {
    final loginRoute =
        _isStaff ? AppRoutes.staffLogin : AppRoutes.login;
    Navigator.pushReplacementNamed(context, loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Create ${_roleLabel()} Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(widget.role.icon,
                          color: AppTheme.brand, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join OrderSync',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.6))),
                          Text('as a ${_roleLabel()}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Demo notice
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 18,
                          color: scheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Demo sign-up — accounts are stored once Firebase is '
                          'connected in Phase 3.',
                          style: TextStyle(
                              fontSize: 12.5,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---- Role-specific (top) ----
                if (widget.role == UserRole.kitchen) ...[
                  _label('Kitchen / Restaurant name'),
                  TextFormField(
                    controller: _kitchenName,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Karahi House',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  _label('Branch area'),
                  DropdownButtonFormField<String>(
                    initialValue: _area,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.map_outlined)),
                    items: [
                      for (final a in _areas)
                        DropdownMenuItem(value: a, child: Text(a)),
                    ],
                    onChanged: (v) => setState(() => _area = v),
                    validator: (v) => v == null ? 'Select a branch area' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                if (widget.role == UserRole.rider) ...[
                  _label('Vehicle type'),
                  DropdownButtonFormField<String>(
                    initialValue: _vehicle,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.two_wheeler_outlined)),
                    items: [
                      for (final v in _vehicles)
                        DropdownMenuItem(value: v, child: Text(v)),
                    ],
                    onChanged: (v) => setState(() => _vehicle = v),
                    validator: (v) => v == null ? 'Select your vehicle' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('License plate'),
                  TextFormField(
                    controller: _plate,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'e.g. ABT-1234',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                ],

                // ---- Common fields ----
                _label('Full name'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Name is required';
                    if (t.length < 3) return 'Enter your full name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _label('Email'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$').hasMatch(t)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _label('Phone number'),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+92 3xx xxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.length < 11) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _label('Password'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _label('Confirm password'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').isEmpty) return 'Please confirm your password';
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Terms checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  title: Text(
                    'I agree to the OrderSync Terms of Service & Privacy Policy',
                    style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.8)),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _createAccount,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: TextStyle(
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6))),
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _roleLabel() => switch (widget.role) {
        UserRole.customer => 'Customer',
        UserRole.kitchen => 'Kitchen',
        UserRole.rider => 'Rider',
      };

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      );
}

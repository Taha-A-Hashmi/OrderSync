import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models.dart';
import '../widgets/common.dart';

/// Public customer login. On success it uses `pushReplacementNamed` to drop the
/// customer into their home and clear the auth stack. Staff (kitchen/rider) do
/// NOT log in here — that lives behind the unlisted `/staff` endpoint.
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ayesha@ordersync.pk');
  final _passwordController = TextEditingController(text: '123456');

  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    final session = UserSession(
      name: 'Ayesha Khan',
      email: _emailController.text.trim(),
      role: UserRole.customer,
    );
    Navigator.pushReplacementNamed(context, AppRoutes.customerHome,
        arguments: session);
  }

  void _backToLanding() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _backToLanding,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 820;
            final form = _buildForm(context);
            if (!isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    _brandHeader(context, compact: true),
                    const SizedBox(height: 26),
                    form,
                  ],
                ),
              );
            }
            return Row(
              children: [
                Expanded(child: _brandHeader(context)),
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 32),
                      child: form,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _brandHeader(BuildContext context, {bool compact = false}) {
    final panel = Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 24 : 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1207), Color(0xFF2A1A0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 24 : 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandMark(size: 46),
          SizedBox(height: compact ? 16 : 40),
          Text(
            'Welcome back to\nthe fastest food in town.',
            style: TextStyle(
              fontSize: compact ? 22 : 36,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sign in to reorder favourites and track deliveries live.',
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
    return compact ? panel : Center(child: panel);
  }

  Widget _buildForm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Sign In',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Order food and track your rider in real time',
              style:
                  TextStyle(color: scheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 26),

          const _FieldLabel('Email'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$').hasMatch(v)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          const _FieldLabel('Password'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: '••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Password is required';
              if ((value ?? '').length < 6) {
                return 'Must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Checkbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? false),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: () => _toast('Password reset arrives in Phase 3'),
                child: const Text('Forgot?'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.customerHome,
                  arguments: const UserSession(
                      name: 'Guest',
                      email: 'guest@ordersync.pk',
                      role: UserRole.customer)),
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Continue as guest'),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Don't have an account?",
                    style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.6))),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.signup),
                  child: const Text('Create one'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}

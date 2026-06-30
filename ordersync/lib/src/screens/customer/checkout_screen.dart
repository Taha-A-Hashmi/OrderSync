import 'package:flutter/material.dart';

import '../../cart_model.dart';
import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'processing_screen.dart';

/// Checkout — a validated Form gathering the delivery address (TextField),
/// area (Dropdown), schedule (Date & Time pickers), payment method (Radio),
/// contactless option (Switch) and rider tip (Slider).
class CheckoutScreen extends StatefulWidget {
  final CartModel cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController(text: '+92 ');
  final _promoController = TextEditingController();

  static const _areas = [
    'Supply Bazaar',
    'Jinnahabad',
    'Mandian',
    'PMA Road',
    'Kakul Road',
    'Nawan Shehr',
  ];

  String? _area;
  String _payment = 'cash';
  bool _asap = true;
  bool _contactless = false;
  double _tip = 50;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _scheduledTime = picked);
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    if (!_asap && (_scheduledDate == null || _scheduledTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please pick a delivery date and time')));
      return;
    }

    // Build the order object handed forward to the processing screen.
    final order = Order(
      id: 'OS-${1000 + widget.cart.count + DateTime.now().second}',
      customerName: 'Ayesha Khan',
      address: '${_addressController.text.trim()}, $_area, Abbottabad',
      items: widget.cart.items.map((e) => e.copy()).toList(),
      prepMinutes: 20,
      status: OrderStatus.placed,
    );

    widget.cart.clear();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProcessingScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // ---- Delivery address ----
            const SectionHeader('Delivery Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Street address',
                hintText: 'House / Flat, street, landmark',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Address is required';
                if (t.length < 8) return 'Please enter a more complete address';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ---- Area (Dropdown Button) ----
            DropdownButtonFormField<String>(
              initialValue: _area,
              decoration: const InputDecoration(
                labelText: 'Area',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: [
                for (final a in _areas)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setState(() => _area = v),
              validator: (v) => v == null ? 'Select your area' : null,
            ),
            const SizedBox(height: 14),

            // ---- Phone ----
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.length < 11) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 22),

            // ---- Schedule (Switch + Date/Time pickers) ----
            const SectionHeader('Delivery Time'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Deliver as soon as possible'),
              subtitle: const Text('Usually 25–35 min'),
              value: _asap,
              onChanged: (v) => setState(() => _asap = v),
            ),
            if (!_asap)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(
                        _scheduledDate == null
                            ? 'Pick date'
                            : '${_scheduledDate!.day}/${_scheduledDate!.month}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text(
                        _scheduledTime == null
                            ? 'Pick time'
                            : _scheduledTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // ---- Payment (Radio buttons) ----
            const SectionHeader('Payment Method'),
            const SizedBox(height: 4),
            RadioGroup<String>(
              groupValue: _payment,
              onChanged: (v) => setState(() => _payment = v ?? _payment),
              child: Column(
                children: [
                  _paymentTile(
                      'cash', 'Cash on Delivery', Icons.payments_outlined),
                  _paymentTile(
                      'card', 'Credit / Debit Card', Icons.credit_card),
                  _paymentTile('wallet', 'OrderSync Wallet',
                      Icons.account_balance_wallet),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Tip (Slider) ----
            Row(
              children: [
                const Text('Tip your rider',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                StatusBadge(label: rs(_tip), color: AppTheme.brand),
              ],
            ),
            Slider(
              value: _tip,
              min: 0,
              max: 300,
              divisions: 6,
              label: rs(_tip),
              onChanged: (v) => setState(() => _tip = v),
            ),

            // ---- Contactless (Switch) ----
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Contactless delivery'),
              subtitle: const Text('Leave the order at my door'),
              value: _contactless,
              onChanged: (v) => setState(() => _contactless = v),
            ),
            const SizedBox(height: 8),

            // ---- Promo ----
            TextField(
              controller: _promoController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Promo code',
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Promo codes arrive in Phase 3')));
                  },
                  child: const Text('Apply'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---- Summary card ----
            Card(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _summaryLine('Items (${widget.cart.count})',
                        rs(widget.cart.subtotal)),
                    _summaryLine('Delivery', rs(widget.cart.deliveryFee)),
                    _summaryLine('Tax', rs(widget.cart.tax)),
                    _summaryLine('Rider tip', rs(_tip)),
                    const Divider(height: 18),
                    _summaryLine(
                        'Grand Total', rs(widget.cart.total + _tip),
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.lock_outline_rounded),
                label: Text('Place Order · ${rs(widget.cart.total + _tip)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String value, String label, IconData icon) {
    final selected = _payment == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.brand.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected ? AppTheme.brand : Colors.transparent, width: 1.4),
      ),
      child: RadioListTile<String>(
        value: value,
        secondary: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

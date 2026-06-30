import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Opens the customisation Bottom Sheet for [dish] and returns the configured
/// [CartItem] (or null if dismissed) — i.e. data returned from the sheet.
Future<CartItem?> showDishCustomizer(BuildContext context, Dish dish,
    {CartItem? existing}) {
  return showModalBottomSheet<CartItem>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
        child: DishCustomizerBody(
          dish: dish,
          initial: existing,
          submitLabel: existing == null ? 'Add to Cart' : 'Update Item',
          onSubmit: (item) => Navigator.pop(ctx, item),
        ),
      ),
    ),
  );
}

/// Full-screen editor pushed from the cart. Receives a [CartItem] as a route
/// argument (data passed forward) and pops the updated item (data returned
/// backward) so the cart can instantly recalculate the bill.
class DishCustomizerScreen extends StatelessWidget {
  final CartItem item;
  const DishCustomizerScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: DishCustomizerBody(
        dish: item.dish,
        initial: item,
        submitLabel: 'Save Changes',
        onSubmit: (updated) => Navigator.pop(context, updated),
      ),
    );
  }
}

/// Shared customiser UI. Demonstrates Slider (spice), Radio (size),
/// Checkboxes (add-ons), a quantity stepper and a notes TextField.
class DishCustomizerBody extends StatefulWidget {
  final Dish dish;
  final CartItem? initial;
  final String submitLabel;
  final ValueChanged<CartItem> onSubmit;

  const DishCustomizerBody({
    super.key,
    required this.dish,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
  });

  @override
  State<DishCustomizerBody> createState() => _DishCustomizerBodyState();
}

class _DishCustomizerBodyState extends State<DishCustomizerBody> {
  late CartItem _draft;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.initial?.copy() ?? CartItem(dish: widget.dish);
    _notesController.text = _draft.notes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool _isSelected(AddOn addOn) =>
      _draft.selectedAddOns.any((a) => a.name == addOn.name);

  void _toggleAddOn(AddOn addOn, bool selected) {
    setState(() {
      if (selected) {
        _draft.selectedAddOns.add(addOn);
      } else {
        _draft.selectedAddOns.removeWhere((a) => a.name == addOn.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Hero ----
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: DishImage(dish: widget.dish, height: 150),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              child: StatusBadge(
                label: widget.dish.isVeg ? 'VEG' : 'NON-VEG',
                color: widget.dish.isVeg
                    ? StatusColors.ready
                    : StatusColors.offline,
                icon: Icons.circle,
              ),
            ),
          ],
        ),
        // ---- Options ----
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.dish.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                    Text(rs(widget.dish.price),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brand)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.brandAlt, size: 18),
                    const SizedBox(width: 3),
                    Text('${widget.dish.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.dish.description,
                          style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13)),
                    ),
                  ],
                ),
                const Divider(height: 28),

                // ---- Spice level (Slider) ----
                Row(
                  children: [
                    const Text('🌶️ Spice Level',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    StatusBadge(
                        label: _draft.spiceLabel, color: AppTheme.brand),
                  ],
                ),
                Slider(
                  value: _draft.spiceLevel,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: _draft.spiceLabel,
                  onChanged: (v) => setState(() => _draft.spiceLevel = v),
                ),
                const SizedBox(height: 4),

                // ---- Size (Radio buttons) ----
                const Text('Portion Size',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                RadioGroup<String>(
                  groupValue: _draft.size,
                  onChanged: (v) =>
                      setState(() => _draft.size = v ?? _draft.size),
                  child: Row(
                    children: [
                      Expanded(child: _sizeOption('Regular', '+ Rs 0')),
                      const SizedBox(width: 10),
                      Expanded(child: _sizeOption('Large', '+ Rs 200')),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ---- Add-ons (Checkboxes) ----
                const Text('Add-ons',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                ...widget.dish.addOns.map((addOn) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      value: _isSelected(addOn),
                      onChanged: (v) => _toggleAddOn(addOn, v ?? false),
                      title: Text(addOn.name),
                      secondary: Text(
                        addOn.price == 0 ? 'Free' : '+ ${rs(addOn.price)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )),
                const SizedBox(height: 12),

                // ---- Notes (TextField) ----
                const Text('Special Instructions',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    hintText: 'e.g. less oil, extra lemon...',
                  ),
                  onChanged: (v) => _draft.notes = v,
                ),
                const SizedBox(height: 4),

                // ---- Quantity ----
                Row(
                  children: [
                    const Text('Quantity',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    QuantityStepper(
                      quantity: _draft.quantity,
                      onChanged: (q) =>
                          setState(() => _draft.quantity = q.clamp(1, 20)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ---- Submit bar ----
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
                top: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.4))),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total',
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.6))),
                  Text(rs(_draft.total),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _draft.notes = _notesController.text;
                    widget.onSubmit(_draft);
                  },
                  child: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sizeOption(String value, String hint) {
    final selected = _draft.size == value;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _draft.size = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.brand.withValues(alpha: 0.12)
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppTheme.brand : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            // Radio button (required widget) — managed by the RadioGroup above.
            Radio<String>(value: value),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(hint,
                      style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'theme.dart';

/// The three role-based ecosystems described in the OrderSync proposal.
enum UserRole { customer, kitchen, rider }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.customer => 'Customer',
        UserRole.kitchen => 'Kitchen / Dispatch',
        UserRole.rider => 'Delivery Rider',
      };

  String get blurb => switch (this) {
        UserRole.customer => 'Order food & track your rider live',
        UserRole.kitchen => 'Manage the order queue & dispatch riders',
        UserRole.rider => 'Pick up missions & deliver across Abbottabad',
      };

  IconData get icon => switch (this) {
        UserRole.customer => Icons.restaurant_menu_rounded,
        UserRole.kitchen => Icons.soup_kitchen_rounded,
        UserRole.rider => Icons.delivery_dining_rounded,
      };

  /// Named route this role is dropped into after authentication (Phase 2).
  String get route => switch (this) {
        UserRole.customer => '/customer_home',
        UserRole.kitchen => '/kitchen_dash',
        UserRole.rider => '/rider_dash',
      };
}

/// Lightweight session object handed forward through the named routes on login.
class UserSession {
  final String name;
  final String email;
  final UserRole role;
  const UserSession(
      {required this.name, required this.email, required this.role});
}

/// An optional extra a customer can add to a dish.
class AddOn {
  final String name;
  final double price;
  const AddOn(this.name, this.price);
}

/// A menu item shown in the customer GridView.
class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String emoji;
  final Color tint;
  final String imageUrl;
  final bool isVeg;
  final double rating;
  final List<AddOn> addOns;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.emoji,
    required this.tint,
    required this.imageUrl,
    this.isVeg = false,
    this.rating = 4.5,
    this.addOns = const [],
  });
}

/// The "complex data object" the proposal passes forward to the cart and
/// returns backward when edited: dish + spice + add-ons + size + quantity.
class CartItem {
  final Dish dish;
  int quantity;
  double spiceLevel; // 0..4 (Slider)
  String size; // Regular / Large (Radio)
  final List<AddOn> selectedAddOns; // Checkboxes
  String notes;

  CartItem({
    required this.dish,
    this.quantity = 1,
    this.spiceLevel = 2,
    this.size = 'Regular',
    List<AddOn>? selectedAddOns,
    this.notes = '',
  }) : selectedAddOns = selectedAddOns ?? <AddOn>[];

  static const List<String> spiceLabels = [
    'No Spice',
    'Mild',
    'Medium',
    'Hot',
    'Extra Hot',
  ];

  String get spiceLabel => spiceLabels[spiceLevel.round().clamp(0, 4)];
  double get addOnTotal =>
      selectedAddOns.fold(0.0, (sum, a) => sum + a.price);
  double get sizeSurcharge => size == 'Large' ? 200 : 0;
  double get unitPrice => dish.price + addOnTotal + sizeSurcharge;
  double get total => unitPrice * quantity;

  /// Deep copy so the editor can mutate a draft without touching the cart copy
  /// until the user confirms (supports "return data backward" semantics).
  CartItem copy() => CartItem(
        dish: dish,
        quantity: quantity,
        spiceLevel: spiceLevel,
        size: size,
        selectedAddOns: List<AddOn>.of(selectedAddOns),
        notes: notes,
      );
}

/// Lifecycle of an order as it moves kitchen -> rider -> customer.
enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  assigned,
  pickedUp,
  arrived,
  delivered,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.placed => 'New Order',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.ready => 'Ready to Dispatch',
        OrderStatus.assigned => 'Rider Assigned',
        OrderStatus.pickedUp => 'Picked Up',
        OrderStatus.arrived => 'Arrived',
        OrderStatus.delivered => 'Delivered',
      };

  Color get color => switch (this) {
        OrderStatus.placed => StatusColors.newOrder,
        OrderStatus.accepted => StatusColors.accepted,
        OrderStatus.preparing => StatusColors.preparing,
        OrderStatus.ready => StatusColors.ready,
        OrderStatus.assigned => StatusColors.assigned,
        OrderStatus.pickedUp => StatusColors.enRoute,
        OrderStatus.arrived => StatusColors.enRoute,
        OrderStatus.delivered => StatusColors.delivered,
      };
}

/// A delivery rider in the local fleet.
class Rider {
  final String id;
  final String name;
  final String vehicle;
  final String plate;
  final String phone;
  final double rating;
  bool online;

  Rider({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.plate,
    required this.phone,
    this.rating = 4.7,
    this.online = true,
  });
}

/// An order ticket shared by the kitchen queue, the rider mission and the
/// customer tracking screen.
class Order {
  final String id;
  final String customerName;
  final String address;
  final List<CartItem> items;
  final int prepMinutes;
  OrderStatus status;
  Rider? assignedRider;

  Order({
    required this.id,
    required this.customerName,
    required this.address,
    required this.items,
    this.prepMinutes = 20,
    this.status = OrderStatus.placed,
    this.assignedRider,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);
}

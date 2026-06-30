import 'package:flutter/material.dart';
import 'models.dart';

/// Static demo content for the Phase 1 / Phase 2 UI build. (Live data arrives
/// in Phase 3 via Cloud Firestore.)
class SampleData {
  SampleData._();

  static const List<String> categories = [
    'Karahi & BBQ',
    'Fast Food',
    'Desi Special',
    'Beverages',
  ];

  static const List<AddOn> _desiAddOns = [
    AddOn('Extra Naan', 60),
    AddOn('Raita', 80),
    AddOn('Salad', 50),
    AddOn('Extra Gravy', 120),
  ];

  static const List<AddOn> _fastFoodAddOns = [
    AddOn('Extra Cheese', 120),
    AddOn('Fries', 180),
    AddOn('Garlic Dip', 60),
    AddOn('Jalapeños', 70),
  ];

  static const List<AddOn> _drinkAddOns = [
    AddOn('Extra Ice', 0),
    AddOn('Lemon Shot', 40),
  ];

  static const List<Dish> menu = [
    // ---- Karahi & BBQ ----
    Dish(
      id: 'd1',
      name: 'Chicken Karahi',
      description: 'Signature wok-tossed chicken in tomato & green chilli gravy.',
      price: 1450,
      category: 'Karahi & BBQ',
      emoji: '🍲',
      tint: Color(0xFFE2562B),
      imageUrl:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=80',
      rating: 4.8,
      addOns: _desiAddOns,
    ),
    Dish(
      id: 'd2',
      name: 'Seekh Kebab',
      description: 'Char-grilled minced beef skewers with smoky spices.',
      price: 850,
      category: 'Karahi & BBQ',
      emoji: '🍢',
      tint: Color(0xFFB91C1C),
      imageUrl:
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80',
      rating: 4.6,
      addOns: _desiAddOns,
    ),
    Dish(
      id: 'd3',
      name: 'Malai Boti',
      description: 'Creamy marinated chicken cubes grilled to perfection.',
      price: 980,
      category: 'Karahi & BBQ',
      emoji: '🍗',
      tint: Color(0xFFD97706),
      imageUrl:
          'https://images.unsplash.com/photo-1610057099431-d73a1c9d2f2f?w=600&q=80',
      rating: 4.7,
      addOns: _desiAddOns,
    ),
    // ---- Fast Food ----
    Dish(
      id: 'd4',
      name: 'Zinger Burger',
      description: 'Crispy fried chicken fillet, lettuce & signature mayo.',
      price: 620,
      category: 'Fast Food',
      emoji: '🍔',
      tint: Color(0xFFCA8A04),
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80',
      rating: 4.5,
      addOns: _fastFoodAddOns,
    ),
    Dish(
      id: 'd5',
      name: 'Loaded Fries',
      description: 'Fries smothered in cheese sauce, jalapeños & herbs.',
      price: 480,
      category: 'Fast Food',
      emoji: '🍟',
      tint: Color(0xFFEAB308),
      imageUrl:
          'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
      isVeg: true,
      rating: 4.4,
      addOns: _fastFoodAddOns,
    ),
    Dish(
      id: 'd6',
      name: 'Pepperoni Pizza',
      description: 'Stone-baked pizza with a generous pepperoni layer.',
      price: 1250,
      category: 'Fast Food',
      emoji: '🍕',
      tint: Color(0xFFDC2626),
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80',
      rating: 4.6,
      addOns: _fastFoodAddOns,
    ),
    // ---- Desi Special ----
    Dish(
      id: 'd7',
      name: 'Chicken Biryani',
      description: 'Fragrant basmati layered with spiced chicken & saffron.',
      price: 720,
      category: 'Desi Special',
      emoji: '🍛',
      tint: Color(0xFFEA580C),
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80',
      rating: 4.9,
      addOns: _desiAddOns,
    ),
    Dish(
      id: 'd8',
      name: 'Kari Pakora',
      description: 'Yogurt curry with soft gram-flour pakoras — house favourite.',
      price: 540,
      category: 'Desi Special',
      emoji: '🥘',
      tint: Color(0xFFCA8A04),
      imageUrl:
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&q=80',
      isVeg: true,
      rating: 4.5,
      addOns: _desiAddOns,
    ),
    Dish(
      id: 'd9',
      name: 'Nihari',
      description: 'Slow-cooked beef shank stew with bone marrow richness.',
      price: 890,
      category: 'Desi Special',
      emoji: '🍜',
      tint: Color(0xFF9A3412),
      imageUrl:
          'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600&q=80',
      rating: 4.7,
      addOns: _desiAddOns,
    ),
    // ---- Beverages ----
    Dish(
      id: 'd10',
      name: 'Kashmiri Chai',
      description: 'Pink tea topped with crushed pistachios & almonds.',
      price: 220,
      category: 'Beverages',
      emoji: '🫖',
      tint: Color(0xFFDB2777),
      imageUrl:
          'https://images.unsplash.com/photo-1597481499750-3e6b22637e12?w=600&q=80',
      isVeg: true,
      rating: 4.6,
      addOns: _drinkAddOns,
    ),
    Dish(
      id: 'd11',
      name: 'Mint Margarita',
      description: 'Chilled lemon-mint cooler — refreshing & fizzy.',
      price: 280,
      category: 'Beverages',
      emoji: '🥤',
      tint: Color(0xFF16A34A),
      imageUrl:
          'https://images.unsplash.com/photo-1497534446932-c925b458314a?w=600&q=80',
      isVeg: true,
      rating: 4.5,
      addOns: _drinkAddOns,
    ),
    Dish(
      id: 'd12',
      name: 'Mango Lassi',
      description: 'Thick, sweet yogurt smoothie blended with ripe mango.',
      price: 320,
      category: 'Beverages',
      emoji: '🥭',
      tint: Color(0xFFF59E0B),
      imageUrl:
          'https://images.unsplash.com/photo-1571805618149-0a37e0c5d4f6?w=600&q=80',
      isVeg: true,
      rating: 4.7,
      addOns: _drinkAddOns,
    ),
  ];

  static List<Dish> byCategory(String category) =>
      menu.where((d) => d.category == category).toList();

  // ---- Fleet -----------------------------------------------------------------
  static List<Rider> riders() => [
        Rider(
          id: 'r1',
          name: 'Bilal Ahmed',
          vehicle: 'Honda CD 70',
          plate: 'ABT-4421',
          phone: '+92 312 1234567',
          rating: 4.9,
        ),
        Rider(
          id: 'r2',
          name: 'Usman Tariq',
          vehicle: 'Suzuki GD 110',
          plate: 'ABT-7782',
          phone: '+92 333 7654321',
          rating: 4.6,
        ),
        Rider(
          id: 'r3',
          name: 'Hamza Noor',
          vehicle: 'Yamaha YBR',
          plate: 'ABT-9090',
          phone: '+92 301 5557788',
          rating: 4.8,
          online: false,
        ),
      ];

  // ---- Kitchen queue seed ----------------------------------------------------
  static List<Order> kitchenTickets() => [
        Order(
          id: 'OS-1042',
          customerName: 'Ayesha Khan',
          address: 'House 12, Street 4, Supply Bazaar, Abbottabad',
          prepMinutes: 18,
          status: OrderStatus.placed,
          items: [
            CartItem(
                dish: menu[0], quantity: 1, spiceLevel: 3, size: 'Large'),
            CartItem(dish: menu[9], quantity: 2),
          ],
        ),
        Order(
          id: 'OS-1043',
          customerName: 'Hassan Raza',
          address: 'Flat 7B, Jinnahabad, Abbottabad',
          prepMinutes: 12,
          status: OrderStatus.preparing,
          items: [
            CartItem(dish: menu[3], quantity: 2),
            CartItem(dish: menu[4], quantity: 1),
          ],
        ),
        Order(
          id: 'OS-1044',
          customerName: 'Fatima Sheikh',
          address: 'House 88, Mandian, Abbottabad',
          prepMinutes: 25,
          status: OrderStatus.accepted,
          items: [
            CartItem(dish: menu[6], quantity: 3, spiceLevel: 2),
          ],
        ),
      ];
}

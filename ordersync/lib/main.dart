import 'package:flutter/material.dart';

import 'src/app_routes.dart';
import 'src/theme.dart';

void main() {
  runApp(const OrderSyncApp());
}

/// Root of the OrderSync ecosystem. Owns the app-wide [ThemeMode] so the
/// Light/Dark switch in the customer profile can flip the whole app, and wires
/// up the Phase 2 named-route table.
class OrderSyncApp extends StatefulWidget {
  const OrderSyncApp({super.key});

  static OrderSyncAppState of(BuildContext context) =>
      context.findAncestorStateOfType<OrderSyncAppState>()!;

  @override
  State<OrderSyncApp> createState() => OrderSyncAppState();
}

class OrderSyncAppState extends State<OrderSyncApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setDarkMode(bool dark) {
    setState(() => _themeMode = dark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      initialRoute: AppRoutes.landing,
      routes: AppRoutes.table,
    );
  }
}

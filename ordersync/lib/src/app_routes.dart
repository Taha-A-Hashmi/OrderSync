import 'package:flutter/material.dart';
import 'models.dart';
import 'screens/landing_page.dart';
import 'screens/customer_login_screen.dart';
import 'screens/staff_login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/kitchen/kitchen_dashboard.dart';
import 'screens/rider/rider_dashboard.dart';

/// Phase 2 — routing architecture.
///
/// Public surface: the landing page, the customer login and the customer
/// sign-up. The Kitchen and Rider consoles (login + sign-up) sit behind a
/// single, unlisted [staffLogin] endpoint — linked from the landing page's
/// "Staff & Admin" entry so admins can find it, but never surfaced in the
/// customer flow.
class AppRoutes {
  AppRoutes._();

  static const String landing = '/'; // public landing page (entry point)
  static const String login = '/login'; // customer login (public)
  static const String signup = '/signup'; // customer sign-up (public)
  static const String staffLogin = '/staff'; // kitchen/rider endpoint
  static const String kitchenSignup = '/staff/kitchen-signup';
  static const String riderSignup = '/staff/rider-signup';

  static const String customerHome = '/customer_home';
  static const String kitchenDash = '/kitchen_dash';
  static const String riderDash = '/rider_dash';

  static Map<String, WidgetBuilder> get table => {
        landing: (_) => const LandingPage(),
        login: (_) => const CustomerLoginScreen(),
        signup: (_) => const SignupScreen(role: UserRole.customer),
        staffLogin: (_) => const StaffLoginScreen(),
        kitchenSignup: (_) => const SignupScreen(role: UserRole.kitchen),
        riderSignup: (_) => const SignupScreen(role: UserRole.rider),
        customerHome: (_) => const CustomerShell(),
        kitchenDash: (_) => const KitchenDashboard(),
        riderDash: (_) => const RiderDashboard(),
      };
}

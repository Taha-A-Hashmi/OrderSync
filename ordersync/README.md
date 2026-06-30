# OrderSync — Phase 1 & Phase 2

A real-time, cross-platform food-delivery ecosystem for high-traffic local
kitchens, built with **Flutter**. This repository covers **Phase 1 (Flutter
Frontend / UI)** and **Phase 2 (Navigation & Application Flow)** of the Mobile
Application Development course project.

> Firebase backend (Phase 3) and native device services / Google Maps & GPS
> (Phase 4) are intentionally **not** included yet — the live map is a
> self-contained `CustomPaint` mock and "call rider" is stubbed, so the app runs
> fully offline on any platform.

## Run it

```bash
cd ordersync
flutter pub get
flutter run -d chrome      # or: flutter run -d windows
```

## The three portals

| Portal | Entry | Highlights |
| --- | --- | --- |
| **Customer** | Landing → "Order Now" → customer login | Menu (tabs + grid), dish customiser bottom sheet, cart, checkout, live tracking |
| **Kitchen / Dispatch** | Hidden `/staff` endpoint | Landscape ticket queue, prep-time progress, status buttons, assign-rider dialog |
| **Rider** | Hidden `/staff` endpoint | Online/Offline switch, mission card, full-screen active-delivery flow |

## Authentication & routing (Phase 2)

The app opens on a **public landing page**. From there:

- **Customers** tap *Order Now / Sign in* → `/login` (public customer login),
  with *Create one* → `/signup` (customer sign-up).
- **Staff (Kitchen & Rider)** share one `/staff` endpoint, reached from the
  **"Staff" button in the landing top bar** or the **"Staff & Admin Portal"**
  button in the footer. It is gated by admin credentials and lets the admin
  choose the Kitchen or Rider console, log in, or onboard a new kitchen/rider
  account.

### Sign-up (UI only)

A single role-aware `SignupScreen` provides dummy account creation for all three
user types (customer / kitchen / rider) with full form validation and
role-specific fields (kitchen name & area; vehicle & plate). No data is
persisted yet — real registration lands in Phase 3 (Firebase Auth). On submit it
validates and drops the new user into their portal.

### Demo credentials

| Login | Email | Password |
| --- | --- | --- |
| Staff console (`/staff`) | `taha@ordersync.com` | `admin` |
| Customer (`/login`) | prefilled demo (any valid email + 6+ char password) | |

## Project structure

```
lib/
├── main.dart                     # MaterialApp, theme mode, route table
└── src/
    ├── app_routes.dart           # named routes (landing, /login, /staff, dashboards)
    ├── theme.dart                # dark-charcoal theme + vibrant status accents
    ├── models.dart               # Dish, CartItem, Order, Rider, UserSession, enums
    ├── sample_data.dart          # demo menu, fleet, kitchen tickets
    ├── cart_model.dart           # ChangeNotifier cart + InheritedNotifier scope
    ├── widgets/
    │   ├── mock_map.dart         # animated CustomPaint "map" (placeholder for Phase 4)
    │   └── common.dart           # DishImage, StatusBadge, BrandMark, QuantityStepper…
    └── screens/
        ├── landing_page.dart
        ├── customer_login_screen.dart
        ├── staff_login_screen.dart      # hidden kitchen/rider endpoint
        ├── customer/  (shell, menu, customiser, cart, checkout, processing, tracking, orders, profile)
        ├── kitchen/   (dashboard)
        └── rider/     (dashboard, active_delivery)
```

## Requirement coverage

**Phase 1 widgets** — Stateless/Stateful, MaterialApp, Scaffold, AppBar,
Container, Row/Column, Stack, ListView, GridView, Card, Text, Image, Icons,
Buttons (Elevated / Outlined / Text / Icon), TextField + Form validation, Radio
(`RadioGroup`), Checkboxes, Switches, Dropdown, Date & Time pickers, Slider,
Progress indicators (linear & circular), Dialogs, Snackbars, Bottom sheet,
Drawer, Bottom navigation bar, Tab bar, Floating action button, and responsive
layout via `MediaQuery` / `LayoutBuilder` / `Expanded` / `Flexible`.

**Phase 2 navigation** — Named routes, `push`, `pop`, `pushReplacement`, passing
data forward (dish → cart → checkout) and returning data backward (edit cart
item recalculates the bill), bottom-navigation, drawer navigation and tab
navigation.

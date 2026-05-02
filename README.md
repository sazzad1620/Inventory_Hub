# Inventory Hub (Flutter)

Inventory Hub is a small **inventory management app** built with Flutter.

The main goal of this project is learning: it demonstrates how to build a beginner-friendly app with an **industry-style architecture foundation** using:

- Clean Architecture (feature-first)
- BLoC state management
- Drift (SQLite) local database

## Purpose

This project is created mainly for learning how real-world app architecture is organized without adding too many features.

It helps you practice:

- separating layers clearly (`presentation -> domain -> data`)
- managing state with BLoC
- handling local persistence with Drift
- wiring dependencies with `get_it`
- writing maintainable and testable code

## Features

- Authentication flow: sign up, sign in, sign out
- Product inventory CRUD: add, update, delete, list
- Optional product categories (example: Grocery, Electronics) with reusable category dropdown in product form
- Stock unit selection per product (default `Unit`, with options like `KG`, `Liter`, etc.)
- Search on product list (name/category/ID) and quick category filter chips for faster finding
- Bangla/English language toggle
- Local session persistence

## Architecture Overview

Flow used in this project:

`UI -> BLoC -> UseCase -> Repository -> LocalDataSource -> Drift DB`

Project modules:

- `lib/core/` - shared infrastructure (database, DI, theme, localization, utilities)
- `lib/features/auth/` - auth feature in clean layers
- `lib/features/product/` - product feature in clean layers
- `ARCHITECTURE.md` - detailed architecture explanation and conventions

## Getting Started

1. Install dependencies:
   - `flutter pub get`
2. Generate Drift/build files:
   - `dart run build_runner build --delete-conflicting-outputs`
3. Run the app:
   - `flutter run`

## App icon and splash (branding)

The launcher icon, Android/iOS native splash, and in-app logo all use **`assets/branding/app_logo.png`** (high-resolution mark suitable for mipmap/splash scaling).

The mark is **three isometric boxes in a 2+1 pyramid** (two on the bottom, one centered on top) so the silhouette fits **circular and square crops** without clipping the sides. Normalization uses **~80%** max scale inside `1024×1024` to leave margin for Android 12’s circular splash.

After replacing that file, regenerate platform assets:

- `dart run tool/normalize_brand_logo.dart assets/branding/_logo_source.png assets/branding/app_logo.png` (square, uniform scale, `#0A0A0A` fill — avoids stretched or off-aspect launcher/splash)
- `dart run flutter_launcher_icons`
- `dart run flutter_native_splash:create`

**Android splash note:** `launch_background.xml` uses a **solid color** layer instead of stretching a bitmap fill (avoids subtle vertical distortion on some devices). If you re-run `flutter_native_splash:create` and the splash looks wrong, restore that pattern: bottom layer `shape` + `#0A0A0A`, top layer centered `@drawable/splash`.

The login screen uses the shared `AppLogo` widget (`lib/core/widgets/app_logo.dart`) so it stays aligned with the same asset.

**Do not** ship PNGs that show a grey/white checkerboard — that is not real transparency; use an opaque background or a proper alpha channel.

## Learning Scope

This is intentionally a **small app with strong fundamentals**.

It is not meant to be a full production product yet (for example: no remote API, no advanced observability, limited test depth), but it is a solid base for learning industry-level architecture patterns step by step.

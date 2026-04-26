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
- Search on product list
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

## Learning Scope

This is intentionally a **small app with strong fundamentals**.

It is not meant to be a full production product yet (for example: no remote API, no advanced observability, limited test depth), but it is a solid base for learning industry-level architecture patterns step by step.

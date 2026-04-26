# Inventory Management App (Flutter)

Production-style Flutter mobile app (Android + iOS) built from your provided design reference.

## What Was Built

- Full authentication flow: sign up, sign in, sign out
- Inventory home dashboard with search
- Add product screen
- Edit product screen (with delete)
- Bangla/English language toggle
- Local persistent database using Drift for:
  - users
  - session/login state
  - products
- BLoC state management with feature-first clean architecture layout

## Project Structure

- `design_guide/` → preserved original design project (reference source)
- `lib/core/` → shared theme, localization, and Drift database
- `lib/features/auth/` → auth domain/data/presentation with BLoC
- `lib/features/product/` → product domain/data/presentation with BLoC
- `ARCHITECTURE.md` → learning-friendly architecture guide and AI prompt

## Run The App

1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs`
3. `flutter run`

## Notes

- Data is stored locally on-device via SQLite (Drift).
- The app starts at login/signup, then navigates to home after auth.
- UI style follows your dark emerald grocery design direction from the source files.

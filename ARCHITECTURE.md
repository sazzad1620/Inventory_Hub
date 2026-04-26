# App Architecture Guide

This document explains the current architecture in simple language.
You can also paste this into an AI chat as a project prompt.

## Architecture Goal

This app follows a learning-focused version of:

- Clean Architecture (feature-first)
- BLoC for state management
- Drift (SQLite) for local storage

The flow is:

`UI -> BLoC -> UseCase -> Repository -> LocalDataSource -> Drift DB`

## Folder Structure

- `lib/core/`
  - Shared cross-feature code (theme, localization, database, error/result models)
- `lib/features/auth/`
  - `presentation/` -> pages + bloc
  - `domain/` -> entities, repository contracts, usecases
  - `data/` -> repository implementation + local datasource
- `lib/features/product/`
  - same layered structure as auth

## Layer Responsibilities

### 1) Presentation (`presentation`)

- Widgets/pages render UI.
- BLoCs receive events and emit UI states.
- Presentation must not run SQL queries directly.
- Keep feature boundaries clear: a feature page should not directly import another feature's BLoC.
- If cross-feature action is needed (for example sign-out from home), pass a callback from app/root composition.

Non-negotiable dependency rule:

- `UI -> BLoC -> UseCase -> Repository(abstract in domain) -> RepositoryImpl(data) -> LocalDataSource -> Drift`
- `presentation` must never import `data`.
- `domain` must never import `drift` or Flutter UI packages.

### 2) Domain (`domain`)

- Pure app rules and contracts.
- `entities`: clean models used by business logic.
- `repositories`: abstract contracts.
- `usecases`: one action per class (sign in, add product, etc).

### 3) Data (`data`)

- Concrete repository implementations.
- Datasources that talk to Drift tables and queries.
- Mapping data rows into domain entities.

### 4) Core (`core`)

- Shared technical infrastructure.
- App-wide utilities and common result/failure wrappers.
- Includes DI setup and password hashing helpers.

## Why use UseCases?

UseCases make each user action explicit and testable.
Example: `SignInUseCase`, `GetProductsUseCase`, `UpdateProductUseCase`.

This keeps BLoC smaller and helps when business rules grow later.

## Why use LocalDataSource?

Repository should not know SQL details.
Datasource isolates Drift-specific code and keeps data access in one place.

## Drift Foundation (Learning + Industry Baseline)

To keep the project beginner-friendly but industry-safe, this app now keeps only 3 core DB rules:

- `schemaVersion` is versioned and includes a real migration strategy.
- `Session.userId` has a foreign-key relation to `Users.id` with safe delete behavior.
- `Products.userId` scopes product records to the currently signed-in user.
- Multi-step auth signup write (create user + create session) is atomic through one transaction.
- Product prices are stored as integer cents in DB to avoid floating-point money issues.

These three give you strong fundamentals without adding advanced complexity.

## Error Handling Style

This project uses one small `Result<T>` model (single standard):

- `Success<T>(data)`
- `FailureResult<T>(message, code?)`

That keeps errors explicit across layers and easier to teach compared to hidden throws.
To keep learning simple, do not mix this with a second failure abstraction in parallel.

Minimal convention used in this project:

- Use-cases return stable error codes (example: `signin_failed`, `products_load_failed`).
- BLoCs pass those codes to UI state instead of raw exception text.
- UI maps known codes to localized labels (for example `invalid_credentials`).
- Sign-in now returns explicit failures for invalid credentials (`invalid_credentials`) instead of `Success(null)` to keep success/failure semantics consistent.
- Product loading uses explicit states: `initial`, `loading`, `loaded`, `failure`.
- Sign-out path is also checked through `Result<void>` so BLoC can keep session state consistent when a failure occurs.
- Auth state now supports explicit user clearing on sign-out (`clearUser`) so logout cannot keep stale user state.
- Auth signup no longer throws a manual repository exception for null user reads; datasource returns a concrete inserted row and use-case remains the single error-mapping boundary.
- Product mutations now refresh list state directly inside the same BLoC flow (no extra re-dispatch event cycle), which keeps behavior clear for learning and cleaner for scale.
- Product mutation failures now set explicit `failure` status, and successful reload clears old errors for consistent UI behavior.
- Product update/delete now check affected row count and fail when no row is changed, avoiding false-success mutation flows.
- Auth page controllers are now explicitly disposed to keep StatefulWidget lifecycle practices correct for beginners and production habits.
- Product list page now renders clear loading/failure UI from `ProductStatus`, so BLoC state meanings stay visible in the UI layer.
- Sign-out now resets `ProductBloc` state before clearing auth session, so user-scoped list data cannot leak across account switches in-memory.
- Validation and generic operation-failure labels are now localized in both auth and product forms to keep beginner flow simple and language behavior consistent.

Stable code convention (recommended):

- Auth: `session_read_failed`, `signin_failed`, `signup_failed`, `signout_failed`, `invalid_credentials`
- Product: `products_load_failed`, `product_add_failed`, `product_update_failed`, `product_delete_failed`

## DI (Dependency Injection) Style

DI now uses `get_it` in `lib/core/di/injection.dart`.

`app.dart` only calls `configureDependencies()` and reads objects from DI.
This keeps startup code small and makes future features easier to wire.

## Password Security (simple but useful)

- Password is hashed before storing in local database.
- Stored format is `salt:hash`.
- Login verifies hash instead of comparing plain text.

This is intentionally minimal for learning and avoids complex auth packages.
It is good for architecture learning, but should not be treated as production-grade password security.

## Start Learning Now (Minimal Start Gate)

Before entering deep refactors, pass this quick gate:

- Keep `flutter analyze` green.
- Keep `flutter test` green.
- Trace auth flow once on paper:
  - Login tap -> `AuthBloc` event -> usecase -> repository -> datasource -> Drift -> state -> UI
- Trace product flow once on paper:
  - Add product -> `ProductBloc` -> usecase -> repository -> datasource -> Drift -> list refresh

If all four are done, start learning immediately with this app as-is.

Additional one-time check after DB schema edits:

- If Drift generated code is outdated, run build runner once, then re-run `flutter analyze` and `flutter test`.

## Testing Baseline

The project now has a starter test baseline:

- One domain use-case unit test
- One BLoC state transition test
- Auth sign-in use-case now covers success, invalid credentials, and unexpected failure mapping

Use these as templates to add tests feature-by-feature.

Minimum target before expanding features:

- Auth use-case tests (success + invalid credentials path)
- Auth BLoC tests (loading/success/failure transitions)
- Product BLoC tests for both success and failure paths
- Keep `flutter analyze` + `flutter test` green before each refactor

## What Is Still Not Fully Production-Grade?

- No full test suite yet (unit + bloc + widget + integration).
- No remote API layer/caching/sync strategy yet.

## Learning-Grade vs Production-Grade (Important)

Learning-grade in this app (good and intentional):

- Small feature scope (auth + product CRUD) to focus on architecture discipline.
- Simple `Result<T>` error handling and stable error codes.
- Local-only data flow through Drift with clear datasource boundaries.

Not yet production-grade (expected at this stage):

- Testing depth is still baseline, not full confidence coverage.
- Failure typing/logging/observability are minimal.
- No remote sync, offline conflict strategy, or API boundary yet.
- Password handling is educational, not enterprise security.
- No encryption-at-rest / secure key management policy (out of scope for this learning app).

Rule for this phase:

- Do not add new features before architecture and test foundations are stable.
- Avoid advanced patterns (CQRS, event-sourcing, micro-modules) until current stack becomes routine.

## How To Read This Project (Learning Order)

1. `lib/app.dart` (root wiring and top-level flow)
2. `presentation/bloc/*_bloc.dart` (events -> states)
3. `domain/usecases/*` (single action classes)
4. `domain/repositories/*` (contracts)
5. `data/*_repository_impl.dart` (contract implementation)
6. `data/datasources/*_local_data_source.dart` (Drift access only)
7. `core/database/app_database.dart` (tables/schema)

## AI Prompt You Can Reuse

Use this prompt when asking an AI to continue this codebase:

> Follow this architecture strictly: feature-first clean architecture with layers `presentation -> domain -> data`.  
> UI widgets can only talk to BLoC. BLoC should call use-cases only.  
> Use-cases depend on repository contracts in domain.  
> Repository implementations live in data layer and depend on datasource classes.  
> Datasources are the only layer allowed to directly use Drift tables/queries.  
> Return explicit `Result<T>` (`Success` / `FailureResult`) across use-cases where possible.  
> Use `get_it` registrations from `core/di/injection.dart` for dependency wiring.  
> Hash passwords through `core/security/password_hasher.dart` before persistence.  
> Keep comments short and educational.  
> Do not break existing behavior and keep Bangla/English and current visual design intact.


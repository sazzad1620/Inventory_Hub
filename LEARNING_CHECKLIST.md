# Learning Checklist: Basic -> Industrial Flutter (Using This App)

This checklist is designed for your exact goal:

- learn quickly
- keep the app small
- build industrial-level thinking step-by-step

Use this file as your roadmap while studying this project.

---

## How To Use This Checklist

- Work in order (Phase 0 -> Phase 4).
- Do not add new features until Phase 2 is mostly complete.
- After each checkbox block, run:
  - `flutter analyze`
  - `flutter test`
- Keep `ARCHITECTURE.md` updated whenever you change architecture or rules (mandatory).

---

## Start Gate (Do This First)

Pass this gate before Phase 0:

- [ ] Run `flutter analyze` and keep it green.
- [ ] Run `flutter test` and keep it green.
- [ ] Trace auth flow on paper:
  - Login tap -> `AuthBloc` event -> usecase -> repository -> datasource -> Drift -> state -> UI
- [ ] Trace product flow on paper:
  - Add product -> `ProductBloc` -> usecase -> repository -> datasource -> DB -> list refresh

If this gate is complete, start learning immediately without feature expansion.

---

## Phase 0 - Foundation Setup (Current App Understanding)

Goal: Understand architecture flow end-to-end without coding much.

- [ ] Read `ARCHITECTURE.md` fully.
- [ ] Trace one flow on paper:
  - Login tap -> `AuthBloc` event -> usecase -> repository -> datasource -> Drift -> state -> UI
- [ ] Trace one product flow:
  - Add product -> `ProductBloc` -> usecase -> repository -> datasource -> DB -> list refresh
- [ ] Explain dependency rule from memory:
  - `UI -> BLoC -> UseCase -> Repository -> DataSource -> Drift`
- [ ] Explain why domain layer has no Drift/UI imports.

Exit criteria:

- You can explain each layer in 2-3 sentences.
- You can locate any logic in code within 30-60 seconds.

---

## Phase 1 - BLoC Mastery (Small App, Deep Understanding)

Goal: Be confident with event -> state modeling and error handling.

- [ ] For `AuthBloc`, list all events and expected state transitions.
- [ ] For `ProductBloc`, list all events and expected state transitions.
- [ ] Add/maintain tests for:
  - [ ] success path
  - [ ] failure path
  - [ ] invalid input path (where relevant)
- [ ] Verify UI behavior on loading/success/failure is consistent.
- [ ] Keep error codes stable and mapped in UI messages.

Exit criteria:

- You can predict exact state sequence before running tests.
- BLoC tests are your first guardrail before refactor.

---

## Phase 2 - Clean Architecture Discipline

Goal: Build industrial habits while keeping the app simple.

- [ ] Keep usecases focused: one action per class.
- [ ] Keep repository contracts in `domain` only.
- [ ] Keep repository implementations in `data` only.
- [ ] Keep all Drift queries inside datasource classes only.
- [ ] Avoid direct feature-to-feature coupling in presentation.
- [ ] Keep DI registration clean in `core/di/injection.dart`.

Architecture safety checks:

- [ ] No `presentation` import from `data`.
- [ ] No `domain` import from Flutter UI or Drift packages.
- [ ] No SQL/Drift call directly from BLoC or UI.

Exit criteria:

- You can refactor one layer without breaking other layers unexpectedly.

---

## Phase 3 - Testing to Near-Industry Baseline

Goal: Build confidence like real teams do.

Minimum target for this app:

- [ ] Auth usecase tests (success + invalid + failure mapping)
- [ ] Auth bloc tests (loading/success/failure)
- [ ] Product usecase tests (success + failure mapping)
- [ ] Product bloc tests (loading/loaded/failure for load/add/update/delete)
- [ ] At least one widget test for auth screen behavior
- [ ] At least one widget test for product form behavior

Quality rules:

- [ ] Every bug fix should include or update a test.
- [ ] Prefer deterministic tests (no time/network randomness).

Exit criteria:

- You trust tests enough to refactor confidently.

---

## Phase 4 - Industrial Thinking (Without App Bloat)

Goal: Learn industry mindset before adding enterprise complexity.

- [ ] Introduce typed failures gradually (not only generic messages).
- [ ] Add simple Drift migration practice (`schemaVersion` + migration notes).
- [ ] Document key trade-offs in `ARCHITECTURE.md`:
  - why BLoC here
  - why local-only DB for now
  - when to introduce remote sync later
- [ ] Keep PR-size changes small and test-backed.
- [ ] Keep naming and folder consistency strict.

Do NOT rush yet:

- [ ] Skip advanced patterns (CQRS/event-sourcing/micro-modules) until current stack is second nature.
- [ ] Skip remote caching/sync complexity until your local architecture is very stable.

Exit criteria:

- You can explain not only *what* your architecture is, but *why* each choice was made.

---

## Weekly Learning Sprint Template (Fast Progress)

Use this weekly cycle:

1. Study one flow deeply (60-90 min)
2. Write/expand tests for that flow (60 min)
3. Refactor one small part safely (30-60 min)
4. Update docs (`ARCHITECTURE.md`) (15 min)
5. Run analyze + test and review what changed (10 min)

---

## Definition of "Ready for Bigger App"

You are ready to scale beyond this small app when:

- [ ] You can implement a new CRUD module with the same architecture without confusion.
- [ ] You can write BLoC + usecase tests first, then implement.
- [ ] You can identify layer violations quickly during review.
- [ ] You can debug state issues from logs/tests without random trial-and-error.
- [ ] Your docs stay aligned with code after each refactor.

If these are true, your foundation is strong enough for larger, more complex Flutter apps.

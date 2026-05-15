# Mangastash

Manga Reader Apps built with Flutter, focusing on modularity and high performance.

# Coverage Status

[![codecov](https://codecov.io/gh/robzimpulse/mangastash/graph/badge.svg?token=P2VBLN6SN3)](https://codecov.io/gh/robzimpulse/mangastash)

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (v3.32.8)
- **Monorepo**: [Melos](https://melos.invertase.dev/) for multi-package management.
- **State Management**: BLoC (via internal `safe_bloc`), Provider, and RxDart.
- **Persistence**: [Drift](https://drift.simonbinder.eu/) (SQLite) for high-performance local storage.
- **Dependency Injection**: Custom `ServiceLocator` pattern based on `GetIt`.
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom retry logic.
- **Routing**: [go_router](https://pub.dev/packages/go_router).
- **UI & Theming**: Material Design 3, `FlexColorScheme`, and `Responsive Framework`.

## ⚙️ Prerequisites

- **FVM** (Flutter Version Manager): Highly recommended to ensure the correct Flutter version is used.
- **Melos**: Run `dart pub global activate melos` to manage the monorepo.
- **LCOV**: Required for generating local coverage reports.

## 🏁 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/robzimpulse/mangastash.git
cd mangastash
```

### 2. Setup Environment
Ensure you have FVM installed, then:
```bash
fvm install
```

### 3. Bootstrap the Workspace
Link all modules and install dependencies across the monorepo:
```bash
melos run refresh
# or
melos bootstrap
```

### 4. Code Generation
Generate the necessary boilerplate for Drift, JsonSerializable, and other source generators:
```bash
melos run generate
```

### 5. Running the App
```bash
fvm flutter run
```

## 📂 Project Structure

The project follows a **Modular Clean Architecture** pattern sharded into the `module/` directory:

- **`lib/`**: The main entry point and app orchestration.
- **`module/entity/`**: Pure data models and value objects.
- **`module/domain/`**: Business logic, use cases, and repository interfaces.
- **`module/core/`**: Infrastructure concerns (Auth, Route, Network, Storage, Analytics, Environment).
- **`module/library/`**: Internal utilities and 3rd-party wrappers (Drift service, Service Locator).
- **`module/ui/`**: Reusable UI components and shared widgets (`ui_common`).
- **`module/feature/`**: High-level feature orchestration (Browse, Library, History, etc.).

## 🧪 Testing

The project emphasizes test coverage and reliability.

- **Run All Tests**:
  ```bash
  melos run test
  ```
- **Generate Merged Coverage Report**:
  ```bash
  melos run coverage:merged
  ```

## 🚢 Deployment

The app is configured for multiple platforms (Android, iOS, Web, Desktop). 
- **Firebase**: Uses Firebase for backend services. Configuration is managed via `firebase.json` and `firebase_options.dart`.
- **CI/CD**: GitHub Actions are used for automated testing and coverage reporting to Codecov.

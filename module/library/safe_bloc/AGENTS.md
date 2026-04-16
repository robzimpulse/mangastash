# safe_bloc Context

## Purpose:
The `safe_bloc` module acts as a robust wrapper around `flutter_bloc` to prevent common runtime crashes and streamline state management. It enforces lifecycle safety by ensuring emissions only occur on open blocs and automates stream subscription cleanup to prevent memory leaks.

## Key Components:
* **safe_cubit.dart**: Defines a `Cubit` subclass that overrides `emit` to perform an `isClosed` check, preventing "emit after close" exceptions.
* **auto_subscription_mixin.dart**: Provides the `AutoSubscriptionMixin`, which automates the tracking and cancellation of `StreamSubscription` instances when a `Bloc` or `Cubit` is closed.
* **safe_bloc.dart**: The primary library entry point that exports `flutter_bloc` (with the original `Cubit` hidden to enforce the safe version).

## Dependencies:
* **External Packages**: `flutter_bloc` (re-exported).
* **Language**: `dart:async`.

## Local Conventions:
* **Enforced Safety**: Developers are encouraged to use the provided `Cubit` rather than the base `bloc.Cubit` to automatically guard against emission crashes.
* **Subscription Management**: Any custom stream subscriptions within BLoCs/Cubits must be managed using `AutoSubscriptionMixin.addSubscription` to ensure proper disposal.
* **Re-export Pattern**: The module hides original `flutter_bloc` classes that are being augmented, promoting the use of the "safe" variants across the monorepo.

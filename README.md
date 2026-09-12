# EasyCertificate

EasyCertificate is a Flutter application for creating certificate batches,
uploading source files, and mapping certificate data.

## Project structure

```text
lib/
├── app/                         # Application bootstrap and global configuration
├── core/
│   ├── models/                  # Shared domain models
│   ├── services/                # Shared data and serialization services
│   └── theme/                   # Shared colors and theme values
├── features/
│   ├── auth/
│   │   └── screens/             # Login and registration flows
│   ├── certificates/
│   │   ├── screens/             # Certificate batch and data mapping flows
│   │   ├── state/               # Certificate editor state
│   │   └── widgets/             # Certificate editor components
│   └── dashboard/
│       ├── screens/             # Dashboard flow
│       └── widgets/             # Dashboard-specific components
└── main.dart                    # Flutter entry point
```

Feature-specific code belongs in its feature folder. Reusable domain objects,
services, and theme values belong in `core`.

## Getting started

Install Flutter, then run:

```bash
flutter pub get
flutter run
```

To verify the Dart code:

```bash
dart analyze
```

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Celechron** is a cross-platform Flutter mobile app designed as a comprehensive time management and academic utility for students at Zhejiang University (ZJU). The app provides schedule management, grade queries, deadline tracking, and campus card payment integration.

## Technology Stack & Architecture

### Core Technologies
- **Framework:** Flutter (SDK >=3.0.0) with Dart
- **State Management:** GetX
  - Uses `Get.put()` for dependency injection with tags
  - Uses `Obx(() => ...)` for reactive UI updates
  - Uses `Rx<Type>` variables for observable state
- **Local Database:** Hive (NoSQL key-value store)
- **Secure Storage:** flutter_secure_storage for credentials
- **UI:** Primarily Cupertino widgets (iOS-style) with `GetCupertinoApp`, even on Android

### State Management Pattern

The app uses a centralized GetX-based state management approach initialized in `lib/main.dart`:

1. **DatabaseHelper** is injected as a singleton: `Get.put(DatabaseHelper(), tag: 'db')`
2. **Global observables** are registered with tags:
   - `'scholar'` - User academic data (Scholar object)
   - `'taskList'` - Deadline/task list
   - `'taskListLastUpdate'` - Last task sync time
   - `'flowList'` - Schedule periods
   - `'flowListLastUpdate'` - Last schedule sync time
   - `'option'` - User preferences
   - `'fuse'` - App update/version info

Access these anywhere via `Get.find<Rx<Type>>(tag: 'tagname')`.

### Database Architecture

Hive is initialized in main.dart with multiple boxes:
- `dbScholar` - User profile and academic data (Scholar model)
- `dbTask` - Deadline and task lists
- `dbFlow` - Schedule/period data
- `dbOptions` - User preferences (work time, rest time, GPA strategy, etc.)
- `dbFuse` - App versioning/update metadata
- `dbOriginalWebPage` - Cached web scraping results
- `dbCustomGpa` - Custom GPA calculation selections

**Important:** Credentials (username/password) are stored in `FlutterSecureStorage`, NOT in Hive. See `database_helper.dart:228-266`.

### Network & Data Fetching

The app uses custom web scrapers ("spiders") in `lib/http/` to interface with ZJU academic systems:
- `ugrs_spider.dart` - Undergraduate student data scraping
- `grs_spider.dart` - Graduate student data scraping
- `lib/http/zjuServices/` - Modular services for specific ZJU systems:
  - `zjuam.dart` - Unified authentication
  - `courses.dart` - Course schedule
  - `zdbk.dart` - "学在浙大" (Study at ZJU) platform
  - `grs_new.dart` - Graduate system
  - `ecard.dart` - Campus card integration
  - `appservice.dart` - ZJU app service APIs

The `Scholar` model (lib/model/scholar.dart) orchestrates authentication and data refresh via these spiders.

## Project Structure

```
lib/
├── main.dart              # App entry point, initialization
├── algorithm/             # Utility algorithms (course scheduling, etc.)
├── database/              # Hive adapters and DatabaseHelper
│   └── adapters/          # Custom type adapters for Hive
├── design/                # Reusable UI components, colors, decorations
├── http/                  # Network layer and web scrapers
│   ├── spider.dart        # Base spider interface
│   ├── ugrs_spider.dart   # Undergraduate scraper
│   ├── grs_spider.dart    # Graduate scraper
│   └── zjuServices/       # Modular ZJU service clients
├── model/                 # Data models (Course, Exam, Grade, Scholar, etc.)
├── page/                  # UI screens (views), organized by feature
│   ├── calendar/          # Calendar view
│   ├── flow/              # Schedule flow ("接下来" - What's Next)
│   ├── task/              # Task/deadline management
│   ├── scholar/           # Academic info (grades, GPA)
│   ├── option/            # Settings
│   └── search/            # Search functionality
├── pigeon/                # Platform channel definitions
├── utils/                 # Helper functions (dates, GPA calculations, etc.)
└── worker/                # Background tasks, widget updaters
```

## Common Development Commands

### Build & Run
```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release
```

### Code Quality
```bash
# Format code
dart format .

# Analyze code (static analysis)
flutter analyze

# Analyze with no fatal infos (CI style)
flutter analyze --no-fatal-infos

# Run tests (currently not implemented, but standard command)
flutter test
```

### Platform-Specific
```bash
# Update launcher icons
flutter pub run flutter_launcher_icons

# iOS pod install
cd ios && pod install && cd ..

# Android clean build
cd android && ./gradlew clean && cd ..
```

## Localization

The app supports Chinese (zh) and English (en), defaulting to Chinese. The locale is set in main.dart:

```dart
locale: const Locale('zh'),
```

All UI uses 24-hour time format via `MediaQuery.copyWith(alwaysUse24HourFormat: true)`.

## Important Patterns & Conventions

### Reactive UI Updates

When modifying global state, always call `.refresh()` on the Rx variable to trigger UI updates:

```dart
var scholar = Get.find<Rx<Scholar>>(tag: 'scholar');
scholar.value.login().then((value) => scholar.refresh());
```

### Asynchronous Operations

Heavy use of `Future` and `await` for database and network operations. The Scholar model uses a mutex pattern to prevent concurrent refreshes (see `scholar.dart:122-134`).

### GPA Calculations

The app calculates multiple GPA types (see `lib/utils/gpa_helper.dart`):
- 保研 GPA (for graduate school admission) - uses first attempt only
- 出国 GPA (for study abroad) - uses highest attempt
- Supports 5-point, 4-point (4.3), original 4-point, and 100-point scales

GPA strategy is configurable in user options.

### Course ID Mapping

Physical education courses and retaken courses require special handling. Course IDs are normalized using regex patterns and user-defined mappings (see `scholar.dart:156-174` and `database_helper.dart:167-177`).

### Deep Linking

The app supports deep links for the campus card payment page:
- URL scheme: `celechron://ecardpaypage`
- Handled in `main.dart:122-131`

## CI/CD

GitHub Actions workflow (`.github/workflows/code_check.yml`):
1. Checks code formatting: `dart format --output=none --set-exit-if-changed .`
2. Runs static analysis: `flutter analyze --no-fatal-infos`
3. Tests are currently commented out

**Before pushing:** Ensure code is formatted and passes analysis.

## Development Notes

- The app uses iOS-style Cupertino widgets across all platforms for visual consistency
- Android-specific configuration includes edge-to-edge display and transparent navigation bar (see `main.dart:133-166`)
- Background refresh and widget updates are handled by `lib/worker/` classes
- The app has a "fuse" system for update checking and feature flags (see `lib/worker/fuse.dart`)
- Mock user support exists for testing (username: `3200000000`)

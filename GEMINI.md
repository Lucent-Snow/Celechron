# Celechron Project Context

## Project Overview
**Celechron** is a cross-platform mobile application designed as a comprehensive time management and academic utility for students of Zhejiang University (ZJU).

**Core Features:**
- **Schedule Management:** Calendar and course schedule viewing.
- **Academic Tools:** Grade queries and exam schedules.
- **Productivity:** Deadline (DDL) assistant and task management.
- **Utilities:** Campus card (ECard) payment integration.

## Technology Stack
- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [GetX](https://pub.dev/packages/get)
  - Uses `Get.put()` for dependency injection.
  - Uses `Obx(() => ...)` for reactive UI updates.
  - Uses `Rx<Type>` variables for observable state.
- **Local Database:** [Hive](https://pub.dev/packages/hive) (NoSQL)
- **Networking:** Custom spiders (`lib/http/`) to interface with ZJU academic systems.
- **UI Library:** Primarily Cupertino (iOS-style) widgets (`GetCupertinoApp`, `CupertinoThemeData`), with Material widgets where necessary.

## Project Structure
- **`lib/`**: Main application source code.
  - **`main.dart`**: Entry point. Initializes Hive, GetX services, and notifications.
  - **`algorithm/`**: Utility algorithms (e.g., course arrangement).
  - **`database/`**: Hive database adapters and helper classes (`DatabaseHelper`).
  - **`design/`**: Reusable UI components and styling (colors, decorations).
  - **`http/`**: Network services and web scrapers (`spider.dart`, `grs_spider.dart`).
  - **`model/`**: Data models (POJOs/POGOs) like `Course`, `Exam`, `Scholar`.
  - **`page/`**: Application screens (Views), organized by feature (calendar, flow, scholar, etc.).
  - **`utils/`**: Helper functions for dates, platforms, and GPA calculations.
  - **`worker/`**: Background tasks and widget updaters.

## Development Workflow

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK

### Build & Run
1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Run Application:**
    ```bash
    flutter run
    ```

### Code Quality & Testing
- **Formatting:**
  ```bash
  dart format .
  ```
- **Linting (Static Analysis):**
  Uses `flutter_lints` rules.
  ```bash
  flutter analyze
  ```
- **Testing:**
  *(Note: CI currently has tests commented out, but standard command applies)*
  ```bash
  flutter test
  ```

## Coding Conventions
- **State Management:** Prefer GetX for global state and simple reactive state management.
- **UI Style:** The app heavily relies on `Cupertino` widgets to provide an iOS-like aesthetic, even on Android.
- **Asynchronous Operations:** Heavy use of `Future` and `await` for database and network operations.
- **Localization:** Supports Chinese (`zh`) and English (`en`), defaulting to Chinese.

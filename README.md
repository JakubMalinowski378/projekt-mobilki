# Personal Finance Tracker

A comprehensive Flutter application for managing personal finances, built according to the PRD specifications.

## Features

### ✅ Implemented Features

1. **Transaction Management**
   - Add, edit, and delete transactions
   - Support for income and expense types
   - Multi-currency support (USD, EUR, PLN, GBP, JPY)
   - Date selection
   - Category assignment
   - Optional descriptions

2. **Categories**
   - CRUD operations for categories
   - Separate categories for income and expenses
   - Default categories pre-loaded on first launch:
     - Income: Salary, Business, Investments
     - Expenses: Food & Dining, Transportation, Shopping, Entertainment, Bills & Utilities, Healthcare

3. **Statistics & Charts**
   - Monthly and yearly statistics
   - Total income, expenses, and balance
   - Pie chart showing expenses by category
   - Category breakdown with percentages
   - Period navigation (previous/next month/year)

4. **Currency Exchange**
   - Integration with Exchange Rate API
   - Automatic currency rate fetching
   - Support for currency conversion
   - Local caching of exchange rates

5. **Biometric Authentication**
   - Fingerprint/Face ID authentication on app launch
   - Graceful fallback if biometric is not available

6. **Accelerometer Integration**
   - Shake device to quickly add a new transaction
   - Configurable shake sensitivity

7. **Localization**
   - Full support for English and Polish languages
   - Complete UI translation

8. **Database**
   - SQLite with Drift ORM
   - Offline-first architecture
   - Three main entities: Transactions, Categories, CurrencyRates
   - Automatic database migrations

9. **Material Design 3**
   - Modern UI with Material 3 components
   - Light and dark theme support
   - Bottom navigation with 4 sections
   - Responsive design

10. **Local Notifications**
    - Service ready for payment reminders
    - Configurable notification settings

## Architecture

The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── data/
│   ├── database/          # Drift database and tables
│   └── services/          # External services (API, biometric, notifications)
├── providers/             # State management with Provider
├── screens/              # UI screens
├── l10n/                 # Localization files
└── main.dart            # App entry point
```

### Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Provider
- **Database**: Drift (SQLite)
- **Charts**: fl_chart
- **HTTP**: http package
- **Biometric Auth**: local_auth
- **Sensors**: sensors_plus
- **Notifications**: flutter_local_notifications
- **Localization**: flutter_localizations + intl

## Setup Instructions

### Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository** (if applicable)

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate database code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Generate localization files**:
   ```bash
   flutter gen-l10n
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## Permissions

The app requires the following Android permissions:

- `USE_BIOMETRIC` - For fingerprint/face authentication
- `INTERNET` - For fetching currency exchange rates
- `POST_NOTIFICATIONS` - For local notifications

These are configured in `android/app/src/main/AndroidManifest.xml`.

## Usage

### First Launch

1. The app will request biometric authentication (if available)
2. Default categories will be automatically created
3. You can start adding transactions immediately

### Adding Transactions

Three ways to add a transaction:
1. Tap the "+" button in the Transactions screen
2. Shake your device anywhere in the app
3. Use the bottom navigation to navigate and add

### Viewing Statistics

1. Navigate to the Statistics tab
2. Toggle between monthly and yearly views
3. Navigate between periods using arrow buttons
4. View pie chart and category breakdown

### Managing Categories

1. Navigate to the Categories tab
2. Switch between Income and Expense tabs
3. Add, edit, or delete categories as needed
4. Categories are linked to transactions

## Database Schema

### Transactions Table
- `id` (Primary Key)
- `amount` (Real)
- `currency` (Text, 3 chars)
- `date` (DateTime)
- `categoryId` (Foreign Key → Categories)
- `type` (Enum: income/expense)
- `description` (Text, nullable)
- `createdAt` (DateTime)

### Categories Table
- `id` (Primary Key)
- `name` (Text, 1-100 chars)
- `type` (Enum: income/expense)
- `createdAt` (DateTime)

### CurrencyRates Table
- `id` (Primary Key)
- `currency` (Text, 3 chars)
- `rate` (Real)
- `date` (DateTime)
- `createdAt` (DateTime)

## API Integration

The app uses the Exchange Rate API (https://api.exchangerate-api.com/v4/latest/USD) to fetch current exchange rates. Rates are cached locally in the database.

## Future Enhancements

- Budget setting and tracking
- Recurring transactions
- Export to CSV/PDF
- Cloud backup and sync
- Multiple accounts support
- Receipt photo attachment
- Custom date range statistics
- More chart types (bar charts, line charts)
- Widget for home screen

## Development

### Adding a New Language

1. Create a new ARB file in `lib/l10n/` (e.g., `app_es.arb`)
2. Copy the structure from `app_en.arb`
3. Translate all strings
4. Add the locale to `supportedLocales` in `main.dart`
5. Run `flutter gen-l10n`

### Modifying Database Schema

1. Update table definitions in `lib/data/database/tables.dart`
2. Update `schemaVersion` in `lib/data/database/database.dart`
3. Add migration logic in the `migration` property
4. Run `dart run build_runner build --delete-conflicting-outputs`

## Troubleshooting

### Build Runner Issues
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Localization Not Working
```bash
flutter gen-l10n
flutter clean
flutter run
```

### Database Issues
Clear app data on the device or uninstall and reinstall the app.

## License

This is a personal project for educational purposes.

## Contributing

This project is developed according to the PRD specifications. For changes or improvements, please refer to the PRD document.
